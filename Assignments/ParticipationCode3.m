%{
    Name: Lena Kemmelmeier
    Code Buddy: Jenna Pablo
    Date: October 10th, 2024
    Assignment: Participation Code #3
%}

%% Prepare Environment
clear; clc; close all;
rng('shuffle');

commandwindow;
ListenChar(2); % disable keyboard output to matlab command window

%% Set Task Preferences

% task-general preferences
nTrials = 4; % number of trials
experimentEnded = false; % flag to ensure endExperiment() is only called once

% screen preferences
Screen('Preference', 'SkipSyncTests', 1);
windowColor = [128 128 128]; % medium gray
textColor = [256 256 256]; % white
textSize = 24; % font size for formatted text
lineSpacing = 1.2; % adjust spacing between instruction lines

% key preferences
selectedKey = ''; % participant will specify this (key to make responses)
reactionTimes = nan(1, nTrials); % store reaction times for each trial
quitKey = 'q'; % define key to quit the experiment

% timing preferences
numPracticeFlips = 7; % number of practice screen flips before experiment starts
durStartTrialMsg = 0.5; % duration of the start message for each trial
dirKeyMsg = 1; % duration of the "you pressed key __" message
jitter = 0.25 + (1 - 0.25) * rand(1, nTrials); % jitter onset of the second image
responseDur = 2; % maximum amount of time to respond after second image appears

%% Get Stim
stimDir = '/Users/lena/Desktop/PSY 427/fLoc_stimuli'; % path to fLoc folder containing stimuli
stimFiles = dir(fullfile(stimDir, '*.jpg')); % get all image files in folder
stimFileNames = {stimFiles.name}; % return only the names of the files
selectedFaces = pseudoRandomSelect(stimFileNames, 'child', 'adult', nTrials); % get face images

%% Preload Textures
textures = cell(nTrials, 2); % store textures for both images in each trial
imageRects = cell(nTrials, 2); % store destination rects for each image (half-size)

% open window before texture creation
[w, windowRect] = Screen('OpenWindow', 0, windowColor); % smaller window size
[screenX, screenY] = Screen('WindowSize', w); % get screen dimensions

% get inter-frame interval (ifi)
ifi = Screen('GetFlipInterval', w);

% define new image size (half of original size)
newImageWidth = 512;
newImageHeight = 512;

for i = 1:nTrials
    % preload textures for both the first and second images in each trial
    leftImage = imread(fullfile(stimDir, selectedFaces{i, 1}));
    rightImage = imread(fullfile(stimDir, selectedFaces{i, 2}));
    
    % store the textures
    textures{i, 1} = Screen('MakeTexture', w, leftImage);
    textures{i, 2} = Screen('MakeTexture', w, rightImage);
    
    % calculate destination rects for half-size images, centered on the screen
    imageRects{i, 1} = CenterRectOnPointd([0, 0, newImageWidth, newImageHeight], screenX / 2, screenY / 2);
    imageRects{i, 2} = CenterRectOnPointd([0, 0, newImageWidth, newImageHeight], screenX / 2, screenY / 2);
end

