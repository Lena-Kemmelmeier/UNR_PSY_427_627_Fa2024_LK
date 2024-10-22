% Response collection in matlab

%% Variables
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

%% Set up screen
% Skip sync tests for now (sync tests cause issues on Mac OS)
Screen('Preference', 'SkipSyncTests', 1);         
% Open window with default settings:
win = Screen('OpenWindow', screenNumber, screenColor, screenRect);


%% Display instructions
my_str = 'Press any key (will record 10 keypresses)';
textPosition = screenSize / 2; % the middle of the screen
textColor = [255, 255, 255, 255]; % White
%Screen('DrawText', win, my_str, textPosition(1), textPosition(2), textColor);
DrawFormattedText(win, my_str, 'center', 'center');
t0 = Screen('Flip', win);

%%
key_count = 0;
keys_out = {};
key_timing = {};
max_wait = 20;
last_key = '';
%fid = fopen('responses_out_matlab.txt');
while (key_count <= 10) & (GetSecs < t0 + max_wait)
    % Use a while loop
    %FlushEvents;
    [KeyDown RT KeyCode] = KbCheck; %(KB);
    if KeyDown==1
        key_count = key_count + 1;
        key_name = KbName(KeyCode);
        if ~strcmp(key_name, last_key)
            % record keypress
            keys_out{key_count} = key_name;
            key_timing{key_count} = RT-t0;
            % Update what last key was
            last_key = key_name;
            % Wait a hot second
            WaitSecs(.3);
        else
            a = 0; % Do nothing
        end
        %fprint()
    end

end

sca;