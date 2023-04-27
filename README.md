# AON_ACTION (repo currently under construction and set as private)

Analysis scripts for master thesis investigating the human action observation network (AON), using data from two fMRI tasks, as well as self-report measures.

01_setup
To easily re-run my analyses, you can either setup an environment manually with FSL 5.0, Nilearn, Nipype ... or just pull my Docker image (i.e., a conteinerized virtual linux environment, in which I already installed all dependencies, including FSL 5.0 and SPM12 standalone, as well as all relevant Python packages). Instructions can be found in the Docker folder of the repo, and more general information on https://docs.docker.com/get-started/. Else, you can setup FSL 5.0 on your local computer and use the conda environment "neuroenv.yml". 

02_data_preparation (ready, V1)
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

06_masking

07_extract_signal

08_linear_mixed_models_ROI

09_plotting

Contact: olafborghi@gmail.com



