# AON_ACTION (repo currently under construction and private)

Analysis scripts for master thesis investigating the human action observation network (AON), using data from two fMRI tasks, as well as self-report measures.

Finished:
- 01_dcm2BIDS.ipynb: Using dcm2bids to convert raw dicom data to BIDS format
- 02_participantsfile.ipynb: Creating a BIDS-style participants.tsv and participants.yaml file containing descriptive statistics and scale scores
- 03_eventfiles.ipynb: Manually converting the .csv logfiles to BIDS format events.tsv files, and sorting them to the respective folders 

Currently under construction:
- 04_preprocessing.ipynb: Preprocessing workflow using FSL 5.0 accessed via Nipype

Future addons:
- 05_first_level
- 06_extract_fROI
- 07_group_level_whole_brain
- 08_linear_mixed_models_ROI



