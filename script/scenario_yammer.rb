require_relative "actor2"

EVENT_ID = "1393214977631601"
LATITUDE = 37.777050
LONGITUDE = -122.417099

LEG_DURATION = 7

l = "1216821"
n = "300255"
a = "206094"
m = "795904577"
k = "100004950549793"

users = {
  l => "Liron Yahdav",
  n => "Ning Liang",
  a => "Anna Do",
  m => "Miguel Trivino",
  k => "Kate Zhang"
}

actors = Actor2.new(users, EVENT_ID)

### Clear statuses and set initial locations
actors.queue_wait_for_input("Press enter to do initial setup")
  .queue_clear_status(l)
  .queue_clear_status(n)
  .queue_clear_status(a)
  .queue_clear_status(m)
  .queue_clear_status(k)
  .queue_set_location(37.777050, -122.417099, a)
  .queue_set_location(37.778273, -122.396574, n)
  .queue_set_location(37.784277, -122.392154, l)
  .queue_set_location(37.787973, -122.399964, m)
  .queue_set_location(37.788720, -122.413526, k)
  .start_running
  .wait_until_done

### Everyone notifies initial status
### Initial leg of movement

puts "Leg 1"
actors.queue_wait_for_input("Anna post a status then press enter: I'm setting up for demo day") # .queue_set_status("I'm setting up for demo day", a)
  .queue_wait_for_input("Enter for next status")
  .queue_set_status("I'm on the bus", l)
  .queue_wait_for_input("Enter for next status")
  .queue_set_status("Heading over to MUNI", m)
  .queue_wait_for_input("Enter for next status")
  .queue_clear_status(a)
  .queue_set_status("I'm running late, as usual", n)
  .queue_wait_for_input("Enter for next status")
  .queue_clear_status(m)
  .queue_set_status("Just wrapped up, there in 5!", k)
  .queue_clear_status(n)
  .start_running
  .wait_until_done

actors.queue_wait_for_input("Press enter to start moving")
  .queue_move(37.785532, -122.396746, LEG_DURATION, l)
  .queue_move(37.789228, -122.401466, LEG_DURATION, m)
  .queue_move(37.781088, -122.411938, LEG_DURATION, k)
  .start_running
  .wait_until_done

puts "Leg 1 done"

### Second leg of movement

puts "Leg 2"
actors.queue_clear_status(k)
  .queue_clear_status(m)
  .queue_wait_for_input("Enter for next status")
  .queue_clear_status(l)
  .queue_set_status("MUNI is delayed", m)
  .queue_wait_for_input("Enter for next status")
  .queue_set_status("Done! Grabbing an Uber", n)
  .start_running
  .wait_until_done

actors.queue_wait_for_input("Press enter to start moving")
  .queue_move(37.770030, -122.407045, LEG_DURATION, n)
  .queue_move(37.772473, -122.410049, LEG_DURATION, l)
  .queue_move(37.781021, -122.411852, LEG_DURATION, k)
  .start_running
  .wait_until_done

puts "Leg 2 done"

### Third leg of movement
puts "Leg 3"
actors.queue_clear_status(l)
  .queue_wait_for_input("Enter for next status")
  .queue_set_status("MUNI cleared up!", m)
  .start_running
  .wait_until_done

actors.queue_wait_for_input("Press enter to start moving")
  .queue_move(37.777050, -122.417099, LEG_DURATION, n)
  .queue_move(37.777050, -122.417099, LEG_DURATION, k)
  .queue_move(37.777050, -122.417099, LEG_DURATION, l)
  .start_running
  .wait_until_done
puts "Leg 3 done"

### Arrival leg
puts "Arrival leg"
actors.queue_clear_status(n)
  .queue_wait_for_input("Anna post a status then press enter: It's starting, guys!!") # .queue_set_status("It's starting, guys!!", a)
  .start_running
  .wait_until_done

actors.queue_wait_for_input("Press enter to start moving")
  .queue_move(37.777050, -122.417099, LEG_DURATION, m)
  .queue_move(37.777050, -122.417099, LEG_DURATION, n)
  .start_running
  .wait_until_done

actors.queue_set_status("Let's do this :-)!", a)
  .start_running
  .wait_until_done
