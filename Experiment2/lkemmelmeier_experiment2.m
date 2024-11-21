%{
    Course: PSY 427/627
    Assignment: Experiment 2 
    Name: Lena Kemmelmeier
    Code buddy: Jenna Pablo
%}

%% Prepare environment 
clear; clc; close all;
rng('shuffle');
imageFolder = '/Users/Lena/Desktop/PSY 427/fLoc_stimuli/'; % adjust path as needed

%% Get participant ID (GUI)
prompt = {'Subject Number'};           
box = inputdlg(prompt, 'Enter Subject Info');

if isempty(box) || isempty(box{1})
    error('No subject ID entered.'); % need a subID
end

subID = str2double(box{1});

%% Set task preferences

% refresh rate and timing
refreshFPS = 120; % refresh rate (e.g., for mac)
ifi = 1 / refreshFPS; % inter-frame interval
refreshAdjustment = ifi * 0.1; % timing adjustment, this was trial and error for me
whileLoopDelta = 0.001; % 1 ms loop control

% task timing
nTrials = 30; % number of trials in the task, total
imageDur = 0.1; % duration to show images (seconds)
maxTimeResponse = 15; % max response time (seconds)
feedbackDur = 1; % feedback duration (seconds)

% quit key
quitKey = KbName('ESCAPE'); % key to quit the experiment

% fixation preferences
fixColor = [0, 0, 0]; % black fixation cross
fixWidth = 4; % width of fixation lines
fixSize = 25; % size of the fixation cross

% screen preferences
isFullScreen = true; % fullscreen or windowed mode
screenColor = [128, 128, 128]; % background screen color (mid-gray)
textColor = [255, 255, 255]; % text color (white)
nPracticeFlips = 20; % number of practice screen flips

% file saving
date = datetime('now');
date.Format = 'yyyy_MM_dd_hh_mm';
saveOutput = sprintf('subject%02d_%s.mat', subID, date);

% instructions and prompts
sameKeyPrompt = strjoin({
    'Please select the button you will use to respond', ...
    'when the images are of the same category.'
}, '\n');

diffKeyPrompt = strjoin({
    'Please select the button you will use to respond', ...
    'when the images are of different categories.'
}, '\n');

nextPrompt = 'Continue = Press a key.';

endMessage = strjoin({
    'Thank you for completing the task!', ...
    'Continue = Press a key.'
}, '\n');

%% Create the trial plan
trialPlan = makeTrialPlan(imageFolder, nTrials);

%% Preallocate variables
responseFields = {'keyPressed', 'participantResponse', 'rt','absoluteRT', 'accuracy'};
responses = cell2struct(cell(length(responseFields), nTrials), responseFields, 1);

timingFields = {'loadTime', 'drawTime', 'imageTime','fixTime'};
timing= cell2struct(cell(length(timingFields), nTrials), timingFields, 1);

