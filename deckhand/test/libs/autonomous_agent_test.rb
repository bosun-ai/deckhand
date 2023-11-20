require 'test_helper'

class AutonomousAgentTest < ActiveSupport::TestCase
  class DummyAgent < AutonomousAgent
    def around_run(&block)
      block.call
      dummy_callback
    end
      
    def around_run_agent(*args, **kwargs, &block)
      block.call(*args, **kwargs)
      dummy_callback
    end

    def run(raise_error: nil)
      raise raise_error if raise_error
      "success"
    end

    def dummy_callback
    end
  end

  setup do
    @agent = DummyAgent.new()
  end

  test 'run callback gets called when run is called' do
    @agent.expects(:dummy_callback).once
    @agent.run
  end

  test 'run_agent runs agent with parent as kwarg' do
    DummyAgent.expects(:run).with(has_entries(parent: @agent))
    @agent.run_agent(DummyAgent)
  end

  test 'hack allows the same behaviour when run is used instead' do
    DummyAgent.expects(:run).with(has_entries(parent: @agent))
    @agent.run(DummyAgent)
  end
  
  test 'run_agent callback gets called when run_agent is called' do
    @agent.expects(:dummy_callback).once
    @agent.run_agent(DummyAgent)
  end

  class DummyArgumentAgent < AutonomousAgent
    arguments :pos_1, :pos_2, kwarg_1: 'ok', kwarg2: 'ok2'
  end

  test 'allows positional arguments and keyword arguments to be set' do
    agent = DummyArgumentAgent.new('pos_1', 'pos_2', kwarg_1: 'very ok')
    assert_equal agent.pos_1, 'pos_1'
    assert_equal agent.pos_2, 'pos_2'
    assert_equal agent.kwarg_1, 'very ok'
    assert_equal agent.kwarg2, 'ok2'
  end

  test 'allows all values to be set from arguments hash as well' do
    agent = DummyArgumentAgent.new(pos_1: 'pos_1', pos_2: 'pos_2', kwarg_1: 'very ok')
    assert_equal agent.pos_1, 'pos_1'
    assert_equal agent.pos_2, 'pos_2'
    assert_equal agent.kwarg_1, 'very ok'
    assert_equal agent.kwarg2, 'ok2'
  end
end
