%{
    Name: Lena Kemmelmeier
    Code Buddy: Jenna Pablo
    Date: October 15th, 2024
    Assignment: Experiment 1 Task Script
%}

%% prepare environment
clear; clc; close all;
rng('shuffle');

commandwindow;
ListenChar(2); % disable keyboard output to matlab command window

%% directories
trialPlanDir = '/Users/lena/Desktop/UNR_PSY_427_627_Fa2024_LK/Assignments/1BackPlan.mat';
outputDir = '/Users/lena/Desktop/UNR_PSY_427_627_Fa2024_LK/Assignments/1BackOutput.mat';

%% load in trial plan
load(trialPlanDir,'trialPlan'); % load in trialPlan array

%% set task preferences and initialize variables
nTrials = height(trialPlan);
keyPressed = ''; % initialize keyPressed as an empty string
responseTime = 0; % initialize responseTime

% preallocate save files
responseLog = cell(nTrials,4); % button, RT, RT since start, block type = 4 columns
timingLog = cell(nTrials,2); % image name + timing = 2 columns

% preallocate other variables
isHitTrial = false; % for use in the trial loop
imageDur = 0; % for storing image duration in each trial
fixColor = [255, 255, 0]; % default fixation color
specialKey = ''; % variable for storing the participant's chosen key

% screen preferences
Screen('Preference', 'SkipSyncTests', 1);
windowColor = [128 128 128]; % medium gray
textColor = [256 256 256]; % white
textSize = 24; % font size for formatted text

% text for instructions screen
instructions1 = 'In this experiment, you will see images of faces, places, bodies, objects, and text, along with scrambled images.';
instructions2 = 'As you watch the images go by, please press a button of your choosing as fast as you can if you see a repeated image.';
instructions3 = 'Press any key to continue.';

% text for keys screen
keyInstruction1 = 'Please choose the key you will use to respond (not q), and use that key for the rest of the experiment.';
keyInstruction2 = 'Once you press your chosen key, the experiment will start.';
keyInstruction3 = 'Press your chosen key to continue.';

% text for end screen
end1 = 'Thank you for participating! You have finished the experiment.';
end2 = 'Press any key to end.';

% quit key settings
quitKey = KbName('q'); % 'q' will be the designated quit key

% fixation dot parameters
fixSize = 15; % size of fixation cross, in pixels
corColor = [0, 255, 0]; % green for correct
faColor = [255, 0, 0]; % red for false alarm
fixFeedbackTime = 2; % display for 2 seconds (may adjust if too long)

% set number of practice flips
nPracticeFlips = 20; % these help with timing, I found this number effective after trial/error

%% experiment

try

    % open window
    [w, windowRect] = Screen('OpenWindow', 0, windowColor);
    [screenX, screenY] = Screen('WindowSize', w); % get screen dimensions
    Screen('Textcolor',w, textColor); % set text color
    Screen('TextSize', w, textSize); % set text size

    Priority(MaxPriority(w)); % raise the screen priority (helps if background processes are running)
    ifi = Screen('GetFlipInterval', w); % get inter-frame interval (ifi), my mac's is 120 Hz or 8.33 ms
    flipAdjustment = ifi * 0.25; % this 0.25 was chosen based on trial/error on a 120 Hz display
    HideCursor;

    % get window coordinates
    centerX = screenX/2; centerY = screenY/2; % vertical and horizontal centers of the screen
    fixRect = CenterRectOnPoint([0 0 fixSize fixSize], centerX, centerY); % rectangle coords for fixation 

    % create the image textures for each image, replace in trial plan array
    for i = 1:nTrials
        img = trialPlan{i,1};
        tex = Screen('MakeTexture', w, img);
        trialPlan{i, 1} = tex;
    end

    % do practice flips to make timing more accurate
    for i = 1:nPracticeFlips
        Screen('Flip',w);
    end
   
    % show the instruction screen
    DrawFormattedText(w,instructions1,'center',centerY-50);
    DrawFormattedText(w,instructions2,'center',centerY);
    DrawFormattedText(w,instructions3,'center',centerY+50);
    firstScreenTime = Screen('Flip',w);
    KbWait; % wait for any key press to move on
    KbReleaseWait; % clear the past keyDown

    % show the screen that lets the participant select their preferred response key
    DrawFormattedText(w,keyInstruction1,'center',centerY-50);
    DrawFormattedText(w,keyInstruction2,'center',centerY);
    DrawFormattedText(w,keyInstruction3,'center',centerY+50);
    timeKeyScreen = Screen('Flip',w);
    
    keyDown = 0;
    % wait for their key press
    while keyDown == 0
        [keyDown, ~, keyCode] = KbCheck;
        if keyDown == 1
            specialKey = find(keyCode);
            if specialKey == quitKey % prevent using the quit key as the special key
                keyDown = 0;
            end
        end
    end

    % buffer before starting trial loop
    WaitSecs(.2 - flipAdjustment); 

% loop over trials
for i = 1:nTrials

    % reset variables at the start of each trial
    keyPressed = ''; 
    responseTime = -4; % default dummy value for no response
    keyDown = 0; % flag for key press (to be safe)
    responseRecorded = 0; % flag to ensure only the first keypress is recorded
    
    isHitTrial = trialPlan{i,4}; % making this a var because it is used more than once
    imageDur = trialPlan{i,2}; % making this a var because it is used more than once
    fixColor = [255, 255, 0]; % default fixation color is yellow

    % draw the image and fixation dot
    Screen('DrawTexture',w,trialPlan{i,1},[]);
    Screen('FillOval',w,fixColor,fixRect);
    timeImageOnset = Screen('Flip', w); % image_onset = first screen per new trial
    
    % check for quit key and exit if pressed
    if checkForQuit(quitKey)
        endExperiment();
        return;
    end

    %{
        with "the time of the response from the onset of the last repeated
        image should be computed and recorded," I interpreted this as being
        *within* a 'hit' (repeat) trial and not also *between* trials; if someone
        missed the window to respond on a hit trial, then I am not
        interpreting their key press in the following trial(s) as being a
        judgement about an earlier trial, for example. my reasoning for this is that it
        would be hard to tell whether this response is actually a
        hit response meant for the previous repeated image, or simply an false
        alarm on the current image. that said, I understand that 500ms
        (the whole time the image is shown) is a very brief window for
        participants.
    %}

    % monitor for keypresses but do not stop the display if a response is recorded
    endTime = timeImageOnset + imageDur - flipAdjustment;
    while GetSecs() < endTime

        % check for quit key and exit if pressed
        if checkForQuit(quitKey)
            endExperiment();
            return;
        end

        % only check for keypresses if a response hasn't been recorded yet
        if ~responseRecorded
            [keyDown, potentialResponseTime, keyCode] = KbCheck;

            % check if a key was pressed and it matches the special key
            if keyDown && keyCode(specialKey)
                keyPressed = KbName(find(keyCode)); % directly get the name of the pressed key
                responseTime = potentialResponseTime; % set actual response time
                responseRecorded = 1; % ensure no further keypresses are recorded
                KbReleaseWait; % ensure key is released before continuing
            end
        end
    end

    % determine the fixation color based on key press and trial type
    if (responseRecorded && isHitTrial) % hit = green
        fixColor = corColor;
    elseif (responseRecorded && ~isHitTrial) % false alarm = red
        fixColor = faColor;
    end
    
    % draw the fixation and display fixation
    Screen('FillOval', w, fixColor, fixRect);
    timeImageOffset = Screen('Flip', w); % image_offset = screen during isi

    % check for quit key and exit if pressed
    if checkForQuit(quitKey)
        endExperiment();
        return;
    end

   %{
        for my attempt at implementing the bonus material, I chose to not make 
        the feedback fixation last 2s or appear when "they have correctly pressed within 
        2s of a repeat." similar to the comment before the response while
        loop, it is hard to tell whether a key response is a delayed hit
        response, or just a false alarm on the current trial. I also did
        not want to make it last 2s because I had a hard time wrapping my
        head around how this would affect appearance on other trials
        (2s spans multiple 1-back trials), especially if there was another hit trial within 2s. 
        to address this concern, I could have put a 2s blank delay screen with just 
        the fixation cross, but I understand that the timing on this task/total time 
        on this task should be fairly set in stone because it is intended for the fmri scanner.
    %}

    % wait for the isi time
    WaitSecs(trialPlan{i,3} - flipAdjustment);

    % add trial info to response log
    if responseRecorded
        responseLog{i,1} = keyPressed; % column 1: which button was pressed;
        responseLog{i,2} = responseTime - timeKeyScreen; % column 2: time of keypress from start of experiment, in seconds
        responseLog{i,3} = responseTime - timeImageOnset; % column 3: time since last repeated image, in seconds
    else
        responseLog{i,1} = NaN; % column 1: which button was pressed; set dummy value
        responseLog{i,2} = NaN; % set dummy value for no response
        responseLog{i,3} = NaN; % set dummy value for no response
    end
    responseLog{i,4} = trialPlan{i,6}; % column 4: block condition

    % add trial info to timing log
    timingLog{i,1} = timeImageOffset - timeImageOnset; % column 1: amount of time this image was shown, in seconds
    timingLog{i,2} = trialPlan{i,5}; % column 2: image file displayed
    
end

    % end screen
    DrawFormattedText(w,end1,'center',centerY-50);
    DrawFormattedText(w,end2,'center',centerY);
    Screen('Flip',w);
    KbWait; % wait for key press to end

    save(fullfile(outputDir),'timingLog','responseLog')
    endExperiment();

catch ME
    endExperiment();
    rethrow(ME); % show actual error
end

%% helper functions
% helper function: check for quit key press
function quitDetected = checkForQuit(quitKey)
    [keyDown, ~, keyCode] = KbCheck;
    quitDetected = keyDown && keyCode(quitKey); % return true if quit key is pressed
end

% helper function: end the experiment and restore settings
function endExperiment()
    sca;
    ShowCursor; % restore the mouse cursor
    ListenChar(0); % restore keyboard control to MATLAB
    Priority(0); % reset any changes made to system priority
end