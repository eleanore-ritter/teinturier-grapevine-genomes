#!/bin/bash
#
#SBATCH --job-name=ArrayFastqDump
#SBATCH --mem=15G
#SBATCH --time=03:59:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --array=1-8%8

#the percent 4 is just to say how many of the lines (subjobs) you want to run at once

#each line of the .txt file contains both paired ends separated by a single space


#change to working directory
cd $PBS_O_WORKDIR

module load sra-toolkit

LINE=$(sed -n "$SLURM_ARRAY_TASK_ID"p sra-list-2.txt)

$HOME/programs/sratoolkit.3.0.0-centos_linux64/bin/fasterq-dump \
--outdir /mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/rnaseq-annotation/${LINE} \
--split-3 ${LINE}
....

