require_relative "actor2"

EVENT_ID = "692714194123608"
LATITUDE = 37.788200
LONGITUDE = -122.411924

l = "1216821"
n = "300255"
a = "206094"

Actor2.new({l => "Liron Yahdav", n => "Ning Liang", a => "Anna Do"}, EVENT_ID)
  .queue_set_status(nil, l)
  .queue_set_status(nil, a)
  .queue_set_status(nil, n)
  .queue_set_location(37.780972, -122.395774, l)
  .queue_set_location(37.776759, -122.416832, a)
  .queue_set_location(37.759859, -122.427585, n)
  .queue_wait_for_input
  .queue_set_status('Heading out in a bit, enjoying the sun at Dolores', n)
  .queue_wait_for_input
  .queue_set_status('Wrapping up some work, on my way soon', a)
  .queue_wait_for_input
  .queue_move(37.760232, -122.426062, 1, n)
  .queue_move(37.769154, -122.426877, 1, n)
  .queue_move(37.774073, -122.420611, 1, n)
  .queue_wait(1)
  .queue_set_status('Ahh traffic', n)
  .queue_wait_for_input
  .queue_set_status("Did you hear from Liron?", n)
  .queue_wait_for_input
  .queue_set_status("Nope", a)
  .queue_wait_for_input
  .queue_set_status("I'm straggling as usual", l)
  .queue_wait_for_input
  .queue_set_status('On my way now', l)
  .queue_set_location(37.783842, -122.399068, l)
  .queue_set_location(37.782180, -122.410569, a)
  .queue_set_status('On my way now', l)
  .queue_wait_for_input
  .queue_set_status("It's moving again, there soon!", n)
  .queue_move(37.786318, -122.423229, 3, n)
  .queue_wait_for_input
  .queue_set_status("Cya in a bit", a)
  .queue_move(LATITUDE, LONGITUDE, 2, n)
  .queue_set_location(37.787437, -122.403510, l)
  .queue_set_location(LATITUDE, LONGITUDE, n)
  .queue_wait_for_input
  .queue_set_location(37.787963, -122.403531, l)
  .queue_set_location(LATITUDE, LONGITUDE, a)
  .queue_wait_for_input
  .queue_set_location(37.786979, -122.411535, l)
  .queue_wait_for_input
  .queue_set_location(LATITUDE, LONGITUDE, l)
  .start_running
  .wait_until_done
