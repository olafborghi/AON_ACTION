####  First level model helper functions

# load libraries / modules

import os
import numpy as np
import nibabel as nib
import pandas as pd

# create a function to load the MRI images with NiBabel (nib) for each sbj in a dict
def MyMRIImages(paths):
    ''' 
    Returns a dictionary with the functional or anatomical MRI images of each subject
    loaded as a nib.img
    Inputs: A list of paths to the functional/anatomical images, ordered by subject number
    '''
    images_dict = {}
    for i, p in enumerate(paths):
        img = nib.load(p)
        if i+1 < 10: 
            images_dict[f"sub-0{i+1}"] = img
        elif i+1 >= 10:
            images_dict[f"sub-{i+1}"] = img
    return images_dict


# create a function to load the motion parameters as pandas dataframes
def MyMotionParameters(par_paths, fd_paths):
    ''' 
    Returns a dictionary with the motion parameters and motion scrubbing of each subject for a task/run
    loaded as a pandas dataframe.
    Inputs: A list of paths to the motion parameters
    Output: dict with pandas dataframe of confounds for each subject
            and prints the percentage of volumes lost by framewise displacement > 0.9
    '''
    pars_dict = {}
    for j, f in enumerate(fd_paths):
        
        # load the framewise displacement parameters of the sbj
        fd=np.loadtxt(f) 
        fd = pd.DataFrame(fd)
        fd.columns=["FD"]
        fd = (fd > 0.9)*1 # replace values < 0.9 with 0, and those > 0.9 with 1
        print(f"Percentage of volums with fd > 0.9 of subject {j+1} = ", np.sum(fd)*100/len(fd))
        
        # load the motion parameters of the sbj as txt
        par = np.loadtxt(par_paths[j])
        # create a pd.DataFrame with column names of the motion parameters
        par = pd.DataFrame(par)
        par.columns =['x', 'y', 'z', 'pitch', 'roll', 'yaw']
        par = pd.concat((par,fd), axis = 1)
        
        if j+1 < 10: 
            pars_dict[f"sub-0{j+1}"] = par
        elif j+1 >= 10:
            pars_dict[f"sub-{j+1}"] = par
    return pars_dict

# create a function to load the motion parameters as pandas dataframes
def MyEventFiles(paths):
    ''' 
    Returns a dictionary with the event files of each subject for a task/run
    loaded as a pandas dataframe.
    Inputs: A list of paths to the motion parameters
    '''
    events_dict = {}
    for i, p in enumerate(paths):
        # load events.tsv files
        events = pd.read_table(p)
        if i+1 < 10: 
            events_dict[f"sub-0{i+1}"] = events
        elif i+1 >= 10:
            events_dict[f"sub-{i+1}"] = events
    return events_dict


def pad_vector(contrast_, n_columns):
    """A small routine to append zeros in contrast vectors"""
    return np.hstack((contrast_, np.zeros(n_columns - len(contrast_))))