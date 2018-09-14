#!/bin/bash

#***************************************************************#
#               runs fastqc on gzipped raw data files           #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=fastqc
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=4gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mark.farrell@csiro.au
#SBATCH --output=Logs/fastqc_%A.out
#SBATCH --array=0-11

#----------------------project variables------------------------# 
IN_DIR=/flush1/far218/projectdir/data/raw/
OUT_DIR=/flush1/far218/projectdir/data/FastQC/

#---------------------------------------------------------------#

mkdir -p $OUT_DIR
module load fastqc

IN_FILE_LIST=( $(ls ${IN_DIR}/*.fastq) );

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
        i=$SLURM_ARRAY_TASK_ID
        IN_FILE=${IN_FILE_LIST[$i]}
        fastqc ${IN_FILE} --noextract -o ${OUT_DIR}
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi

