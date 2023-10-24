require 'test_helper'

class DummyAgent < AutonomousAgent
  set_callback :run, :after, :dummy_callback
  set_callback :run_agent, :after, :dummy_callback

  def run(raise_error: nil)
    raise raise_error if raise_error
    "success"
  end

  def dummy_callback
  end
end

class AutonomousAgentTest < ActiveSupport::TestCase
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
end