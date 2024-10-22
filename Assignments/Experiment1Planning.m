%{
    Name: Lena Kemmelmeier
    Code Buddy: Jenna Pablo
    Date: October 15th, 2024
    Assignment: Experiment 1 Planning
%}

%% prepare environment
clear; clc; close all;
rng('shuffle');

%% directories
outputDir = '/Users/lena/Desktop/UNR_PSY_427_627_Fa2024_LK/Assignments/'; % this is where we will save the trial plan to
stimDir = '/Users/lena/Desktop/PSY 427/fLoc_stimuli'; % this is where we are getting the images from

%% timing/image parameters
timeImg = 0.5; % time per image, in seconds
ISI = 0.1; % time between each image, in seconds
timePerBlock = 12; % total time per block, in seconds
nCategories = 6; % number of different blocks (different types of stimuli)
nBlocks = nCategories * 2; % each block will be repeated twice

% calculate the number of issues in each block
nTrialsPerBlock = floor((timePerBlock) / (timeImg + ISI)); % round down to nearest whole number

%% make trial type array
nHitTrialsPerBlock = 1;
nFATrialsPerBlock = nTrialsPerBlock - nHitTrialsPerBlock;
hitTrials = ones(nHitTrialsPerBlock,1); % hit trials = 1
FAtrials = zeros(nFATrialsPerBlock, 1); % FA (false alarm) trials = 0
trialOrderUnshuffled = vertcat(hitTrials, FAtrials);

trialOrdersEachBlock = cell(nBlocks, 1); % preallocate a cell array

for i = 1:nBlocks
    trialOrdersEachBlock{i, 1} = generateTrialOrder(trialOrderUnshuffled);
end

%% choose images for each block (generalized)
stimFiles = dir(fullfile(stimDir, '*.jpg')); % get all image files in folder
stimFileNames = {stimFiles.name}; % return only the names of the files

% match each category to respective subcategories
categories = {'faces', {'child', 'adult'};
              'places', {'corridor', 'house'};
              'bodies', {'limb', 'body'};
              'objects', {'instrument', 'car'};
              'text', {'word', 'number'}};

% preallocate the cell array with 2 columns
imagesEachBlockUnshuffled = cell(nBlocks, 2); % nBlocks should match the intended 12

% counter for tracking current index in preallocated array
blockIdx = 1;

% select images for each category based on subcategories
for i = 1:length(categories)
    subCat1 = categories{i, 2}{1};
    subCat2 = categories{i, 2}{2};
    
    imagesEachBlockUnshuffled{blockIdx, 1} = pseudoRandomSelect(stimFileNames, subCat1, subCat2, nTrialsPerBlock);
    imagesEachBlockUnshuffled{blockIdx, 2} = categories{i, 1}; % add category label
    blockIdx = blockIdx + 1;
    
    imagesEachBlockUnshuffled{blockIdx, 1} = pseudoRandomSelect(stimFileNames, subCat1, subCat2, nTrialsPerBlock);
    imagesEachBlockUnshuffled{blockIdx, 2} = categories{i, 1}; % add category label
    blockIdx = blockIdx + 1;
end

% for scrambled, there are not subcategories
allScrambledImages = stimFileNames(contains(stimFileNames, 'scrambled'));
scrambled1 = allScrambledImages(randperm(length(allScrambledImages), nTrialsPerBlock))';
scrambled2 = allScrambledImages(randperm(length(allScrambledImages), nTrialsPerBlock))';

% add scrambled images if blockIdx is within bounds
if blockIdx <= nBlocks
    imagesEachBlockUnshuffled{blockIdx, 1} = scrambled1;
    imagesEachBlockUnshuffled{blockIdx, 2} = 'scrambled';
    blockIdx = blockIdx + 1;
end

if blockIdx <= nBlocks
    imagesEachBlockUnshuffled{blockIdx, 1} = scrambled2;
    imagesEachBlockUnshuffled{blockIdx, 2} = 'scrambled';
end

% shuffle the blocks
shuffledOrder = randperm(nBlocks);
imagesEachBlock = imagesEachBlockUnshuffled(shuffledOrder, :);

%% map images to trial sequence and include category label
megaTrialType = zeros(nBlocks * nTrialsPerBlock, 1);
megaStimNames = cell(nBlocks * nTrialsPerBlock, 1);
megaCategory = cell(nBlocks * nTrialsPerBlock, 1);

trialIdx = 1; % index to keep track of overall trial position
for i = 1:nBlocks
    nTrials = nTrialsPerBlock;
    range = trialIdx:(trialIdx + nTrials - 1);
    
    % get the current block information
    currentBlockTrials = trialOrdersEachBlock{i};
    currentImageSet = imagesEachBlock{i, 1};
    currentCategory = imagesEachBlock{i, 2};
    
    % ensure the hit trial matches the prior image
    hitIndex = find(currentBlockTrials == 1);
    currentImageSet(hitIndex) = currentImageSet(hitIndex - 1);
    
    % populate the main arrays
    megaTrialType(range) = currentBlockTrials;
    megaStimNames(range) = currentImageSet;
    megaCategory(range) = repmat({currentCategory}, nTrials, 1);
    
    trialIdx = trialIdx + nTrials; % update index
end

%% resize & create images
% get preferred image dimensions
prefImgWidth = 500;
prefImgHeight = 500;

% preallocate images array
images = cell(nBlocks * nTrialsPerBlock, 1); 

% load in the image for each trial, resize it, store it back to the array
for i = 1:(nBlocks * nTrialsPerBlock)
    imgPath = fullfile(stimDir, megaStimNames{i});
    if ~exist(imgPath, 'file')
        error('image file %s not found.', imgPath); % error checking for missing image files
    end
    img = imread(imgPath);
    img = imresize(img, [prefImgHeight, prefImgWidth]);
    images{i, 1} = img;
end

%% create trialPlan and save it

% preallocate trialPlan array
trialPlan = cell(nBlocks * nTrialsPerBlock, 6); % preallocate trialPlan array

% each row represents a single trial
trialPlan(:,1) = images; % first column: images
trialPlan(:,2) = num2cell(zeros(nBlocks * nTrialsPerBlock, 1) + timeImg); % second column: time per image
trialPlan(:,3) = num2cell(zeros(nBlocks * nTrialsPerBlock, 1) + ISI); % third column: ISI
trialPlan(:,4) = num2cell(megaTrialType); % fourth column: FA or hit trial
trialPlan(:,5) = megaStimNames; % fifth column: filename
trialPlan(:,6) = megaCategory; % sixth column: category label

save(fullfile(outputDir, '1BackPlan.mat'), "trialPlan");
disp('done!')

%% helper functions

% helper function: pseudo-randomized selection of unique image file names for each object category
function selectedFileNames = pseudoRandomSelect(imageList, type1, type2, numImagesPerBlock)
    
    % combine type1 and type2 images
    selectedImages = [imageList(contains(imageList, type1)); imageList(contains(imageList, type2))];
    
    % select and shuffle combined images
    selectedFileNames = selectedImages(randperm(length(selectedImages), numImagesPerBlock))';
end

% helper function: generate a trial order where the first trial is not a hit
function trialOrder = generateTrialOrder(trialOrderUnshuffled)
    trialOrder = trialOrderUnshuffled(randperm(length(trialOrderUnshuffled)));
    while trialOrder(1,1) == 1
        trialOrder = trialOrderUnshuffled(randperm(length(trialOrderUnshuffled)));
    end
end
