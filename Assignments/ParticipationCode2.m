%{
    Name: Lena Kemmelmeier
    Code buddy: Jenna Pablo
    Date: October 1st, 2024
    Assignment: Participation Code #2
%}

%% Testing timing

clc;
clear;

numReps = 1000;
waitTime = .001; 
timing = zeros(numReps, 1);

for i = 1:numReps
    t1 = GetSecs;
    WaitSecs(waitTime);
    t2 = GetSecs;
    
    timing(i,:) = t2 - t1;
end

stdev_time = std(timing);
mean_time = mean(timing);
disp(stdev_time);

%% Testing timing on screen flips

waitTime = .002; 

Screen('Preference', 'SkipSyncTests', 1); % skip sync tests
[w, ~] = Screen('OpenWindow', 0, [128 128 128]);

flip_time1 = Screen('Flip',w);
WaitSecs(waitTime);
flip_time2 = Screen('Flip',w);

flip_time = flip_time2 - flip_time1;

Screen('CloseAll');
disp(flip_time);