%% Experiment
try
    HideCursor;
    ListenChar(2);
    commandwindow;

    win = setupScreen(1, screenColor); % open the custom screen, 1 = fullscreen, opted to not give option screen dimensions
    [screenWidth, screenHeight] = Screen('WindowSize', win); % get the screen size
    [leftImageRect, rightImageRect] = createRectanglesPairImages(screenWidth, screenHeight, screenHeight/2, screenHeight/2);

    %add practice flips to ensure best timing
    for i = 1:nPracticeFlips
        Screen('Flip', win);
    end

    % prompt participant for same key
    DrawFormattedText(win, sameKeyPrompt, 'center', 'center', textColor);
    Screen('Flip', win);
    [sameKey, sameKeyString] = getKeyChoice(quitKey); % get the chosen same key
    
    % prompt participant for different key
    DrawFormattedText(win, diffKeyPrompt, 'center', 'center', textColor);
    Screen('Flip', win);    
    [diffKey, diffString] = getKeyChoice(quitKey); % get the chosen different key
    
    % check if the same key was chosen for both prompts
    if sameKey == diffKey
        error('The same key cannot be used for both "same" and "different" responses. Please restart the experiment and choose different keys.');
    end
    
    responseKeys = [sameKey, diffKey];

    % full task instructions
    line1 = sprintf('Press the "%s" key when the images are of the SAME TYPE.', sameKeyString);
    line2 = sprintf('Press the "%s" key when the images are of DIFFERENT TYPES.', diffString);
    line3 = 'Press any key to begin the task.';
    taskInstructions = strjoin({line1, line2, line3}, '\n');

    % Display final instructions
    KbReleaseWait; %need otherwise it continues on w/o showing full instruct
    DrawFormattedText(win, taskInstructions, 'center','center', textColor);
    Screen('Flip', win);
    KbWait; %wait for any key to continue

    t0 = GetSecs; % start time of experiment
   
    % load the first image pair!
    startLoad = GetSecs;
    leftImage = imread(string(fullfile(imageFolder, trialPlan{1, 1})));
    rightImage = imread(string(fullfile(imageFolder,trialPlan{1,2})));
    leftTexture = Screen('MakeTexture', win, leftImage);
    rightTexture = Screen('MakeTexture', win, rightImage);
    timing(1).loadTime = GetSecs - startLoad; % get the timing info (first trial)

    for iTrial = 1:nTrials

        startDraw = GetSecs;
        Screen('DrawTexture', win, leftTexture, [], leftImageRect);
        Screen('DrawTexture', win, rightTexture, [], rightImageRect);
        fixColor = [0,0,0]; % start as black
        drawFixation(win, screenWidth, screenHeight, fixColor, fixSize, fixWidth);
        endDraw = GetSecs;
        onsetImage = Screen('Flip', win);

        imageDown = false; %reset offsetImage timing

        % participants have 15 seconds max to respond
        while GetSecs < (onsetImage + (maxTimeResponse-refreshAdjustment)) 
            currTime = GetSecs;

            % take off image after image_duration expires
            if currTime >= (onsetImage + (imageDur-refreshAdjustment)) && ~imageDown
                drawFixation(win, screenWidth, screenHeight, fixColor, fixSize, fixWidth);
                offsetImage = Screen('Flip', win);
                imageDown = true;
            end
            
            % collect response with custom function 
            [keyLogged,key, rt] = getResponse(responseKeys,quitKey);
            if keyLogged 
                responses(iTrial).keyPressed = key; % get name of key press

                % did they make a same/different/no response?
                if strcmp(key, sameKeyString)
                    responses(iTrial).participantResponse = 'same';
                elseif strcmp(key,diffString) 
                    responses(iTrial).participantResponse = 'different';
                else %if no response
                    responses(iTrial).participantResponse = [];
                end

                responses(iTrial).rt = rt-onsetImage; % RT from onsetImage
                responses(iTrial).absoluteRT = rt- t0; % Rt from beginning of experiment
            end
 
            %break the while if a key press is logged & the images were
            %shown for full duration
            if keyLogged && currTime >= (onsetImage + imageDur)
                break;
            end

            WaitSecs(whileLoopDelta);
        end

        % determine the fixation feedback 
        isSameTrial = trialPlan{iTrial, 3}; 

        % was the partiicpant correct?
        if isSameTrial == 1 && strcmp((responses(iTrial).participantResponse),'same') || isSameTrial == 0 && strcmp((responses(iTrial).participantResponse),'different')
            responses(iTrial).accuracy = 'correct';
            fixColor = [0, 255, 0]; %green
        else
            responses(iTrial).accuracy = 'incorrect';
            fixColor = [255, 0, 0]; %red
        end
        
        % show fixation with feedback
        drawFixation(win, screenWidth, screenHeight, fixColor, fixSize, fixWidth);
        onsetFix = Screen('Flip', win);

        % wait fixation time, check for quit key; load images for nxt trial
        keyLogged = false;
        loaded = false;
        while GetSecs < (onsetFix + (feedbackDur-refreshAdjustment))
            checkForQuit(quitKey)

            % prep for nect trial!
            if iTrial < nTrials && ~loaded
                startLoad = GetSecs;
                leftImage = imread(string(fullfile(imageFolder, trialPlan{iTrial+1, 1})));
                rightImage = imread(string(fullfile(imageFolder,trialPlan{iTrial+1,2})));
                leftTexture = Screen('MakeTexture', win, leftImage);
                rightTexture = Screen('MakeTexture', win, rightImage);
                endLoad = GetSecs;
                loaded = true;
            end

            WaitSecs(whileLoopDelta);
        end

        if iTrial < nTrials

            % prompt participant to select any keep to move on
            DrawFormattedText(win, nextPrompt, 'center','center', textColor);
            offsetFix = Screen('Flip', win);
            KbWait;

            timing(iTrial+1).loadTime = endLoad - startLoad;
        end
        
        % store timing things
        timing(iTrial).drawTime = endDraw - startDraw;
        timing(iTrial).imageTime = offsetImage - onsetImage;
        timing(iTrial).fixTime = offsetFix - onsetFix;
    end
    
    % end of study screen
    KbReleaseWait;
    DrawFormattedText(win, endMessage, 'center','center', textColor);
    end_time = Screen('Flip', win); 
    KbWait;

