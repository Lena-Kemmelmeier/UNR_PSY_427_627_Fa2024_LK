% Response collection in matlab

%% Variables
ifi = 1/60;
method = 'GetChar';  %'KbCheck'; % 
max_wait = 3;
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

%% Set up screen
% Skip sync tests for now (sync tests cause issues on Mac OS)
Screen('Preference', 'SkipSyncTests', 1);         
% Open window with default settings:
win = Screen('OpenWindow', screenNumber, screenColor, screenRect);


%% Display instructions
my_str = 'Press left or right arrow or q!';
textPosition = screenSize / 2; % the middle of the screen
textColor = [255, 255, 255, 255]; % White
Screen('DrawText', win, my_str, textPosition(1), textPosition(2), textColor);
t0 = Screen('Flip', win);


% Exercise: Display something here (a dot, an image), and time responses from there

% Exercise: Create a loop getting responses after each presentation
key_out = '';
if method == 'GetChar'
    key_out = GetChar();
elseif method == 'KbCheck'
    % Use a while loop
    while GetSecs < (t0 + max_wait)
        [KeyDown RT KeyCode] = KbCheck; %(KB);
        if KeyDown==1
            key_out = KbName(KeyCode);
            break
        end
    end
end

if key_out == ''
    disp("timed out!")
else
    fprintf('pressed %s\n', key_out)
end

sca;