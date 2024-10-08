# Functions for event detection in python

# In general, there are two options for response collection. We will be using 
# the older versions, because getting the new ones running is likely to be 
# difficult to do on everyone's system. 

# for reference, see:
# https://psychopy.org/api/event.html   # Older (still fine) version of code
# https://www.psychopy.org/api/hardware/keyboard.html # for newer (psychtoolbox-based) version of code

import psychopy
from psychopy import visual, core, event

#%% Open window

fullscr = False
screen_size = [600,600]
max_wait = 3 
method = 'waitKeys' # 'getKeys'
win = visual.Window(size=screen_size, 
                    color=(0.5,0.5,0.5),
                    fullscr=fullscr, 
                    units='pix',)

#%% Get keypresses in buffer
# Note that your mouse must be over the window in order for keypresses to be collected! 
# Full screen windows will help with this, but are currently buggy on Macs. 

# Display message:
my_str = 'Press left or right arrow or q!'
txt_stim = visual.TextStim(win, text=my_str)
txt_stim.draw()
win.flip()
t0 = core.getTime()

# Exercise: Display something here (a dot, an image), and time responses from there

# Exercise: Create a loop getting responses after each presentation

if method == 'waitKeys':
    key_out = event.waitKeys(maxWait=max_wait, keyList=['left','right','q'])
elif method == 'getKeys':
    # Use a while loop
    while core.getTime() < (t0+max_wait):
        key_out = event.getKeys(keyList=['left','right','q'], timeStamped=True)
        if len(key_out) > 0:
            break

# Exercise: change this to print buttons and reaction times to file!
print('\n\n\n')
if (key_out is not None) and (len(key_out) > 0):
    print(key_out)
else:
    print('Reponse timed out!')
print('\n\n\n')

win.close()
core.quit()

