# Make a trial order for image presentation 
import numpy as np
import pathlib

# Experiment parameters, stipulated
# Basics
subjectNumber = 1
sname = f'subject{subjectNumber:02d}_plan.npy'
blockRepeats = 2
blockLength = 12 # seconds
imageDuration = 0.5 # seconds
imageISI = 0.1 # inter-stimulus interval, seconds
blockISI = 3 # gap between blocks, seconds
# Block types & sub-categories (categories in alphabetical order)
block_categories = {
    'bodies':['limb','body'],
    'characters':['word','number'],
    'faces':['adult','child'],
    'objects':['car','instrument'],
    'places':['house','corridor'],
    'scrambled':['scrambled']}
block_category_names = sorted(list(block_categories.keys()))
# Image file location (assumes all images are in same folder, as they 
# should be if you downloaded and unzipped fLoc from here: 
# )
imageFolder = pathlib.Path('~/Teaching/PSY427_627/datasets/fLoc_stimuli/')
imageFolder = imageFolder.expanduser()
imageType = 'jpg'

# Experiment parameters, computed
# Explicit computation of these variables will make the code clearer, and
# our life easier, below
imagesPerBlock = blockLength / (imageDuration + imageISI)
if imagesPerBlock % 1: # i.e., if not whole number
    print("block length does not divide evenly into imageDuration + imageISI!")
    # Stop here w/ error
    1/0
else:
    imagesPerBlock = int(imagesPerBlock)
nCategories = len(block_category_names)
nBlocks = nCategories * blockRepeats
nTrials = nBlocks * imagesPerBlock
# Create randomized block order
#block_order = repmat(1:nCategories, 1, blockRepeats)
block_order = np.hstack([range(nCategories)]*2)
# numpy shuffle, shuffles array in place (without mapping to a new variable)
np.random.shuffle(block_order)

# Get possible images for each category
block_images = {}
for category, subcategories in block_categories.items():
    # Get all possible images
    block_images[category] = []
    for subcategory in subcategories:
        # Get images of a particular type, starting with the sub-category string. 
        # This is a python specific one-liner to grab all images as Pathlib paths
        tmp_images = sorted(list(imageFolder.glob(f'{subcategory}*{imageType}')))
        # Add these images to our list of possible images for this category
        block_images[category].extend(tmp_images)

# Create a list to hold trials. 
# {<image to show>, <onset time>, <offset time>, <post image time>>}
trials = [] #cell(nTrials, 5)
current_image_time = 1 # not right away
for blockNumber in block_order:
    # Select n random images from category
    category = block_category_names[blockNumber]
    this_block_images = np.random.choice(block_images[category], imagesPerBlock, replace=False)
    # Select a target, repeat it
    target_idx = np.random.randint(low=1,high=imagesPerBlock)
    this_block_images[target_idx] = this_block_images[target_idx - 1]
    for iimage, trial_image in enumerate(this_block_images):
        # Image, onset, offset, is_target, blockNumber,
        is_target = iimage == target_idx
        this_trial = [trial_image.name,
                      current_image_time,current_image_time + imageDuration,
                      is_target,
                      blockNumber,
                      ]
        trials.append(this_trial)
        # Increment timing
        current_image_time += (imageDuration + imageISI)
    current_image_time += blockISI

np.save(sname, trials)