%% Run Experiment (Instructions + Trial Loop in one block)
try
    ListenChar(2); % don't print key presses to matlab command window
    HideCursor;

    % preferences for text 
    Screen('FillRect', w, windowColor);
    Screen('TextSize', w, textSize); % set text size
    Screen('Textcolor', w, textColor); % set text color

    for i = 1:numPracticeFlips % these are the practice flips
        Screen('Flip', w); % practice screen flip
        WaitSecs(ifi); % wait for one ifi to sync with display
    end

    %% Show Instruction Window
    instructions = [
        'Welcome to the Detect Change Task.\n\n'...
        'You will first see an image of a face.\n\n' ...
        'Then, the face will change to a new one.\n\n' ...
        'As soon as you see the second face, respond as quickly as you can by pressing the key you select.\n\n' ...
        'You will have a limited amount of time to respond after the second face appears.\n\n'...
        'Let''s get started!\n\n'...
        'First, select the key you will use to respond. The "' quitKey '" key cannot be used to respond.'
    ];

    DrawFormattedText(w, instructions, 'center', 'center', textColor, [], [], [], lineSpacing); % formatted text with spacing
    Screen('Flip', w); % show the instructions

    % start loop waiting for key press
    while true
        checkForQuit(quitKey); % check for the quit key press anytime
        [keyIsDown, ~, keyCode] = KbCheck; % check for key press

        if experimentEnded
            return; % end the script if the experiment was ended during the instructions
        end

        if keyIsDown
            pressedKey = KbName(keyCode); % get the name of the key pressed

            if iscell(pressedKey)
                pressedKey = pressedKey{1}; % take the first key if multiple are pressed
            end

            if strcmpi(pressedKey, quitKey) % if quitKey is pressed, end experiment
                endExperiment();
                return;
            else
                % any key other than quitKey is valid to proceed
                selectedKey = pressedKey; % get valid key
                WaitSecs(0.25); % small buffer before task begins
                break;
            end
        end
    end

    if experimentEnded
        return; % end script if the experiment was ended
    end

    % show window informing the participant of their selected key
    Screen('FillRect', w, windowColor); % gray background
    DrawFormattedText(w, ['You have selected the key: ', selectedKey], 'center', 'center', textColor);
    Screen('Flip', w); % show the selected key
    WaitSecs(dirKeyMsg); % show for 1 second

    %% Loop Over Trials

    for trial = 1:nTrials
        checkForQuit(quitKey); % check for quitKey press
        
        % display "Starting new trial" message
        Screen('FillRect', w, windowColor); % gray background
        DrawFormattedText(w, 'Starting new trial...', 'center', 'center', textColor);
        Screen('Flip', w); % show message
        WaitSecs(durStartTrialMsg);
        checkForQuit(quitKey); % check again for quitKey press during delay

        % display first image (left image) at half size
        Screen('DrawTexture', w, textures{trial, 1}, [], imageRects{trial, 1});
        vbl = Screen('Flip', w); % display first image, store precise flip timestamp

        % insert frequent quit key checks during jitter wait time
        elapsedTime = 0;
        while elapsedTime < jitter(trial)
            checkForQuit(quitKey); % frequent check for quit key press
            elapsedTime = elapsedTime + ifi; % increment elapsed time by ifi
            WaitSecs(ifi); % wait for ifi to keep timing accurate
        end

        % display second image (right image) at half size
        Screen('DrawTexture', w, textures{trial, 2}, [], imageRects{trial, 2});
        trialStartTime = Screen('Flip', w); % get precise flip timestamp when second image appears

        % record reaction time using precise timestamps
        while GetSecs - trialStartTime < responseDur % check if within response duration
            checkForQuit(quitKey); % check for quitKey press
            
            [keyIsDown, reactionEndTime, keyCode] = KbCheck; % check for key press
            if keyIsDown
                reactionKey = KbName(find(keyCode)); % get the key pressed
                if strcmpi(reactionKey, quitKey) % if quitKey is pressed, end experiment
                    endExperiment();
                    return;
                elseif strcmpi(reactionKey, selectedKey) % if selected key is pressed
                    reactionTime = reactionEndTime - trialStartTime; % calculate reaction time
                    reactionTimes(trial) = reactionTime; % save reaction time for this trial
                    break;
                end
            end
        end
    end
    
    %% Show "You completed the task!" screen after all trials
    Screen('FillRect', w, windowColor); % gray background
    DrawFormattedText(w, 'You completed the task!', 'center', screenY / 2 - 50, textColor);
    DrawFormattedText(w, 'Press any key to shut the window.', 'center', screenY / 2 + 50, textColor);
    Screen('Flip', w); % show completion message

    % wait for any key press to close the window
    while true
        checkForQuit(quitKey); % check for quitKey press anytime
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            pressedKey = KbName(find(keyCode)); % get key pressed
            if ~strcmpi(pressedKey, quitKey) % any key other than quitKey ends experiment
                break;
            end
        end
    end

    endExperiment(); % properly end the experiment

catch ME
    if ~experimentEnded
        endExperiment(); % handle errors by ending experiment
    end
    rethrow(ME); % show actual error
end

%% End of Experiment
if ~experimentEnded
    endExperiment(); % call function to close experiment properly
end

%% Save Reaction Times to .mat File
save('reaction_times.mat', 'reactionTimes'); % saves the reactionTimes array in a .mat file

%% Helper functions

% helper function: check for quit key press
function checkForQuit(quitKey)
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && strcmpi(KbName(keyCode), quitKey)
        endExperiment(); % end experiment immediately
        return; % stop further execution
    end
end

% helper function: end the experiment and restore settings
function endExperiment()
    % close the experiment window and restore control
    Screen('CloseAll'); % close the psychtoolbox window
    ShowCursor; % restore the mouse cursor
    ListenChar(0); % restore keyboard control to matlab
    if ~evalin('base', 'experimentEnded') % prevent double display of message
        assignin('base', 'experimentEnded', true); % set flag to avoid printing multiple times
        disp('Experiment ended.'); % print message
    end
end

% helper function: pseudo-randomized selection of unique image file names for each object category
function selectedFileNames = pseudoRandomSelect(imageList, type1, type2, numSets)
    % combine images of both types into one list
    combinedImages = imageList(contains(imageList, type1) | contains(imageList, type2));

    % ensure enough images for requested number of pairs
    if numSets * 2 > length(combinedImages)
        error('Not enough images to form the requested number of pairs.');
    end

    % randomly select images without repetition
    selectedImages = combinedImages(randperm(length(combinedImages), numSets * 2));
    selectedFileNames = reshape(selectedImages, [2, numSets])'; % reshape selected images into pairs
    selectedFileNames = selectedFileNames(randperm(numSets), :); % shuffle the rows
end