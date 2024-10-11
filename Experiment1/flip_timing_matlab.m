%% Timing demo in matlab

%% Define experiment parameters
image_dir = '/Users/mark/Teaching/PSY427_627/datasets/fLoc_stimuli/';
            
conditions = {'adult', 'body', 'corridor'};
block_order = [0, 2, 1]; % ...
fps = 60;
ifi = 1/fps; % inter flip interval, check the device

image_files = {};
for icondition = 1:3
    fstr = fullfile(image_dir, ['*', conditions{icondition}, '*']);
    image_files{icondition} = {dir(fstr).name};
end

%% Set up screen
% Variables
spacebar = KbName('space');
ifi = 1/60;
screenColor = [128,128,128];
% Below is only relevant for non-full-screen 
screenSize = [800,600];
screenUpperLeft = [30,30];
screenRect = [screenUpperLeft, screenUpperLeft + screenSize];
% screenRect = []; % for fullscreen
% Choose screen, in case you want to display on another screen (e.g. the 
% projector in an fMRI experiment setup)
screens=Screen('Screens');
% Choosing the display with the highest display number is
% a best guess about where you want the stimulus displayed.
screenNumber=max(screens);

% Skip sync tests for now (sync tests cause issues on Mac OS)
Screen('Preference', 'SkipSyncTests', 1);         
% Open window with default settings:
win = Screen('OpenWindow', screenNumber, screenColor, screenRect);
%%
t1 = Screen('Flip', win);
time_to_wait = 1;
condition = 'adult';
% WaitSecs(time_to_wait - ifi*.1); % print it out, waiting a little slower for a second, account for the delay

while (GetSecs - t1) < (time_to_wait - ifi*0.1)
    [~,~, keyCode] = KbCheck(); 
    
    while ~keyCode(spacebar)
        [~,~, keyCode] = KbCheck(); 
    end
end


% little deltas will be your friend! :)
t2 = Screen('Flip', win);
fprintf('t diff: %.6f\n', t2-t1); % check accuracy of flips, check flaws in timing

%%

% flip a few times on a blank screen before you actually need it, those
% flips warm up the stifle-back up the system, the other flips will be more
% accurate in timing