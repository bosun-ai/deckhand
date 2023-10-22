require 'test_helper'

class ApplicationAgentTest < ActiveSupport::TestCase
  setup do
    @agent = ApplicationAgent.new(context: 'some_context', tools: [AnalyzeFileTool, ListFilesTool])

    dummy_logger = mock('Logger')
    dummy_logger.stubs(:anything).returns(nil)

    @agent.stubs(:logger).returns(dummy_logger)
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

  test 'run callback creates agent run and records exception on error' do
    mock_span = mock('OpenTelemetry::Trace::Span')
    mock_span.expects(:add_attributes)
    mock_span.expects(:record_exception)
    mock_span.expects(:status=)
    mock_span.expects(:context)

    OpenTelemetry::Trace.stubs(:current_span).returns(mock_span)
    AgentRun.expects(:create!).returns(AgentRun.new)
    @agent.context.stubs(:agent_run=)

    # Simulating error during agent run
    @agent.stubs(:some_internal_method).raises(StandardError, 'Some Error')

    assert_raises StandardError do
      @agent.run # Assuming the callback triggers the run method
    end
  end

  test 'prompt callback creates event on agent run' do
    event = mock('Event')
    result_mock = mock('Result')
    result_mock.stubs(:prompt).returns('prompt_here')
    result_mock.stubs(:full_response).returns('response_here')

    agent_run_mock = mock('AgentRun')
    agent_run_mock.expects(:events).returns(event).once
    event.expects(:create!).with(event_hash: {
                                   type: 'prompt',
                                   content: { prompt: 'prompt_here', response: 'response_here' }
                                 }).once

    @agent.agent_run = agent_run_mock

    # Simulate the prompt callback
    @agent.send(:prompt, 'Hello') { result_mock }
  end

  test 'run callback handles success' do
    mock_span = mock('OpenTelemetry::Trace::Span')
    mock_span.expects(:add_attributes).at_least_once

    OpenTelemetry::Trace.stubs(:current_span).returns(mock_span)

    agent_run_mock = mock('AgentRun')
    AgentRun.expects(:create!).returns(agent_run_mock)
    agent_run_mock.expects(:update!).with(has_entries(output: 'success', context: 'some_context'))

    @agent.stubs(:context).returns('some_context')

    result = @agent.send(:run) { 'success' }
    assert_equal 'success', result
  end

  test 'run callback handles exceptions' do
    mock_span = mock('OpenTelemetry::Trace::Span')
    mock_span.expects(:add_attributes).at_least_once
    mock_span.expects(:record_exception).once
    mock_span.expects(:status=).once

    OpenTelemetry::Trace.stubs(:current_span).returns(mock_span)

    agent_run_mock = mock('AgentRun')
    AgentRun.expects(:create!).returns(agent_run_mock)
    agent_run_mock.expects(:update!).with(has_entry(error: instance_of(StandardError)))

    exception = assert_raises(StandardError) do
      @agent.send(:run) { raise StandardError, 'An error occurred' }
    end
    assert_equal 'An error occurred', exception.message
  end

  test 'run callback updates agent_run with parent' do
    mock_span = mock('OpenTelemetry::Trace::Span')
    mock_span.expects(:add_attributes).at_least_once

    OpenTelemetry::Trace.stubs(:current_span).returns(mock_span)

    parent_run = mock('AgentRun')
    event = mock('Event')
    parent_run.expects(:events).returns(event).once
    event.expects(:create!).with(event_hash: { type: 'run_agent', content: instance_of(Numeric) }).once

    agent_run_mock = mock('AgentRun')
    AgentRun.expects(:create!).returns(agent_run_mock)
    agent_run_mock.stubs(:parent).returns(parent_run)

    @agent.stubs(:parent).returns(OpenStruct.new(agent_run: parent_run))

    @agent.send(:run) { 'success' }
  end
end
