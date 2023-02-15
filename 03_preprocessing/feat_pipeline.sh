#!/usr/bin/env bash

set -e    # stop immediately on error
umask u+rw,g+rw,a+rw # give group read/write permissions to all new files

#==========================================
# Edit this part
#==========================================

# General path
# basedir=/mnt/c/Users/HP/Documents/03_AON_ACTION # local
basedir="/home/olafb99/mnt/p/userdata/olafb99/shared/03_AON_ACTION" # server

# script directory (where this script is stored)
scriptsdir="${basedir}/02_scripts"

# directory where data is stored
datadir="${basedir}/01_data"

# create folder for fsf files of each sbj
mkdir -p "${basedir}/02_scripts/fsf_dump"

# create and set output folder
mkdir -p "${basedir}/derivatives"
outputdir="${basedir}/derivatives"

#==========================================
# Input options
#==========================================

usage() {
cat <<EOF

Pipeline to to prepare fieldmap and anatomical images, create fsf files, run feat, and calculate framewise displacement

usage: wrapper_fsl_fmri <subjname> 
  <subjid> : a single subject number, or a list of comma-separated numbers
  <runs>: comma separated list of strings describing the task and/or run number in BIDS format (e.g., AON_run-01 or rest) 
  <tasklist> : comma separated list of tasks
               -prepdata
               -createfsf
               -runfeat
               -motion
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
    then steps=(prepdata,createfsf,runfeat,motion)
         tasklist="${steps//,/ }"
    else tasklist="${tasks//,/ }"
fi

# ============================================
# Do the work
# ============================================

echo ""; echo "START: wrapper FSL bet / preparefieldmap / feat / motion_outliers humans"

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

            echo "done betting & preparing fieldmap"

            # anat has to be betted before running feat!
            cd $anatdir
            echo $anatdir

            anat=_T1w

            bet $subj$anat.nii.gz ${subj}${anat}_brain.nii.gz -B -f 0.2 -m

            echo "done betting anat image"

          ;;

          #-----------------------------------
          # create fsf files for preprocessing
          #-----------------------------------

          createfsf )

            echo ""; echo "START: create fsf"

            for run in $runs; do 

              echo "working on subject: $subj and run: $run"

              # calculate npts (number of time points) 
			        ntime=$(fslnvols $datadir/${subj}/func/${subj}_task-${run}_bold.nii.gz)
			        echo "Number of time points of $subj and task_run $run: $ntime"

              # copy template file to fsf dump folder (can also be the subject folder)
			        cp $scriptsdir/template.fsf $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              echo "$scriptsdir/scriptsdir/template.fsf to $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf"
              
              # substitute information
              # outputdir
              sed -i -e "s|OUTPUT_DIR|"\"${outputdir}/${subj}/${run}\""|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # number of time points
              sed -i -e "s|NTPTS|$ntime|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # input 4D data dir
              sed -i -e "s|DATA_DIR|"\"${funcdir}/${subj}_task-${run}_bold\""|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # fmap dir (has to be prepped using prepdata)
              sed -i -e "s|FMAP_DIR|"\"${fmapdir}/${subj}_fmap_rads\""|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # mag dir (has to be betted and unbetted file should be in same folder)
              sed -i -e "s|MAG1_DIR|"\"${fmapdir}/${subj}_magnitude1_brain\""|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              # anat dir
              sed -i -e "s|ANAT_DIR|"\"${anatdir}/${subj}_T1w_brain\""|g" $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf

              echo "done substituting sbj and run specific information in fsf file for sbj: $subj and run: $run"

            done

          ;;

          #-------------------------------------------------------
          # Run feat for each sbj and run
          #-------------------------------------------------------

          runfeat )

            echo "START: feat preprocessing"

            for run in $runs; do

              echo "working on subject: $subj and run: $run"
              feat $scriptsdir/fsf_dump/feat_${subj}_${run}.fsf
              echo "done preprocessing run: $run of sbj: $subj"

            done

          ;;

          #---------------------------------------------------------------------------------
          # Run fsl_motion_outliers to calculate framewise displacement for each sbj and run
          #---------------------------------------------------------------------------------

          motion )

            echo "START: Calculating motion outliers"

            echo "Creating an output html file where motion information will be assembled"
            outhtml="${outputdir}/bold_motion.html"

            for run in $runs; do 
              
              echo "Creating motion directory for $subj and $run"
              mkdir -p "${outputdir}/${subj}/${run}.feat/motion_assess"
              motiondir="${outputdir}/${subj}/${run}.feat/motion_assess"

              echo "start fsl_motion_outliers for $subj and $run"
              fsl_motion_outliers -i "${funcdir}/${subj}_task-${run}_bold" -o "${motiondir}/output.txt" --fd --thresh=0.9 -s "${motiondir}/confound.txt" -p "${motiondir}/fd_plot" -v >> "$outhtml"         
              echo "done calculating fsl_motion_outliers for $subj and $run"

              echo "Putting the fd plot into the outhtml file"
              fdplot="${motiondir}/fd_plot.png"
              echo "
              <html>
                <head>
                  <title>FD plot of $subj and $run</title>
                  </head>
                  <body>
                <h1>FD Plot of $subj and $run</h1>
                <img src="${fdplot}" width='100%'>
                </body>
              </html>" >> $outhtml

              # echo "Place empty file in motiondir if no fd is larger than threshold of .9 for a subj"
              # confoundfile="${motiondir}/confound.txt"
              # if test -f "$confoundfile"; then
              #     echo "$FILE exists. Outliers > .9 were detected."
              #   else
              #     echo "No outliers > .9, creating an empty file"
              #     touch "$confoundfile"
              # fi
            
            done
          
          ;;

      # end task switching
      esac
        
  # end loop over tasks      
  done

# end subject loop
done


  
