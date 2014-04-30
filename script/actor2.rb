require "rubygems"
require "pubnub"
require "parse-ruby-client"
require "thread"

PARSE_MUTEX = Mutex.new

# NOTE all durations are assumed to be in integer seconds
class Actor2

  PUBLISH_KEY = "pub-c-c946c570-8c5e-4b33-b8f4-a54e4e8c9f4e"
  SUBSCRIBE_KEY = "sub-c-d45c86be-cb56-11e3-94ea-02ee2ddab7fe"
  PUBNUB_ORIGIN = "pubsub.pubnub.com"

  PARSE_APP_ID = "2DhYRY420kuYwMv12BZrEzpbjebGS9wVlCtJKdnz"
  PARSE_API_KEY = "7ZPfJh62fZZ5TRpDmJYLmN6YIxUNNw5X7CZhBal9"

  def initialize(full_names, event_id)
    @actions = []
    @mutex = Mutex.new

    @full_name = full_names
    @event_id = event_id
    @user_event_location = {}
    @user = {}

    @pubnub = Pubnub.new(
      subscribe_key: SUBSCRIBE_KEY,
      publish_key: PUBLISH_KEY,
      origin: PUBNUB_ORIGIN,
      error_callback: lambda { |msg| puts "Error: #{msg.inspect}" }
    )

    @parse = Parse.init(
      application_id: PARSE_APP_ID,
      api_key: PARSE_API_KEY
    )

    @latitude = {}
    @longitude = {}
  end

  def queue_set_location(lat, lng, user_id)
    @actions.push({
      type: :set_location,
      latitude: lat,
      longitude: lng,
      user_id: user_id
    })
    self
  end

  def queue_wait(duration)
    @actions.push({
      type: :wait,
      duration: duration
    })
    self
  end

  def queue_wait_for_input
    @actions.push({
      type: :wait_for_input
    })
    self
  end

  def queue_move(lat, lng, duration, user_id)
    @actions.push({
      type: :move,
      latitude: lat,
      longitude: lng,
      duration: duration,
      user_id: user_id
    })
    self
  end

  def queue_set_status(text, user_id)
    @actions.push({
      type: :set_status,
      text: text,
      user_id: user_id
    })
    self
  end

  def start_running
    return if @runner
    @runner = Thread.new do
      while (action = next_action)
        case action[:type]
          when :set_location then set_location(action[:latitude], action[:longitude], action[:user_id])
          when :set_status then set_status(action[:text], action[:user_id])
          when :wait then sleep(action[:duration])
          when :wait_for_input then puts "Press enter to continue"; gets
          when :move then move(action[:latitude], action[:longitude], action[:duration], action[:user_id])
          else
            puts "Invalid action: #{action.inspect}"
            exit(1)
        end
      end
      @runner = nil
    end
    self
  end

  def wait_until_done
    @runner.join if @runner
    self
  end

  private

  def next_action
    @mutex.synchronize { @actions.shift }
  end

  ### Actions - these execute in the runner thread ###

  def set_location(latitude, longitude, user_id)
    @latitude[user_id] = latitude
    @longitude[user_id] = longitude

    message = [user_id, @latitude[user_id], @longitude[user_id]].join(",")
    @pubnub.publish(
      channel: "#{@event_id}_location",
      message: message,
      http_sync: true
    ) { |env| log_event(env) }

    # Update parse
    location = get_user_event_location(user_id)
    location["latitude"] = @latitude[user_id]
    location["longitude"] = @longitude[user_id]
    PARSE_MUTEX.synchronize { location.save }
  end

  def move(lat_end, lng_end, duration, user_id)
    lat_interval = (lat_end - @latitude[user_id]) / duration
    lng_interval = (lng_end - @longitude[user_id]) / duration

    # Basically a timer
    duration.times do
      sleep 1
      set_location(@latitude[user_id] + lat_interval, @longitude[user_id] + lng_interval, user_id)
    end
  end

  def set_status(text, user_id)
    message = [user_id, @full_name[user_id], text, Time.now.to_f]
    @pubnub.publish(
      channel: "#{@event_id}_status",
      message: message,
      http_sync: true
    ) { |env| log_event(env) }
  end

  def log_event(env)
    time = Time.at(env.timetoken.to_i / 10000000)
    puts "#{time}: broadcasted message #{env.message.inspect}"
  end

  def get_user_event_location(user_id)
    unless @user_event_location[user_id]
      query = Parse::Query.new("UserEventLocation")
      query.eq("eventFacebookID", @event_id)
      query.eq("user", get_user(user_id))

      @user_event_location[user_id] = PARSE_MUTEX.synchronize { query.get.first }
      unless @user_event_location[user_id]
        @user_event_location[user_id] = Parse::Object.new("UserEventLocation")
        @user_event_location[user_id]["user"] = get_user(user_id)
        @user_event_location[user_id]["eventFacebookID"] = @event_id
      end
    end
    @user_event_location[user_id]
  end

  def get_user(user_id)
    unless @user[user_id]
      query = Parse::Query.new("_User")
      query.eq("facebookID", user_id)
      @user[user_id] = PARSE_MUTEX.synchronize { query.get.first }
      raise "No parse user found for #{user_id}" unless @user[user_id]
    end
    @user[user_id]
  end

end
