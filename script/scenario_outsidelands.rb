require_relative "actor2"

EVENT_ID = "709030562468396"
LATITUDE = 37.767238
LONGITUDE = -122.494383

l = "1216821"
n = "300255"
a = "206094"

r = Actor2.new({l => "Liron Yahdav", n => "Ning Liang", a => "Anna Do"}, EVENT_ID)
  .queue_set_status(nil, l)
  .queue_set_status(nil, a)
  .queue_set_status(nil, n)
  .queue_set_location(LATITUDE, LONGITUDE, l)
  .queue_set_location(37.770655, -122.490735, a)
  .queue_set_location(37.769578, -122.487388, n)
  .queue_wait_for_input
  .queue_set_status('I found a pretty good spot, find me!', l)
  .queue_wait_for_input
  .queue_set_status("I'm at the entrance, heading there", a)
  .queue_wait_for_input
  .queue_set_status('Grabbing some food. When do they start?', n)
  .queue_wait_for_input
  .queue_set_status(nil, n)
  .queue_set_status('10 minutes, hurry!', l)
  .queue_wait_for_input
  .queue_set_location(37.769417, -122.490735, a)
  .queue_set_location(37.769205, -122.488600, n)
  .queue_wait_for_input
  .queue_set_status("I'll wait for you here Ning", a)
  .queue_wait_for_input
  .queue_set_status("Just a minute!", n)
  .queue_set_location(37.769417, -122.490735, n)
  .queue_wait_for_input
  .queue_set_status(nil, n)
  .queue_set_status(nil, a)
  .queue_set_location(37.768374, -122.490735, a)
  .queue_set_location(37.768374, -122.490735, n)
  .queue_wait_for_input
  .queue_set_status("They're coming on stage!", l)
  .queue_set_location(37.767755, -122.492452, a)
  .queue_set_location(37.767755, -122.492452, n)
  .queue_wait_for_input
  .queue_set_status("We're close!", n)
  .queue_set_location(LATITUDE, LONGITUDE, a)
  .queue_set_location(LATITUDE, LONGITUDE, n)

  #.queue_move(37.774073, -122.420611, 1, n)
  #.queue_wait(1)
  #.queue_set_status('Ahh traffic', n)
  #.queue_wait_for_input
  #.queue_set_status("Did you hear from Liron?", n)
  #.queue_wait_for_input
  #.queue_set_status("Nope", a)
  #.queue_wait_for_input
  #.queue_set_status("I'm straggling as usual", l)
  #.queue_wait_for_input
  #.queue_set_status('On my way now', l)
  #.queue_set_location(37.783842, -122.399068, l)
  #.queue_set_location(37.782180, -122.410569, a)
  #.queue_set_status('On my way now', l)
  #.queue_wait_for_input
  #.queue_set_status("It's moving again, there soon!", n)
  #.queue_move(37.786318, -122.423229, 3, n)
  #.queue_wait_for_input
  #.queue_set_status("Cya in a bit", a)
  #.queue_move(LATITUDE, LONGITUDE, 2, n)
  #.queue_set_location(37.787437, -122.403510, l)
  #.queue_set_location(LATITUDE, LONGITUDE, n)
  #.queue_wait_for_input
  #.queue_set_location(37.787963, -122.403531, l)
  #.queue_set_location(LATITUDE, LONGITUDE, a)
  #.queue_wait_for_input
  #.queue_set_location(37.786979, -122.411535, l)
  #.queue_wait_for_input
  #.queue_set_location(LATITUDE, LONGITUDE, l)
  r.start_running
  .wait_until_done
