% Demonstrations of useful psychtoolbox functions to build experiments

%% Set up screen
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

%% Draw text to window
% Position and color for text 
textPosition = screenSize / 2; % the middle of the screen
textColor = [255, 255, 255, 255]; % White
textToShow = 'Hello world!';

Screen('DrawText', w, textToShow, textPosition(1), textPosition(2), textColor);
flip_time = Screen('Flip', w);
WaitSecs(1);

%% Draw a dot
fixColor = [255, 255, 255]; % white
fixSize = 12; % pixels
xCenter = screenSize(1) / 2;
yCenter = screenSize(2) / 2;
FixRect = CenterRectOnPoint([0 0 fixSize fixSize], xCenter, yCenter);
Screen('FillOval',w,fixColor,FixRect);
Screen('Flip', w);

%% Draw an image
imageDir = '/Users/mark/Teaching/PSY427_627/datasets/fLoc_stimuli/';
imageFile = [imageDir, 'instrument-85.jpg'];
image = imread(imageFile);
% Resize! it's too big...
im_small = imresize(image, 0.25);
image_texture = Screen('MakeTexture',w,im_small);
Screen('DrawTexture',w,image_texture);
Screen('Flip', w);



%% Draw a color patch
colorPatch = ones(100,100,3);
color = [255, 127, 0];
for rgb = [1,2,3]
    colorPatch(:,:,rgb) = color(rgb);
end
image_texture = Screen('MakeTexture',w,colorPatch);
Screen('DrawTexture',w,image_texture);
Screen('Flip', w);

%% End of demo, close window:
sca;