# AON_ACTION
Analysis scripts for master thesis investigating the human action observation network (AON), using data from two fMRI tasks, as well as self-report measures.

Contact: olafborghi@gmail.com

- 01_dcm2BIDS.ipynb: Using dcm2bids to convert raw dicom data to BIDS format
- 02_participantsfile.ipynb: Creating a BIDS-style participants.tsv and participants.yaml file containing descriptive statistics and scale scores
- 03_eventfiles.ipynb: Manually converting the .csv logfiles to BIDS format events.tsv files, and sorting them to the respective folders 
