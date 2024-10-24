# Run experiment

from psychopy import visual, core, event
import numpy as np
import pathlib
import datetime

def get_response(deadline, disallowedKeys, resp_key):
    max_wait_time = deadline - core.getTime()
    key_out = event.waitKeys(maxWait=max_wait_time, keyList=disallowedKeys + [resp_key], timeStamped=True)
    if key_out is not None:
        print('')
        print(key_out)
        print('')
        if key_out[0][0] in disallowedKeys:
            raise Exception('Manual quit!')
        else:
            pressed, key_time = key_out[0]
            print(f'pressed {pressed}, at {key_time})')
    # Wait for quit key if we've already got a response
    max_wait_time = deadline - core.getTime()
    key_out = event.waitKeys(maxWait=max_wait_time, keyList=disallowedKeys)
    if key_out is not None:
        print('')
        print(key_out)
        print('')
        raise Exception('Manual quit!')


# Parameters
screenFps = 60
ifi = 1 / screenFps
deadlinePct = 0.1 # percent of a screen refresh interval by which 
whileLoopDelta = 0.001 # 1 ms
# to return control in while loops

imageFolder = pathlib.Path('~/Teaching/PSY427_627/datasets/fLoc_stimuli/').expanduser()
subjectNumber = 1
fullScreen = False # false for debugging, True to run
screenSize = [500,500] #[1440, 900] # For mac laptop, may need to change for you! 
imageSize = [500,500]
textColor = [255, 255, 255]
fixationColor = [255, 235, 0] # a nice yellow
fixationSize = 12 # pixels
screenColor = [128,128,128]


# File to save
date = datetime.datetime.now()
datestr = date.strftime('%Y_%m_%d_%H_%M')
sfile = f'subject{subjectNumber:02d}_{datestr}.npz'
# Instructions
instructions_choice = 'Please press the button you want to use to respond'
disallowedKeys = ['escape', 'q']
instructions = '\n'.join([
                'In this experiment, you will see images of',
                'faces, places, bodies, objects, and text,',
                'along with scrambled images.'
                '',
                'As you watch the images go by, please press',
                'the response key as fast as you can if you see',
                'a repeated image.',
                '',
                '(Press any key to continue)'])

if fullScreen:
    screenSize = []
# fixation

# Cerate psychopy object

# Skip sync tests for now (sync tests cause issues on Mac OS)
#Screen('Preference', 'SkipSyncTests', 0)
# Load `trials` variable
trials = np.load(f'subject{subjectNumber:02d}_plan.npy')
nTrials = len(trials)
# preallocate trials
fields = ['keyPressed', 'rt', 'rtAbsolute', 'blockType', 'blockNumber', 'trial', 'deltaTime']
responses = dict((f, []) for f in fields)
# try / catch around opening screen
try:
    # Disable keys in matlab window
    #ListenChar(2)
    # Open window with default settings:
    win = visual.Window(size=screenSize, 
                        color=(0.5,0.5,0.5),
                        fullscr=fullScreen, 
                        units='pix')
    # Choose response key
    button_choice_message = visual.TextStim(win, text=instructions_choice, color=textColor)
    button_choice_message.draw()
    win.flip()
    core.wait(.2)
    resp_key = 'escape'
    while resp_key in disallowedKeys:
        key_out = event.waitKeys(maxWait=20)
        if key_out is None:
            raise ValueError('Timed out waiting for response!')
        if len(key_out) >= 0:
            resp_key = key_out[0]
    button_chosen_message = visual.TextStim(win, text=f'You chose "{resp_key}" - moving on!', color=textColor)
    button_chosen_message.draw()
    win.flip()
    core.wait(1)
    # Draw instructions 
    instruction_message = visual.TextStim(win, text=instructions, color=textColor)
    instruction_message.draw()
    win.flip()
    _ = event.waitKeys(maxWait=20)
    # Set up fixation 
    fixation = visual.Circle(win, radius=fixationSize,
                          units='pix',
                          fillColor=fixationColor,
                          pos=(0,0))
    # Start timing 
    t0 = core.getTime()
    timeFrom = t0
    responses = []
    for itrial, trial in enumerate(trials):
        img_name, onsetTime, offsetTime, isTarget, blockNumber = trial
        image_file = str(imageFolder / img_name)

        # Preallocate responses
        this_response = {}
        this_response['rt'] = np.nan
        this_response['rtAbsolute'] = np.nan
        this_response['trial'] = itrial
        this_response['blockType'] = blockNumber
        # Draw image texture
        img = visual.ImageStim(win, image=image_file, units='pix', size=imageSize)
        img.draw()
        # Draw fixation
        fixation.draw()
        # Use any remaining time before presentation deadline to check for response keys
        deadline = (t0 + float(onsetTime) - deadlinePct * ifi)
        get_response(deadline, disallowedKeys, resp_key)

        flipXX = win.flip()
        flipOnset = core.getTime() # Don't trust flipXX

        # New deadline for image down
        deadline = (t0 + float(offsetTime) - deadlinePct * ifi)
        get_response(deadline, disallowedKeys, resp_key)

        if isTarget:
            timeFrom = flipOnset
        fixation.draw()

        flipXX2 = win.flip()
        flipOffset = core.getTime() # Don't trust flipXX
        print('Image time: %0.04f\n'%(flipOffset-flipOnset))
except:
    win.close()
    core.quit()
    raise


win.close()
core.quit()
