#!/usr/bin/env bash

set -e    # stop immediately on error
umask u+rw,g+rw,a+rw # give group read/write permissions to all new files

#==========================================
# Edit this part
#==========================================

# General path
basedir=/mnt/d/Research/01_AON_ACTION

# script directory (where this script is stored)
scriptsdir=${basedir}/02_scripts

# directory where data is stored
datadir=${basedir}/01_data

# create folder for fsf files of each sbj
mkdir -p ${basedir}/02_scripts/fsf_dump

# create and set output folder
mkdir -p ${basedir}/output
outputdir=${basedir}/output

#==========================================
# Input options
#==========================================

usage() {
cat <<EOF

Pipeline to to prepare fieldmap and anatomical images and run melodic

usage: wrapper_prep_rest <subjname> 
  <subjid> : a single subject number, or a list of comma-separated numbers
  <runlist>: comma separated list of strings describing the task and/or run number in BIDS format (e.g., AON_run-01 or rest) 
  <tasklist> : comma separated list of tasks
               -prepdata
               -createfsf
               -runfeat
EOF
}

# ============================================
# Housekeeping
# ============================================

# retrieve the subject name(s) from the input arguments; replace commas by spaces
subjlist="${1//,/ }"
runs="${2//,/ }"
tasks=$3

# create task list if set to 'all'
if [[ "$tasks" == *"all"* ]]; 
    then steps=(prepdata,runmelodic)
         tasklist="${steps//,/ }"
    else tasklist="${tasks//,/ }"
fi

# ============================================
# Do the work
# ============================================

echo ""; echo "START: wrapper feat humans"

# start subject loop
for subjid in $subjlist ; do

  if [[ $subjid -lt 10 ]]
    then subj=sub-0$subjid; 
    else subj=sub-$subjid;
  fi

  # assign directories
  subdir=$datadir/$subj
  fmapdir=$subdir/fmap
  anatdir=$subdir/anat
  funcdir=$subdir/func

  # loop over tasks
  for task in $tasklist; do 
    # switch depending on tasks

        case "$task" in

          #----------------------------
          # prepare input for feat
          #----------------------------

          prepdata )

          echo "betting magnitude img, fslprepare fmap"

            echo "human: $subj"

            cd $fmapdir
            echo $fmapdir

            mag=_magnitude1
            phase=_phasediff
            fmap=_fmap_rads

            bet $subj$mag.nii.gz ${subj}${mag}_brain -R -f 0.5
            fsl_prepare_fieldmap SIEMENS $subj$phase.nii.gz ${subj}${mag}_brain $subj$fmap 2.46

            echo "done betting magnitude img, fslprepare fmap"

          ;;

          #----------------------------
          # run individual melodics
          #----------------------------

          createfsf )

            echo ""; echo "START: create fsf"

            for run in $runs; do 

              echo "working on subject: $subj and run: $run"

              # calculate npts (number of time points) 
			        ntime=$(fslnvols $datadir/${subj}/func/${subj}_task-${run}_bold.nii.gz)
			        echo "Number of time points of $subj and task_run $run: $ntime"

              # copy template file to fsf dump folder (can also be the subject folder)
			        cp $scriptsdir/template.fsf $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              echo "$scriptsdir/scriptsdir/template.fsf to $scriptsdir/fsf_dump"
              
              # substitute information
              # outputdir
              sed -i -e "s|OUTPUT_DIR|'"${basedir}/output/${subj}/${run}"'|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # input 4D data dir
              sed -i -e "s|DATA_DIR|'"${datadir}/${subj}/func/${subj}_task-${run}_bold.nii.gz"'|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # number of time points
              sed -i -e "s|NTPTS|$ntime|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # fmap dir (has to be prepped using prepdata)
              sed -i -e "s|FMAP_DIR|'"${datadir}/${subj}/fmap/${subj}_fmap_rads.nii.gz"'|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # mag dir (has to be betted and unbetted file should be in same folder)
              sed -i -e "s|MAG1_DIR|'"${datadir}/${subj}/fmap/${subj}_magnitude1_brain.nii.gz"'|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # anat dir
              sed -i -e "s|ANAT_DIR|'"${datadir}/${subj}/anat/${subj}_T1w.nii.gz"'|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf

              echo "done substituting sbj and run specific information in fsf file for sbj: $subj and run: $run"

            done

          ;;

          #-------------------------------------------------------
          # Run feat for each sbj and run
          #-------------------------------------------------------

          runfeat )

            echo "START: feat preprocessing"

            for run in $runlist; do

              echo "working on subject: $subj and run: $run"
			  
			        mkdir -p $outputdir/$subj/$run
			        echo "created outputdir for subject: $subj and run: $run"
			  
              feat $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
			        echo "done preprocessing run: $run of sbj: $subj"

            done

          ;;

        # end task switching
        esac
        
  # end loop over tasks      
  done

# end subject loop
done


  
