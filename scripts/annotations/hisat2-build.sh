#!/bin/sh -login


#SBATCH --time=100:59:59             # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=4                   # number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks-per-node=1         # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=1           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem=60G                   # memory required per allocated CPU (or core) - amount of memory (in bytes)
#SBATCH --job-name hisat2-build             # you can give your job a name for easier identification (same as -J)
#SBATCH --output=job_reports/%x_%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="/mnt/home/rittere5/anaconda3/"

#THIS MAY NEED TO BE CHANGED
sample="dakapowt"

#Set variables
threads="4"

#Change to current directory
cd ${PBS_O_WORKDIR}

#Export paths to conda
export PATH="${conda}/envs/annotations/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/annotations/lib:${LD_LIBRARY_PATH}"

#Set temporary directories for large memory operations
export TMPDIR=$(pwd | sed s/data.*/data/)
export TMP=$(pwd | sed s/data.*/data/)
export TEMP=$(pwd | sed s/data.*/data/)

#The following shouldn't need to be changed, but should set automatically
path1="../${sample}/assembly"

#Run hisat2 build
echo "Running hisat2 build"
hisat2-build ${path1}/*.fa \
-p ${threads} \
${sample}

echo "Done"
