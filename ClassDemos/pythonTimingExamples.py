# Python tiing functions
import psychopy
from psychopy import core

#%% Get system timestamp
tx = psychopy.clock.getTime()
# Note that this is in WHOLE SECONDS...

#%% Get time with a clock, starting at a time
# Create a clock object
my_clock = psychopy.clock.Clock()
# Get the time! 
t0 = my_clock.getTime()

#%% Wait a specified duration
t1 = my_clock.getTime(); 
core.wait(2); 
t2 = my_clock.getTime()
print(t2-t1)

#%% Wait for a specified interval
wait_seconds = 3
my_clock2 = psychopy.clock.Clock()
t3 = my_clock2.getTime()
my_timer = core.CountdownTimer(wait_seconds)
while my_timer.getTime() > 0:
    # Do something
    pass
t4 = my_clock2.getTime()