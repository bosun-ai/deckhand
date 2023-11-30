module ApplicationAgent::Random
  DEFAULT_SEED = 11

  def random
    @random ||= Random.new(agent_run&.id || DEFAULT_SEED)
  end

  def random_hex(amount=16)
    random.bytes(amount).unpack1('H*')
  end
end
