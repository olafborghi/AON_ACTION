How to run the preprocessing pipeline

Folder structure: 
01_data --> containing the subject data sub-01 ...
02_scripts --> containing the template.fsf and feat_pipeline.sh

Change the basedir in the feat_pipeline.sh to the path referring to the folder, in which the folders 01_data and 02_scripts are stored. 

In the terminal, go to the folder 02_scripts.

It may be necessary to use dos2unix to convert the feat_pipeline.sh to true .sh format.

	dos2unix feat_pipeline.sh

It may also be necessary to set the script executable permission

	chmod +x feat_pipeline.sh

If FSL is installed on your system, then you can start the pipeline with the command

	bash feat_pipeline.sh 1,2, action,AON_run-01,AON_run-02, prepdata,createfsf,runfeat

1,2, stands for the subjects that should be preprocessed (i.e., a comma separated list)
action,AON_run-01,AON_run-02, stand for the tasks & runs of the task that should be preprocessed (comma separated list)
prepdata,createfsf,runfeat stands for the jobs that should be performed (i.e., prepdata = bet and prepare fieldmap; 
												 createfsf = create a fsf file for each subject from the template.fsf;
												 runfeat = run preprocessing for chosen subjects)

The betted magnitude1 and anatomical image, as well as the prepared fieldmap, are stored in the same location as the original files and automatically used during preprocessing.
The script then creates a fsf_dump folder in the 02_scripts folder. This is the place, where all the individual fsf files per subject & run are stored.
Finally the script runs FEAT for all chosen subjects & runs, and stores the preprocessed output in /derivatives/sub-XX/run-XX_feat/				