catch ME
    save(saveOutput,'responses','timing');
    endExperiment();
    rethrow(ME);

end

endExperiment();
save(saveOutput,'responses','timing'); % save responses and timing variables!

%% Helper functions

function trialPlan = makeTrialPlan(imageFolder, nTrials)
    % create a trial plan for an experiment
    % generates a randomized sequence of trials where some trials involve
    % images from the same sub-category, and the other half involve images from
    % different categories.
    %
    % inputs:
    % imageFolder: file path containing the stimuli
    % nTrials: number of trials in the task (default = 30)
    %
    % outputs:
    % trialPlan: cell array with trial details (image1, image2, isSame - 1 is yes, 0 is no)
    
    if ~exist('nTrials', 'var') || isempty(nTrials)
        nTrials = 30; 
    end

    probIsSame = 0.5; % half of the pairs will be from the same sub-category
    numSameTrials = floor(nTrials * probIsSame); % trials with same sub-category pairs
    numDiffTrials = nTrials - numSameTrials; % trials with different category pairs

    blockCategories = {'faces','bodies','places','objects','characters','scrambled'};
    blockSubCategories = {{'adult', 'child'},{'limb', 'body'},{'house', 'corridor'},{'car', 'instrument'},{'word', 'number'},{'scrambled'}};
    imageType = 'jpg';

    % create block images using the helper function
    blockImages = struct;
    for iCategory = 1:length(blockCategories)
        category = blockCategories{iCategory};
        subCategories = blockSubCategories{iCategory};
        for iSub = 1:length(subCategories)
            subCategory = subCategories{iSub};
            blockImages.(category).(subCategory) = getImagesMatchingPattern(imageFolder, [subCategory '*' imageType]);
        end
    end

    % initialize trial plan
    trialPlan = cell(nTrials, 3); % columns: {image1, image2, isSame}
    trialOrder = [ones(1, numSameTrials), zeros(1, numDiffTrials)];
    trialOrder = trialOrder(randperm(length(trialOrder))); % add Shuffle back here

    % generate trials
    for iTrial = 1:nTrials
        isSame = trialOrder(iTrial);
        trialPlan{iTrial, 3} = isSame;

        if isSame % same trial: select two images from the same sub-category
            
            categoryIndex = randi(length(blockCategories));
            category = blockCategories{categoryIndex};
            subCategoryIndex = randi(length(blockSubCategories{categoryIndex}));
            subCategory = blockSubCategories{categoryIndex}{subCategoryIndex};
            images = blockImages.(category).(subCategory);

            if length(images) < 2
                error('not enough images in sub-category: %s', subCategory);
            end

            imageIndices = Shuffle(1:length(images));
            trialPlan{iTrial, 1} = images{imageIndices(1)};
            trialPlan{iTrial, 2} = images{imageIndices(2)};
        else % different trial: select images from different categories

            categoryIndex1 = randi(length(blockCategories));
            categoryIndex2 = randi(length(blockCategories));

            while categoryIndex1 == categoryIndex2 % two categories must be distinct
                categoryIndex2 = randi(length(blockCategories)); % pick a new second category
            end

            category1 = blockCategories{categoryIndex1};
            category2 = blockCategories{categoryIndex2};

            subCategoryIndex1 = randi(length(blockSubCategories{categoryIndex1}));
            subCategoryIndex2 = randi(length(blockSubCategories{categoryIndex2}));

            subCategory1 = blockSubCategories{categoryIndex1}{subCategoryIndex1};
            subCategory2 = blockSubCategories{categoryIndex2}{subCategoryIndex2};

            images1 = blockImages.(category1).(subCategory1);
            images2 = blockImages.(category2).(subCategory2);

            if isempty(images1) || isempty(images2)
                error('not enough images in categories: %s or %s', subCategory1, subCategory2);
            end

            trialPlan{iTrial, 1} = images1{randi(length(images1))};
            trialPlan{iTrial, 2} = images2{randi(length(images2))};
        end
    end
