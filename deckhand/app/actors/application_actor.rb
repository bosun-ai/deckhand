class ApplicationActor < AutonomousActor
  set_callback :run, :before do |object|
    puts "Going to run! #{object.class}"
  end
end
