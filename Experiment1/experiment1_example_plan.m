% Make a trial order for image presentation 

%% Experiment parameters, stipulated
% Basics
subjectNumber = 1;
sname = sprintf('subject%02d_plan.mat', subjectNumber); 
blockRepeats = 2;
blockLength = 12; % seconds
imageDuration = 0.5; % seconds
imageISI = 0.1; % inter-stimulus interval, seconds
blockISI = 3; % gap between blocks, seconds
% Block types
block_categories = {
    'faces',
    'bodies',
    'places',
    'objects',
    'characters',
    'scrambled'};
% Image types to inclue in each block, in the same order
block_sub_categories = {
    {'adult','child'},
    {'limb','body'},
    {'house','corridor'},
    {'car','instrument'},
    {'word','number'},
    {'scrambled'},
    };
% Image file location (assumes all images are in same folder, as they 
% should be if you downloaded and unzipped fLoc from here: 
% )
imageFolder = '~/Teaching/PSY427_627/datasets/fLoc_stimuli/';
imageFolder = string(py.os.path.expanduser(imageFolder));
imageType = 'jpg';

%% Experiment parameters, computed
% Explicit computation of these variables will make the code clearer, and
% our life easier, below
imagesPerBlock = blockLength / (imageDuration + imageISI);
nCategories = length(block_categories);
nBlocks = nCategories * blockRepeats;
nTrials = nBlocks * imagesPerBlock;
% Create randomized block order
block_order = repmat(1:nCategories, 1, blockRepeats);
% Psychtoolbox randomizaion function, useful: 
block_order = Shuffle(block_order);

% Get possible images for each category
block_images = struct;
for iblock = 1:nCategories
    category = block_categories{iblock};
    % Get all possible images
    possible_images = {};
    for isub_block = 1:length(block_sub_categories{iblock})
        % Get images of a particular type, starting with the
        % sub-category string from `block_sub_categories`
        fstr = [block_sub_categories{iblock}{isub_block} '*' imageType];
        % One-liner, matlab-specific, possibly confusing but common usage. 
        % Embrace it. Let your matlab-fu grow strong. 
        tmp_images = {dir(fullfile(imageFolder, fstr)).name};
        % Add these images to our list of possible images for this category
        possible_images = [possible_images, tmp_images];
    end
    % Use a struct array to hold possible images for each category.
    % Multiple cell arrays would also work for this. 
    block_images.(category) = possible_images;
end

% Create a cell array that is: 
% {<image to show>, <onset time>, <offset time>, <post image time>>}
trials = cell(nTrials, 5);
itrial = 1;
first_image_time = 1; % not right away
current_image_time = first_image_time; % Start here
for iblock = 1:nBlocks
    blockNumber = block_order(iblock);
    % Select n random images from category
    category = block_categories{blockNumber};
    n_available = length(block_images.(category));
    idx = ChooseKFromN(n_available, imagesPerBlock, true);
    % Make sure not strictly ascending (may cause weird bias or predicable
    % sequences)
    idx = Shuffle(idx);
    % Select a target, repeat it
    target_idx = randi([2,imagesPerBlock]);
    idx(target_idx) = idx(target_idx - 1);
    for iimage = 1:imagesPerBlock
        % Image
        trials{itrial, 1} = block_images.(category){idx(iimage)};
        % Onset
        trials{itrial, 2} = current_image_time;
        % Offset
        trials{itrial, 3} = current_image_time + imageDuration;
        % Is Target
        trials{itrial, 4} = iimage == target_idx;
        % Block type (for spot checking)
        trials{itrial, 5} = blockNumber;
        % Increment itrial
        itrial = itrial + 1;
        % Increment timing
        current_image_time = current_image_time + imageDuration + imageISI;
    end
    current_image_time = current_image_time + blockISI;
end

save(sname, 'trials')