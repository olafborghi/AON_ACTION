# AON_ACTION (repo currently under construction and private)

Analysis scripts for master thesis investigating the human action observation network (AON), using data from two fMRI tasks, as well as self-report measures.

01_setup
To easily re-run my analyses, you can either setup an environment manually with FSL 5.0, Nilearn, Nipype ... or just pull my Docker image (i.e., a conteinerized virtual linux environment, in which I already installed all dependencies, including FSL 5.0 and SPM12 standalone, as well as all relevant Python packages). Instructions can be found in the Docker folder of the repo, and more general information on https://docs.docker.com/get-started/. Else, you can setup FSL 5.0 on your local computer and use the conda environment "neuroenv.yml". 

02_data_preparation (ready, V1)
- dcm2BIDS.ipynb: Using dcm2bids to convert raw dicom data to BIDS format
- participantsfile.ipynb: Creating a BIDS-style participants.tsv and participants.yaml file containing descriptive statistics and scale scores
- eventfiles.ipynb: Manually converting the .csv logfiles to BIDS format events.tsv files, and sorting them to the respective folders 

03_preprocessing (currently under construction)
- feat_pipeline.sh Bash script to prepare fieldmaps and run preprocessing for all participants and runs
- template.fsf Template file for feat preprocessing, used to generate a FSF file for all participants and runs

Future addons:
- 04_first_level
- 05_group_level_whole_brain
- 06_extract_ROI
- 07_linear_mixed_models_ROI

Yet to do:
- deface the T1 images, so that the data could potentially be shared

Contact: olafborghi@gmail.com



