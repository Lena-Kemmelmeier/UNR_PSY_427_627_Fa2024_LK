# Response collection in matlab

import psychopy
import numpy as np
from psychopy import core, event, visual

#%% Variables
ifi = 1/60
# Create a full screen window
screen_size = [800,600]
win = visual.Window(size=screen_size, 
                    color=(0.5,0.5,0.5),
                    fullscr=False, 
                    units='pix')

#%%# Display instructions
my_str = 'Press any key (will record 10 keypresses)';
message = visual.TextStim(win, text=my_str)
# Drawtrext
message.draw()
win.flip()
t0 = core.getTime()

##
key_count = 0;
keys_out = [];
key_timing = [];
max_wait = 20;
output_file = 'responses_out.txt'
fid = open(output_file, mode='w')
while (key_count < 10) & (core.getTime() < (t0 + max_wait)):
    # Use a while loop
    key_out = event.getKeys(timeStamped=True)
    if len(key_out) > 0:
        key_pressed = key_out[0]
        key_name, key_time = key_pressed
        key_count = key_count + 1;
        keys_out.append(key_name)
        key_time = key_time - t0
        key_timing.append(key_time)
        # Save something incrementally 
        fid.write("%s,%0.3f"%(key_name, key_time))

# Save something 
#np.save(some_file, key_timing=key_timing, keys_out=keys_out)
fid.close()
win.close()






