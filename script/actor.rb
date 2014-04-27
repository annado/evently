require "rubygems"
require "pubnub"
require "parse-ruby-client"
require "thread"

PARSE_MUTEX = Mutex.new

# NOTE all durations are assumed to be in integer seconds
class Actor

  PUBLISH_KEY = "pub-c-c946c570-8c5e-4b33-b8f4-a54e4e8c9f4e"
  SUBSCRIBE_KEY = "sub-c-d45c86be-cb56-11e3-94ea-02ee2ddab7fe"
  PUBNUB_ORIGIN = "pubsub.pubnub.com"

  PARSE_APP_ID = "2DhYRY420kuYwMv12BZrEzpbjebGS9wVlCtJKdnz"
  PARSE_API_KEY = "7ZPfJh62fZZ5TRpDmJYLmN6YIxUNNw5X7CZhBal9"

  def initialize(user_id, full_name, event_id)
    @actions = []
    @mutex = Mutex.new

    @user_id = user_id
    @full_name = full_name
    @event_id = event_id

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

    @latitude = nil
    @longitude = nil
  end

  def queue_set_location(lat, lng)
    @actions.push({
      type: :set_location,
      latitude: lat,
      longitude: lng
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

  def queue_move(lat, lng, duration)
    @actions.push({
      type: :move,
      latitude: lat,
      longitude: lng,
      duration: duration
    })
    self
  end

  def queue_set_status(text)
    @actions.push({
      type: :set_status,
      text: text
    })
    self
  end

  def start_running
    return if @runner
    @runner = Thread.new do
      while (action = next_action)
        case action[:type]
          when :set_location then set_location(action[:latitude], action[:longitude])
          when :set_status then set_status(action[:text])
          when :wait then sleep(action[:duration])
          when :move then move(action[:latitude], action[:longitude], action[:duration])
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

  def set_location(latitude, longitude)
    @latitude = latitude
    @longitude = longitude

    message = [@user_id, @latitude, @longitude].join(",")
    @pubnub.publish(
      channel: "#{@event_id}_location",
      message: message,
      http_sync: true
    ) { |env| log_event(env) }

    # Update parse
    location = get_user_event_location
    location["latitude"] = @latitude
    location["longitude"] = @longitude
    PARSE_MUTEX.synchronize { location.save }
  end

  def move(lat_end, lng_end, duration)
    lat_interval = (lat_end - @latitude) / duration
    lng_interval = (lng_end - @longitude) / duration

    # Basically a timer
    duration.times do
      sleep 1
      set_location(@latitude + lat_interval, @longitude + lng_interval)
    end
  end

  def set_status(text)
    message = [@user_id, @full_name, text, Time.now.to_f]
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

  def get_user_event_location
    query = Parse::Query.new("UserEventLocation")
    query.eq("eventFacebookID", @event_id)
    query.eq("user", get_user)

    event_location = PARSE_MUTEX.synchronize { query.get.first }
    unless event_location
      event_location = Parse::Object.new("UserEventLocation")
      event_location["user"] = get_user
      event_location["eventFacebookID"] = @event_id
    end
    event_location
  end

  def get_user
    unless @user
      query = Parse::Query.new("_User")
      query.eq("facebookID", @user_id)
      @user = PARSE_MUTEX.synchronize { query.get.first }
      raise "No parse user found for #{@user_id}" unless @user
    end
    @user
  end

end
