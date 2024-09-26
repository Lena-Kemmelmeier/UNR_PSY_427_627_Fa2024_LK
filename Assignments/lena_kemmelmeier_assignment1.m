%{
    Name: Lena Kemmelmeier
    Code Buddy: Jenna Pablo
    Class: PSY 427/627
    Assignment: Code Assignment # 1
%}

% tidy up and prepare env
clear; clc; close all;
rng('shuffle');


% 1) create a sorted list of all images in the fLoc folder
stimDir = '/Users/lena/Desktop/PSY 427/fLoc_stimuli'; % path to fLoc folder containing stimuli
stimFiles = dir(fullfile(stimDir, '*.jpg')); % get all .jpg files in the folder, files appear in order they actually are (already sorted)
stimFileNames = {stimFiles.name}; % extract names into a cell arr (again, already in correct order)


% 2) select a random sample of 12 images.
nImgs = 12; % this is the number of images. I am assuming there are >= 12 .jpg files in fLoc, which there are... skipping an additional check
stimInd = randperm(length(stimFileNames), nImgs); % randomly choose stim indices. out of personal preference, I want no duplicates
chosenStim = stimFileNames(stimInd); % index the stim array appropiately


% 3) display each of the 12 randomly chosen images sequentially (in your random order)  * in the same figure * 
% 4a) concatenate the images into an array
% I did not use a matrix array because not all of the images are actually the same size! found this out by chance
figure(1); % create a new figure
imgDuration = 0.5; % show each image for this many seconds

% preallocate cell array for concatenating images of varying sizes - four of the 'scrambled' stim are of different sizes from the rest, so I avoided an array
concatImgs = cell(1, nImgs); % use cell array to handle varying sizes

for i = 1:nImgs
    
    % read image
    imgPath = fullfile(stimDir, chosenStim{i}); % get full path of this image
    img = imread(imgPath); 

    % store image in concatenated arr
    concatImgs{i} = img;

    % display image
    imshow(img);
    pause(imgDuration);

end

close(gcf); % once the last image has been shown for the appropiate duration, close the figure window (for sanity sake)

% 4b) save the concatenated images as one big array
save('/Users/lena/Desktop/PSY 427/randomly_selected_images.mat', 'concatImgs');


% 5) make a figure with subplots to display each of the 12 images in a 4 x 3 'light table" grid
nRows = 4; % number of rows in the grid
nCols = 3; % number of columns in the grid

figure(2); % create a new figure

for i = 1:nImgs

    % create subplot part of the 4x3 grid
    subplot(nRows,nCols,i)

    % read image, take advantage of the already existing concatImgs
    img = concatImgs{i};

    % display image
    imshow(img);

    % display title for each image
    title(chosenStim(i))

end