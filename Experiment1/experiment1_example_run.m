% Run experiment

% Parameters
screenFps = 60;
ifi = 1 / screenFps;
deadlinePct = 0.2; % percent of a screen refresh interval by which 
whileLoopDelta = 0.001; % 1 ms
% to return control in while loops

imageFolder = '~/Teaching/PSY427_627/datasets/fLoc_stimuli/';
imageFolder = string(py.os.path.expanduser(imageFolder));
subjectNumber = 1;
fullScreen = true; % false for debugging, true to run
imageSize = [500,500];
textColor = [255, 255, 255];
fixationColor = [255, 235, 0]; % a nice yellow
fixationSize = 12; % pixels
screenColor = [128,128,128];
% Choose screen, in case you want to display on another screen (e.g. the 
% projector in an fMRI experiment setup)
screens=Screen('Screens');
% Choosing the display with the highest display number is
% a best guess about where you want the stimulus displayed.
screenNumber=max(screens);
% File to save
date = datetime('now');
date.Format = 'yyyy_MM_dd_hh_mm';
sfile = sprintf('subject%02d_%s', subjectNumber, date);
% Instructions
instructions_choice = 'Please press the button you want to use to respond';
disallowedKeys = {'ESCAPE', 'q'};
instructions = {'Thank you!',...
                '',...
                'In this experiment, you will see images of', ...
                'faces, places, bodies, objects, and text,', ...
                'along with scrambled images.' ...
                '', ...
                'As you watch the images go by, please press', ...
                'the response key as fast as you can if you see', ...
                'a repeated image.', ...
                '',...
                '(Press any key to continue)'};
instructions = strjoin(instructions, '\n');

if fullScreen
    screenRect = [];
    [width_mm, height_mm] = Screen('DisplaySize', screenNumber);
    res = Screen('Resolution', screenNumber);
    screenSize = [res.width, res.height];
else
    screenSize = [800, 600]; % []
    screenUpperLeft = [200,200];
    screenRect = [screenUpperLeft, screenUpperLeft + screenSize];
end
% fixation
xCenter = screenSize(1) / 2;
yCenter = screenSize(2) / 2;
fixationRect = CenterRectOnPoint([0 0 fixationSize fixationSize], xCenter, yCenter);

% Skip sync tests for now (sync tests cause issues on Mac OS)
Screen('Preference', 'SkipSyncTests', 0);
% Load `trials` variable
load(sprintf('subject%02d_plan.mat', subjectNumber));
nTrials = length(trials);
% preallocate trials
fields = {'keyPressed', 'rt', 'rtAbsolute', 'blockType', 'blockNumber', 'trial', 'deltaTime'};
responses = cell2struct(cell(length(fields), nTrials), fields, 1);
% try / catch around opening screen
try
    % Disable keys in matlab window
    ListenChar(2);
    % Open window with default settings:
    win = Screen('OpenWindow', screenNumber, screenColor, screenRect);
    % Choose response key
    DrawFormattedText(win, instructions_choice, 'center','center', textColor);
    Screen('Flip', win);
    FlushEvents; 
    WaitSecs(.5); 
    respKey = 'ESCAPE';
    while any(strcmp(disallowedKeys, respKey))
        [keyTime, keyCode, dTime] = KbWait;
        % Make sure we have one clear keypress
        if sum(keyCode) > 1
            continue
        end
        % Keep key & break loop
        respKey = find(keyCode);
    end

    % Display instructions
    DrawFormattedText(win, instructions, 'center','center', textColor);
    Screen('Flip', win);
    KbWait;
    t0 = GetSecs;
    timeFrom = t0;
    % Loop over trials
    for itrial = 1:length(trials)
        % Load and draw image
        imgFile = fullfile(imageFolder, trials{itrial, 1});
        onsetTime = trials{itrial, 2};
        offsetTime = trials{itrial, 3};
        isTarget = trials{itrial, 4};
        blockNumber = trials{itrial, 5};
        imgOrig = imread(imgFile);
        imgSmall = imresize(imgOrig, [500,500]);
        % Preallocate responses
        responses(itrial).rt = nan;
        responses(itrial).rtAbsolute = nan;
        responses(itrial).trial = itrial;
        responses(itrial).blockType = blockNumber;
        % Draw image texture
        imageTexture = Screen('MakeTexture', win, imgSmall);
        Screen('DrawTexture', win, imageTexture);
        Screen('FillOval', win, fixationColor, fixationRect);    
        % Use any remaining time before presentation deadline to check for
        % response keys
        deadline = (t0 + onsetTime - deadlinePct * ifi);
        while GetSecs < deadline
            [keyDown, rt, keyCode, deltaTime] = KbCheck;
            if keyDown && keyCode(respKey)
                % record response
                responses(itrial).rtAbsolute = rt;
                responses(itrial).rt = rt - timeFrom;
                responses(itrial).deltaTime = deltaTime;
                break
            elseif keyDown && any(keyCode(KbName(disallowedKeys)))
                error("Manual quit!")
            end
            % Allow operating system to do its thing for 1 ms
            WaitSecs(whileLoopDelta);
        end
        % Continue listening for quit keys if response has already been
        % collected
        while GetSecs < deadline
            [keyDown, rt, keyCode, deltaTime] = KbCheck;
            if keyDown && any(keyCode(KbName(disallowedKeys)))
                error("Manual quit!")
            end
            % Allow operating system to do its thing for 1 ms
            WaitSecs(whileLoopDelta);
        end        
        
        flipOnset = Screen('Flip', win, t0 + trials{itrial, 2});
        if isTarget
            timeFrom = flipOnset;
        end
        Screen('FillOval', win, fixationColor, fixationRect);
        % Deadline is `deadlinePct` of a refresh before intnded flip
        deadline = (t0 + offsetTime - deadlinePct * ifi);
        if isnan(responses(itrial).rt)
            while GetSecs < deadline
                [keyDown, rt, keyCode, deltaTime] = KbCheck;
                if keyDown && keyCode(respKey)
                    % record response
                    responses(itrial).rtAbsolute = rt;
                    responses(itrial).rt = rt - timeFrom;
                    responses(itrial).deltaTime = deltaTime;
                    break
                elseif keyDown && any(keyCode(KbName(disallowedKeys)))
                    error("Manual quit!")
                end
                % Allow operating system to do its thing for 1 ms
                WaitSecs(whileLoopDelta);
            end
        else
            while GetSecs < deadline
                [keyDown, rt, keyCode, deltaTime] = KbCheck;
                if keyDown && any(keyCode(KbName(disallowedKeys)))
                    error("Manual quit!")
                end
                % Allow operating system to do its thing for 1 ms
                WaitSecs(whileLoopDelta);
            end
        end
        flipOffset = Screen('Flip', win, t0 + trials{itrial, 3});
        fprintf('Image time: %0.04f\n', flipOffset-flipOnset);
        %disp(sprintf('%0.4f', flipOffset - flipOnset))
    end
catch %ME
    % Close screen
    sca;
    % Enable keystrokes in Matlab window
    ListenChar(0);
    % Close trial file
    %fclose(fid);
    % Display the error we caught
    error(lasterror)
end
% Close screen
sca;
% Enable keystrokes in Matlab window
ListenChar(0);
% Close trial file
%fclose(fid);