require "rubygems"
require "pubnub"

### A user that wanders around ###
class User
  STEP_SIZE_DEGREES = 0.0001

  def initialize(user_id, init_lat, init_lng)
    @user_id = user_id
    @lat = init_lat
    @lng = init_lng
  end

  def step
    @lng += STEP_SIZE_DEGREES * rand - STEP_SIZE_DEGREES / 2.0
    @lat += STEP_SIZE_DEGREES * rand - STEP_SIZE_DEGREES / 2.0
  end

  def location_message
    [@user_id, @lat, @lng].join(",")
  end
end


### Begin script ###

PUBLISH_KEY = "pub-c-c946c570-8c5e-4b33-b8f4-a54e4e8c9f4e"
SUBSCRIBE_KEY = "sub-c-d45c86be-cb56-11e3-94ea-02ee2ddab7fe"

unless ARGV.length >= 4
  puts "Usage: ruby publish_locations.rb event_id user_id init_lat init_lng [sleep_interval]"
  exit(1)
end

event_id, user_id, lat, lng, sleep_interval = ARGV
lat = lat.to_f
lng = lng.to_f
sleep_interval = 1.0

pubnub = Pubnub.new(
  subscribe_key: SUBSCRIBE_KEY,
  publish_key: PUBLISH_KEY,
  origin: "pubsub.pubnub.com",
  error_callback: lambda { |msg| puts "Error: #{msg.inspect}" }
)


thread = Thread.new do
  user = User.new(user_id, lat, lng)
  on_broadcast = lambda do |env|
    time = Time.at(env.timetoken.to_i / 10000000)
    puts "#{time}: broadcasted message #{env.message.inspect}"
  end

  loop do
    user.step
    pubnub.publish(
      channel: "#{event_id}_location",
      message: user.location_message,
      &on_broadcast
    )
    sleep sleep_interval
  end
end
thread.join
