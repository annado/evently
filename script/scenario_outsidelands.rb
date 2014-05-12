require_relative "actor2"

EVENT_ID = "709030562468396"
LATITUDE = 37.767238
LONGITUDE = -122.494383

l = "1216821"
n = "300255"
a = "206094"

Actor2.new({l => "Liron Yahdav", n => "Ning Liang", a => "Anna Do"}, EVENT_ID)
  .queue_set_status(nil, l)
  .queue_set_status(nil, a)
  .queue_set_status(nil, n)
  .queue_set_location(LATITUDE, LONGITUDE, l)
  .queue_set_location(37.770655, -122.490735, a)
  .queue_set_location(37.769578, -122.487388, n)
  .queue_wait_for_input #.queue_set_status('I found a pretty good spot, find me!', l) #.queue_wait_for_input
  .queue_set_status("I'm at the entrance, heading there", a)
  .queue_wait_for_input
  .queue_set_status('Grabbing some food. When do they start?', n)
  .queue_wait_for_input #.queue_set_status(nil, n) #.queue_set_status('10 minutes, hurry!', l) #.queue_wait_for_input
  .queue_set_status(nil, n)
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
  .queue_wait_for_input #.queue_set_status("They're coming on stage!", l)
  .queue_set_location(37.767755, -122.492452, a)
  .queue_set_location(37.767755, -122.492452, n)
  .queue_wait_for_input
  .queue_set_status("We're close!", n)
  .queue_set_location(LATITUDE, LONGITUDE, a)
  .queue_set_location(LATITUDE, LONGITUDE, n)
  .start_running
  .wait_until_done
