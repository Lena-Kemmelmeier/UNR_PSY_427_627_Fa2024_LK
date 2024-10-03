% Variables
screenColor = [128,128,128];
% Below is only relevant for non-full-screen 
screenSize = [400,400];
screenUpperLeft = [200,200];
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
w=Screen('OpenWindow', screenNumber, screenColor, screenRect);

%%


flip_time1 = Screen('Flip', w);
WaitSecs(.002);
flip_time2 = Screen('Flip', w);

time_delta = flip_time2 - flip_time1;
disp(time_delta)