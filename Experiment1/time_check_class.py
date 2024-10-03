#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct  1 14:13:30 2024

@author: mark
"""

import psychopy
from psychopy import core
import numpy as np
#%%

# Pseudocode: 
"""   
for repeat in (some number of repeats)
get an initial timestamp
try to wait some specified (short) time
get another timestamp
compute the difference

save that difference in a variable

compute the standard deviation of the time it took
"""
my_clock = psychopy.clock.Clock()
num_repeats = 100
wait_duration = .1
time_list = np.zeros((num_repeats, ))
for repeat in range(num_repeats):
    t1 = my_clock.getTime(); 
    core.wait(wait_duration); 
    t2 = my_clock.getTime()
    delta_t = t2 - t1
    time_list[repeat] = delta_t