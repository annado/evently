require_relative "actor"

EVENT_ID = "703885286319620"
LATITUDE = 37.770481
LONGITUDE = -122.404289

ning = Actor.new("300255", "Ning Liang", EVENT_ID)
ning.queue_set_location(LATITUDE - 0.002, LONGITUDE + 0.004)
  .queue_set_status("I'm on my way!")
  .queue_move(LATITUDE, LONGITUDE, 8)
  .queue_set_status("I'm here!")

anna = Actor.new("206094", "Anna Do", EVENT_ID)
anna.queue_set_location(LATITUDE + 0.008, LONGITUDE - 0.003)
  .queue_set_status("Me too, will be there soon")
  .queue_move(LATITUDE + 0.004, LONGITUDE - 0.001, 6)
  .queue_set_status("Oh no, traffic!")
  .queue_wait(4)
  .queue_set_status("It's moving again, there soon!")
  .queue_move(LATITUDE, LONGITUDE, 2)
  .queue_set_status("Arrived!")

liron = Actor.new("1216821", "Liron Yahdav", EVENT_ID)
  .queue_set_location(LATITUDE - 0.005, LONGITUDE - 0.002)
  .queue_set_status("Wrapping up some coding")
  .queue_wait(6)
  .queue_set_status("Finished, heading over")
  .queue_move(LATITUDE, LONGITUDE, 4)

users = [ning, anna, liron]
users.each(&:start_running)
users.each(&:wait_until_done)