end

function imageList = getImagesMatchingPattern(directory, pattern)
    % retrieve image filenames matching a specific pattern in a directory
    %
    % inputs:
    % directory: string, the folder where images are stored
    % pattern: string, the filename pattern to match (default: '*.jpg')
    %
    % outputs:
    % imageList: cell array of filenames that match the pattern

    % retrieve all image filenames matching the given pattern in the specified directory
    files = dir(fullfile(directory, pattern));
    imageList = {files.name};
end


function win = setupScreen(isFullScreen, screenColor, screenDims)
    % setup a psychtoolbox screen window
    %
    % inputs:
    % isFullScreen: boolean, true for fullscreen mode, false for windowed mode (default: true)
    % screenColor: RGB array, background color of the screen (default: [128, 128, 128], mid-gray)
    % screenDims: [width, height], dimensions of the screen in windowed mode (default: [800, 600] if not fullscreen)
    %
    % outputs:
    % win: the psychtoolbox screen window

    Screen('Preference', 'SkipSyncTests', 1);

    % handle defaults for each argument
    if ~exist('isFullScreen', 'var') || isempty(isFullScreen)
        isFullScreen = true; 
    end

    if ~exist('screenColor', 'var') || isempty(screenColor)
        screenColor = [128, 128, 128];
    end

    if ~exist('screenDims', 'var') || isempty(screenDims)
        if isFullScreen
            screens = Screen('Screens');
            screenNumber = max(screens); 
            res = Screen('Resolution', screenNumber);
            screenDims = [res.width, res.height]; 
        else
            screenDims = [800, 600]; 
        end
    end

    screens = Screen('Screens');
    screenNumber = max(screens);

    if isFullScreen
        screenRect = [];
    else
        screenUpperLeft = [200, 200]; % offset from the upper-left corner
        screenRect = [screenUpperLeft, screenUpperLeft + screenDims];
    end

    win = Screen('OpenWindow', screenNumber, screenColor, screenRect);

end

function [leftImageRect, rightImageRect] = createRectanglesPairImages(screenWidth, screenHeight, newImageWidth, newImageHeight)
    % create rectangles for a pair of images
    %
    % inputs:
    % screenWidth: width of the screen
    % screenHeight: height of the screen
    % newImageWidth: width of each image (default: screenHeight / 2)
    % newImageHeight: height of each image (default: screenHeight / 2)
    %
    % outputs:
    % leftImageRect: rectangle coordinates for the left image
    % rightImageRect: rectangle coordinates for the right image

    if ~exist('newImageWidth', 'var') || isempty(newImageWidth)
        newImageWidth = screenHeight / 2; % default width
    end
    if ~exist('newImageHeight', 'var') || isempty(newImageHeight)
        newImageHeight = screenHeight / 2; % default height
    end

    % make the rectangle for the left image
    leftImageRect = [(screenWidth / 4) - (newImageWidth / 2), (screenHeight / 2) - (newImageHeight / 2), ...
    (screenWidth / 4) + (newImageWidth / 2), (screenHeight / 2) + (newImageHeight / 2)];

    % make the rectangle for the right image
    rightImageRect = [(3 * screenWidth / 4) - (newImageWidth / 2), (screenHeight / 2) - (newImageHeight / 2), ...
    (3 * screenWidth / 4) + (newImageWidth / 2), (screenHeight / 2) + (newImageHeight / 2)];

