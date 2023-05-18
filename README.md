# AON_ACTION 

Analysis scripts for master thesis investigating the human action observation network (AON), using data from two fMRI tasks, as well as self-report measures.

01_setup
To easily re-run my analyses, you can either setup an environment manually with FSL 5.0, Nilearn, Nipype ... or pull my Docker image (i.e., a conteinerized virtual linux environment, in which I already installed all dependencies, including FSL 5.0, as well as many relevant Python packages). Instructions can be found in the Docker folder of the repo, and more general information on https://docs.docker.com/get-started/. Else, you can setup FSL 5.0 on your local computer and use the conda environment "neuroenv.yml". 

02_data_preparation
- dcm2BIDS.ipynb: Using dcm2bids to convert raw dicom data to BIDS format
- descriptives_participantsfile.ipynb: Scale calculations, descriptive stats and code for the creation of a BIDS-style participants.tsv file 
- eventfiles.ipynb: Manually converting the .csv logfiles to BIDS format events.tsv files, and sorting them to the respective folders 
- participants.tsv Dataframe with the descriptive and self-report variables of the participants
- dataset_description.json: BIDS style dataset description
- participants.json: BIDS style description of the variables in the participants.tsv file

03_preprocessing 
- datachecks_pre_preprocessing.ipynb: Code for quick data checks before the preprocessing
- feat_pipeline.sh Bash script to prepare fieldmaps and run preprocessing for all participants and runs
- template.fsf Template file for feat preprocessing, used to generate a FSF file for all participants and runs

04_first_level_model
- AON_first_level_model.ipynb Jupyter notebook with first level model setup using Nilearn for the Action Observation task 
- action_first_level_model.ipynb Jupyter notebook with first level model setup using Nilearn for the Action task 
- flm_helper_functions.py A collections of functions that were used in the first level model setup

05_second_level_model
- second_level_model.ipynb: Second level model code for both the action observation and action execution analysis on a whole brain level

06_masking
- masking.ipynb: Code for the creation of individual mask for each region of interest (ROI)

07_extract_signal
- extract_signal.ipynb: Signal extraction from first level contrasts of the action observation task compared with baseline from the ROIs and creation of a data frame used in subsequent ROI analyses

08_ROI_analysis
- R code for linear mixed effect regressions to investigate main effects and interactions of the different factors

09_plotting
- Code for surface, glass brain and other plots visualizing the fMRI results

10_cluster_info
- cluster_info.ipynb: Code to generate the Supplementary Tables on peak activation coordinates from the whole brain contrasts

Feel free to re-use my code, and if you find any mistakes (and you will find them), or have any questions, please contact me!

Contact: olafborghi@gmail.com