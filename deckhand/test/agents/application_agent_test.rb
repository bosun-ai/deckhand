require 'test_helper'

class ApplicationAgentTest < ActiveSupport::TestCase
  class DummyAgent < ApplicationAgent
    def run(raise_error: nil)
      raise raise_error if raise_error
      "success"
    end
  end

  class PromptingDummyAgent < ApplicationAgent
    def run
      prompt("What is up?")
    end
  end
  
  class RandomDummyAgent < ApplicationAgent
    def run
      "success-#{SecureRandom.hex(4)}"
    end
  end
  
  class RunAgentDummyAgent < ApplicationAgent
    def run
      run_agent(RandomDummyAgent)['output']
    end
  end

  def make_dummy_agent(klass)
    agent = klass.new(context: @context, tools: [AnalyzeFileTool, ListFilesTool])
    agent.stubs(:logger).returns(@dummy_logger)
    agent
  end

  setup do
    @codebase = Codebase.new
    @dummy_logger = mock('Logger')
    @dummy_logger.stubs(:anything).returns(nil)

    @context = ApplicationAgent::Context.new("testing", codebase: @codebase)
    @agent = make_dummy_agent(DummyAgent)
  end

  test 'call_function raises error when tool not found' do
    prompt_response = mock('PromptResponse')
    prompt_response.stubs(:function_call_name).returns('NonExistentTool')
    assert_raises(ApplicationTool::Error) do
      @agent.call_function(prompt_response)
    end
  end

  test 'call_function raises error for invalid args' do
    tool = mock('Tool')
    tool.stubs(:name).returns('AnalyzeFileTool')
    prompt_response = mock('PromptResponse')
    prompt_response.stubs(:function_call_name).returns('AnalyzeFileTool')
    prompt_response.stubs(:function_call_args).returns('invalid_args')

    assert_raises(ApplicationTool::Error) do
      @agent.call_function(prompt_response)
    end
  end

  test 'context_prompt returns empty string when no context' do
    @agent.context = nil
    assert_equal '', @agent.context_prompt
  end

  test 'context_prompt returns a prompt with summarized_knowledge' do
    context = mock('Context')
    context.stubs(:summarize_knowledge).returns('Hello world')
    @agent.context = context

    assert_match(/Hello world/, @agent.context_prompt)
  end

  test 'render raises error when template not found' do
    Rails.root.stubs(:/).returns(Pathname.new('/path/to/nonexistent'))
    assert_raises(RuntimeError) do
      @agent.send(:read_template_file, 'nonexistent_template')
    end
  end

  test 'summarize_tools' do
    tool = mock('Tool')
    tool.stubs(:name).returns('AnalyzeFileTool')
    tool.stubs(:description).returns('A tool for analyzing files.')
    tool.stubs(:usage).returns('Usage: AnalyzeFileTool <filename>')

    @agent.tools = [tool]

    expected_output = "  * AnalyzeFileTool: A tool for analyzing files.\n  Usage: AnalyzeFileTool <filename>"
    assert_equal expected_output, @agent.summarize_tools(@agent.tools)
  end

  test 'render reads and renders template' do
    mock_template = mock('Liquid::Template')
    mock_template.expects(:render!).with(has_key('some_key'),
                                         has_entries(strict_variables: true,
                                                     strict_filters: true)).returns('Rendered Content')

    Liquid::Template.stubs(:new).returns(mock_template)

    @agent.stubs(:read_template_file).with('some_template').returns(mock_template)

    rendered_content = @agent.render('some_template', locals: { some_key: 'some_value' })

    assert_equal 'Rendered Content', rendered_content
  end

  test 'prompt callback creates event on agent run' do
    event = mock('Event')
    result_mock = mock('Deckhand::Lm::PromptResponse')
    result_mock.stubs(:prompt).returns('prompt_here')
    result_mock.stubs(:full_response).returns('response_here')
    result_mock.stubs(:is_function_call?).returns(false)
    result_mock.stubs(:as_json).returns({ some: 'result'})

    Deckhand::Lm.expects(:prompt).returns(result_mock)

    agent = make_dummy_agent(PromptingDummyAgent)
    agent_run = AgentRun.new
    agent.agent_run = agent_run
    agent_run.expects(:events).returns(event).once
    event.expects(:create!).with(event_hash: {
                                   type: 'prompt',
                                   content: { prompt: 'prompt_here', response: 'response_here' }
                                 }).once


    # Simulate the prompt callback
    agent.run
  end

  test 'run callback handles success' do
    agent_run_mock = AgentRun.new
    agent = make_dummy_agent(DummyAgent)
    agent.agent_run = agent_run_mock

    result = agent.run
    assert_equal 'success', result.output
  end

  test 'run callback handles exceptions' do
    agent_run_mock = AgentRun.new
    agent = make_dummy_agent(DummyAgent)

    result = agent.run(raise_error: StandardError.new('A dummy error occurred'))

    assert_nil result.output
    assert_equal "A dummy error occurred", result.error["message"]
  end

  test 'run callback updates agent_run with parent' do
    parent_agent_run = AgentRun.new()
    parent_agent = DummyAgent.new()
    parent_agent.agent_run = parent_agent_run
    @agent.parent = parent_agent

    assert_equal(@agent.parent.agent_run, parent_agent_run)

    AgentRun.stubs(:create!).with do |name:, arguments:, context:, parent:|
      assert_equal(parent, parent_agent_run)
    end.returns(AgentRun.new(parent: parent_agent_run))

    events = mock('Events[]')
    parent_agent_run.expects(:events).returns(events)

    events.expects(:create!).once

    @agent.run
  end

  test 'run_agent callback increments checkpoint_index and records result in state' do
    @agent.checkpoint_index = 0
    @agent.agent_run = AgentRun.new
    result = @agent.run_agent(DummyAgent)

    assert_equal 1, @agent.checkpoint_index  

    assert_equal '1-run_agent', @agent.agent_run.state.checkpoint
    assert_equal 'success', @agent.agent_run.state.value['output']
  end

  test 'run_agent callback only runs agent if there its not been run yet' do
    agent = make_dummy_agent(RunAgentDummyAgent)
    first_result = agent.run
    agent_run = agent.agent_run

    assert_nil first_result.error

    assert_equal(1, agent.checkpoint_index)
    assert_equal 'success', first_result.output.split('-').first

    second_result = agent_run.resume

    assert_nil second_result.error
    assert_equal 'success', second_result.output.split('-').first
    assert_equal first_result.output, second_result.output
  end

  test 'an agent can be resumed from an intermediate state' do
    
  end
end
