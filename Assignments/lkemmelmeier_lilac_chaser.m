%{
    Name: Lena Kemmelmeier
    Code Buddy: Jenna Pablo
    Date: October 29th, 2024
    Assignment: Extra Credit Lilac Chaser
%}

%% prepare environment
clear; clc; close all;
rng('shuffle');

commandwindow;
ListenChar(2);

%% set task preferences and initialize variables

taskDur = 20; % total time in seconds for the lilac chaser
nPracticeFlips = 20;

% blobs (!) preferences
blob.nBlobs = 12; % number of blobs
blob.disappearTime = 0.25; % disappearance duration of each blob, in seconds
blob.color = [255 0 255]; % color of blob, purple
blob.stdev = 30; % controls the blob size
blob.size = 2 * round(3 * blob.stdev) + 1; % calculate blob size

% screen preferences
Screen('Preference', 'SkipSyncTests', 1);
windowPrefs.color = [128 128 128]; % medium gray background


% --- I used ChatGPT for the below code - especially to customize the size/blur ----

% generate gaussian matrix for blob
[x, y] = meshgrid(-blob.size / 2 : blob.size / 2, -blob.size / 2 : blob.size / 2);
GaussianBlob = 0.8 * exp(-(x.^2 + y.^2) / (2 * blob.stdev^2));
GaussianBlob = min(GaussianBlob, 0.8); % cap values at 1 to avoid oversaturation

% create RGBA blob matrix with Gaussian applied as an alpha layer
rgbaBlob = repmat(reshape(windowPrefs.color, 1, 1, 3), blob.size + 1, blob.size + 1);
rgbaBlob(:,:,1) = uint8(blob.color(1) * GaussianBlob + double(windowPrefs.color(1) * (1 - GaussianBlob)));
rgbaBlob(:,:,2) = uint8(double(windowPrefs.color(2) * (1 - GaussianBlob)));
rgbaBlob(:,:,3) = uint8(blob.color(3) * GaussianBlob + double(windowPrefs.color(3) * (1 - GaussianBlob)));

% --- I used ChatGPT for the above code - especially to customize the size/blur ----


% quit key settings
quitKey = KbName('q'); % 'q' will be the designated quit key

% fixation cross parameters
fixPrefs.size = 15; % size of fixation cross, in pixels
fixPrefs.color = [0, 0, 0]; % color for fixation, black
fixPrefs.width = 2; % thickness of fixation cross lines

%% experiment

try
    % open window
    windowPrefs.win = Screen('OpenWindow', 0, windowPrefs.color);
    HideCursor;
    [screenX, screenY] = Screen('WindowSize', windowPrefs.win);

    % make the blob texture
    blob.texture = Screen('MakeTexture', windowPrefs.win, rgbaBlob);

    Priority(MaxPriority(windowPrefs.win)); % maximize screen priority
    ifi = Screen('GetFlipInterval', windowPrefs.win); % get inter-frame interval, my M3 Mac runs at 120 Hz

    % calculate blob positions in a circle
    blob.positions = circlePos(blob.nBlobs, screenX / 4);

    % center coordinates for fixation cross
    windowPrefs.centerX = screenX / 2; 
    windowPrefs.centerY = screenY / 2;

    % do practice flips for timing accuracy
    for i = 1:nPracticeFlips
        Screen('Flip', windowPrefs.win);
    end

    currentBlob = 1; % start with the first blob in each cycle
    startTime = Screen('Flip', windowPrefs.win); % initial flip time

    % main loop
    while GetSecs < startTime + taskDur
        
        % check for quit key press
        if checkForQuit(quitKey)
            endExperiment();
            return;
        end
        
        % draw all blobs except the one that is disappearing
        for j = 1:blob.nBlobs
            if j ~= currentBlob
                Screen('DrawTexture', windowPrefs.win, blob.texture, [], ...
                    CenterRectOnPoint([0 0 blob.size blob.size], ...
                    windowPrefs.centerX + blob.positions(j, 1), ...
                    windowPrefs.centerY + blob.positions(j, 2)));
            end
        end

        % draw fixation cross
        drawFixation(windowPrefs, fixPrefs);

        % flip screen and wait for next frame
        Screen('Flip', windowPrefs.win);

        % increment and reset currentBlob
        currentBlob = currentBlob + 1;
        if currentBlob > blob.nBlobs % if it is the 'last' blob, roll over
            currentBlob = 1;
        end

        % wait the amount of time the blobs should be shown like this for
        WaitSecs(blob.disappearTime - (ifi * 0.25));

    end

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
    ShowCursor;
    ListenChar(0); 
    Priority(0);
end

% helper function to draw the fixation cross
function drawFixation(windowPrefs, fixPrefs)
    % draw the horizontal line
    Screen('DrawLine', windowPrefs.win, fixPrefs.color, ...
    windowPrefs.centerX - fixPrefs.size, windowPrefs.centerY, ...
    windowPrefs.centerX + fixPrefs.size, windowPrefs.centerY, fixPrefs.width);

    % draw the vertical line
    Screen('DrawLine', windowPrefs.win, fixPrefs.color, ...
    windowPrefs.centerX, windowPrefs.centerY - fixPrefs.size, ...
    windowPrefs.centerX, windowPrefs.centerY + fixPrefs.size, fixPrefs.width);
end

% helper function: get coordinates along circle
function circlePoints = circlePos(nPositions, radius)
    theta = linspace(0, 2 * pi, nPositions + 1); 
    theta(end) = [];

    [x, y] = pol2cart(theta, radius);

    circlePoints = [x', y'];
end