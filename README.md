# AON_ACTION 

Analysis scripts for master thesis investigating the human action observation network (AON), using data from two fMRI tasks, as well as self-report measures.

01_setup
To easily re-run my analyses, you can either setup an environment manually with FSL 5.0, Nilearn, Nipype ... or just pull my Docker image (i.e., a conteinerized virtual linux environment, in which I already installed all dependencies, including FSL 5.0 and SPM12 standalone, as well as all relevant Python packages). Instructions can be found in the Docker folder of the repo, and more general information on https://docs.docker.com/get-started/. Else, you can setup FSL 5.0 on your local computer and use the conda environment "neuroenv.yml". 

02_data_preparation
- dcm2BIDS.ipynb: Using dcm2bids to convert raw dicom data to BIDS format
- participantsfile.ipynb: Creating a BIDS-style participants.tsv and participants.yaml file containing descriptive statistics and scale scores
- eventfiles.ipynb: Manually converting the .csv logfiles to BIDS format events.tsv files, and sorting them to the respective folders 

03_preprocessing 
- feat_pipeline.sh Bash script to prepare fieldmaps and run preprocessing for all participants and runs
- template.fsf Template file for feat preprocessing, used to generate a FSF file for all participants and runs

04_first_level_model
- AON_first_level_model.ipynb Jupyter notebook with first level model setup using Nilearn for the Action Observation task 
- action_first_level_model.ipynb Jupyter notebook with first level model setup using Nilearn for the Action task 
- flm_helper_functions.py A collections of functions that were used in the first level model setup

05_second_level_model
- Second level model code for both the action observation and action execution analysis on a whole brain level

06_masking
- Code for the creation of individual mask for each region of interest (ROI)

07_extract_signal
- signal extraction from first level contrasts of the action observation task compared with baseline from the ROIs 
- creation of a data frame used in subsequent analyses

08_linear_mixed_models_ROI
- R code for linear mixed effect regression to investigate main effects and interactions of the different factors

09_plotting
- Code for surface, glass brain and other plots visualizing the fMRI results

Contact: olafborghi@gmail.com



