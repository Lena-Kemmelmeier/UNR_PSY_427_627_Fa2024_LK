%{
    Name: Lena Kemmelmeier
    Code Buddy: Jenna Pablo
    Class: PSY 427/627
    Assignment: Code Assignment #2
%}

%% Prepare Environment
clear; clc; close all;
rng('shuffle');

%% Timing parameters - Calculate number of images shown per block
timeImg = 1; % time per image, in seconds
ISI = 0.25; % time between each image, in seconds
timePerBlock = 20; % total time per block, in seconds
timeBwBlock = 3; % time between each block, in seconds
nDiffBlocks = 3; % number of different blocks (types of stimuli)

% calculate the amount of images in each block, considering no ISI after the last image in a block
numImagesPerBlock = floor((timePerBlock + ISI) / (timeImg + ISI)); % round down to nearest whole number

%% Get appropiate images for each block

% path to the fLoc folder containing the stim
stimDir = '/Users/lena/Desktop/PSY 427/fLoc_stimuli'; % path to fLoc folder containing stimuli

% get all image files/image file names in folder
stimFiles = dir(fullfile(stimDir, '*.jpg')); 
stimFileNames = {stimFiles.name}; % return only the names of the files

% personal preference: pseudo-randomly select images for each category using helper function
% e.g. half of face files will be child, half will be adult (do this for each category)
% no single image will be repeated more than once
% each of these selected images will be shown once on the left and once on the right
selectedFaces = pseudoRandomSelect(stimFileNames, 'child', 'adult', numImagesPerBlock);
selectedPlaces = pseudoRandomSelect(stimFileNames, 'house', 'corridor', numImagesPerBlock);
selectedObjects = pseudoRandomSelect(stimFileNames, 'instrument', 'car', numImagesPerBlock);

% combine these images into an array for all blocks
% going off the task schematic on Canvas (i.e. the order will be faces, places, then objects)
firstThreeBlocks = {selectedFaces, selectedPlaces, selectedObjects}; % first 3 blocks

% last three blocks will also be faces, places, then objects (going off Canvas)
% however, I chose to shuffle the order of images w/i each block. this was just my personal preference
shuffledFaces = selectedFaces(randperm(length(selectedFaces)));
shuffledPlaces = selectedPlaces(randperm(length(selectedPlaces)));
shuffledObjects = selectedObjects(randperm(length(selectedObjects)));
lastThreeBlocks = {shuffledFaces, shuffledPlaces, shuffledObjects}; % last 3 blocks

% Combine all blocks into one array
allBlocks = [firstThreeBlocks, lastThreeBlocks]; % the order of all images

%% Display images in blocks

try % safety net - this is fullscreened, but we will close the window if an error is thrown
    
    HideCursor; % hide the mouse

    % open gray screen, get screen coords
    Screen('Preference', 'SkipSyncTests', 1); % skip sync tests
    [window, windowRect] = Screen('OpenWindow', 0, [128 128 128]);
    [screenX, screenY] = Screen('WindowSize', window);

    % get image dimensions
    originalImageWidth = 1024;  % original width of each of these fLoC images, in pixels
    originalImageHeight = 1024; % original height of each of these fLoC images, in pixels

    % scaling image dimensions (half original size)
    imageWidth = originalImageWidth/2;  % scaled width of the image (512)
    imageHeight = originalImageHeight/2; % scaled height of the image (512)

    % determine positions for left and right image presentation - centered within left side of screen/right side of screen
    leftRect = [(screenX / 4) - (imageWidth / 2), (screenY / 2) - (imageHeight / 2), ...
                (screenX / 4) + (imageWidth / 2), (screenY / 2) + (imageHeight / 2)]; 

    rightRect = [(3 * screenX / 4) - (imageWidth / 2), (screenY / 2) - (imageHeight / 2), ...
                 (3 * screenX / 4) + (imageWidth / 2), (screenY / 2) + (imageHeight / 2)]; 


    % - - - presenting the images - - -

    % nested for-loops aren't great on time complexity (I could have done one for-loop for showing on left, then one for showing on right)
    % but we are dealing with a small number of images per block and blocks, so it seems okay for now...
   
    % loop through total number of blocks (num categories times 2 because shown on left, then shown on right)
    for blockIdx = 1:nDiffBlocks * 2

        % get images for this block
        currentBlockImages = allBlocks{blockIdx};

        % determine where image will show: first 3 blocks left, last 3 blocks right
        if blockIdx <= nDiffBlocks
            posRect = leftRect;  % left side
        else
            posRect = rightRect; % right side
        end

        % loop through each image in block
        for imgIdx = 1:numImagesPerBlock

            % load image
            imgPath = fullfile(stimDir, currentBlockImages{imgIdx});
            img = imread(imgPath);
            imgTexture = Screen('MakeTexture', window, img); % make image texture

            % show the image
            Screen('DrawTexture', window, imgTexture, [], posRect);
            Screen('Flip', window);
            WaitSecs(timeImg);

            % if this isn't the last image in the block, there should be an ISI after
            if imgIdx ~= numImagesPerBlock
                Screen('Flip', window); % image should not be showing anymore
                WaitSecs(ISI);
            end
        end

        % time between blocks
        Screen('Flip', window);
        WaitSecs(timeBwBlock);
    end

    % after all six blocks, close window
    Screen('CloseAll');
    ShowCursor; % show the mouse again

    disp('Completed!'); % just something fun

catch ME % if an error is thrown, catch it, close the window, show the message
    Screen('CloseAll');
    ShowCursor; % show the mouse again
    disp('Error occurred:');
    disp(ME.message);
end

%% Helper functions

% Helper function: pseudo-randomized selection of unique image file names for each object category
function selectedFileNames = pseudoRandomSelect(imageList, type1, type2, numImagesPerBlock)

    %{
        Usage: selectedFileNames = pseudoRandomSelect(imageList, type1, type2, numImagesPerBlock)
    
        Inputs
        imageList: cell array of file names from the stimulus directory
        type1: string for the first type of image, used to match the file-naming scheme
        type2: string for the second type of image, used to match the file-naming scheme
        numImagesPerBlock: total number of images to select for each block, this willl be split evenly between type1 and type2
    
        Outputs
        selectedFileNames: horizontal array of randomly selected image file names, half from type1 and half from type2, shuffled into a random order
    %}
    
    % calculate num images per type
    numEachType = numImagesPerBlock/2;
    
    % separate type1 and type2 image names
    type1Images = imageList(contains(imageList, type1));
    type2Images = imageList(contains(imageList, type2));

    % randomly select indices (no repeats) for each type, index the array to get the appropiate file names
    selectedType1 = type1Images(randperm(length(type1Images), numEachType));
    selectedType2 = type2Images(randperm(length(type2Images), numEachType));

    % combine & shuffle image names
    selectedFileNames = [selectedType1, selectedType2]; % concat the two arrs
    selectedFileNames = selectedFileNames(randperm(length(selectedFileNames))); % shuffle order
end