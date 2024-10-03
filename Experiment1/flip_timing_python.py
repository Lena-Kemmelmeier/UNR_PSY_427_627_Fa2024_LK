# Full screen 

#%%Imports 
import psychopy
from psychopy import visual, core
import glob
import matplotlib.pyplot as plt

#%% Define experiment parameters
info = dict(image_dir='/Users/mark/Teaching/PSY427_627/datasets/fLoc_stimuli/',
)
            
# Here, we will 
conditions = ['adult', 'body', 'corridor']
image_files = {}
for condition in conditions: 
    image_files[condition] = sorted(list(glob.glob(info['image_dir'] + f'*{condition}*')))

block_order = [0, 2, 1] # ...
#%%
fps = 60
ifi = 1/fps
# Timing demo in python 

#%% Set up screen

# Create a full screen window
screen_size = [800,600]
win = visual.Window(size=screen_size, 
                    color=(0.5,0.5,0.5),
                    fullscr=False, 
                    units='pix')
#%%
time_to_wait = 1
f0 = win.flip()
condition = 'adult'
exp_start = win.flip()
exp_clock = psychopy.clock.Clock()
t0 = exp_clock.getTime()
print('t0:', t0)
img = visual.ImageStim(win, image=image_files[condition][0], units='pix', size=(300,300))
t1 = exp_clock.getTime()
print('t1:', t1)
img.draw()
t2 = exp_clock.getTime()
print('t2:', t2)
f1 = win.flip()
t3 = exp_clock.getTime()
print('t3:', t3)
print('f1:',f1)
core.wait(time_to_wait - ifi * .1)
f2 = win.flip()
t4 = exp_clock.getTime()
print('t4:', t4)
print('f2:',f2)
print(t4-t3)