end


function drawFixation(win, screenWidth, screenHeight, fixColor, fixSize, fixWidth)
    % inputs:
    % win: psychtoolbox screen window
    % screenWidth: width of the screen
    % screenHeight: height of the screen
    % fixColor: RGB array, color of the fixation cross (default: [0, 0, 0], black)
    % fixSize: size of the fixation cross in pixels (default: 25)
    % fixWidth: width of the fixation cross lines in pixels (default: 5)

    if ~exist('fixColor', 'var') || isempty(fixColor)
        fixColor = [0, 0, 0]; % default to black
    end

    if ~exist('fixSize', 'var') || isempty(fixSize)
        fixSize = 25; % default size of the fixation cross
    end
    if ~exist('fixWidth', 'var') || isempty(fixWidth)
        fixWidth = 5; % default line width
    end
    xCenter = screenWidth/2;
    yCenter = screenHeight/2;
    
    Screen('DrawLine', win, fixColor, ...
        xCenter - fixSize, yCenter, ...
        xCenter + fixSize, yCenter, fixWidth);
    
    Screen('DrawLine', win, fixColor, ...
        xCenter, yCenter - fixSize, ...
        xCenter, yCenter + fixSize, fixWidth);
end

function [key, keyString] = getKeyChoice(quitKey)
    % get the participant's key choice for a specific action
    %
    % inputs:
    % quitKey: keycode for the quit key (default: KbName('ESCAPE'))
    %
    % outputs:
    % key: keycode of the chosen key
    % keyString: string representation of the chosen key

    if ~exist('quitKey', 'var') || isempty(quitKey)
        quitKey = KbName('ESCAPE'); % default quit key
    end

    if ~exist('quitKey','var')
        quitKey = KbName('ESCAPE');
    end
    
    KbReleaseWait; %clear the past keyDown
    keyDown = 0;

    while keyDown == 0
        [keyDown, ~, keyCode] = KbCheck;
        if keyDown == 1 && ~keyCode(quitKey)
            key = find(keyCode);
            keyString = KbName(keyCode);
            break;
        else
            keyDown = 0;
        end
    end
end

function [keyLogged, key, rt] = getResponse(responseKeys,quitKey)
    % collect a participant's response during a trial
    %
    % inputs:
    % responseKeys: array of valid response keycodes
    % quitKey: keycode for the quit key
    %
    % outputs:
    % keyLogged: boolean, true if a valid key is logged
    % key: keycode of the logged key
    % rt: response time in seconds

    keyLogged = false;
    if ~keyLogged
        [keyDown, rt, key] = KbCheck;
        if keyDown && any(key(responseKeys))
            key = KbName(key);
            keyLogged = true;
        elseif keyDown && key(quitKey)
            error('Quit!')
        end
    end
end

function checkForQuit(quitKey)
    % check if the participant pressed the quit key
    %
    % inputs:
    % quitKey: keycode for the quit key (default: KbName('ESCAPE'))
    %
    % if quitKey is pressed, the function throws an error to quit the experiment
    
    keyLogged = false;
    
    if ~keyLogged
        [keyDown, ~, keyCode] = KbCheck;
        if keyDown && keyCode(quitKey)
            error('Quit!')
        end
    end
end

function endExperiment()
    % close the screen, restore key press settings when the experiment ends
    sca;
    ShowCursor;
    ListenChar(0);
end