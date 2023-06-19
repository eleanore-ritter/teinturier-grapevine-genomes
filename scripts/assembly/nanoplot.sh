#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=200GB
#SBATCH --job-name nanoplot
#SBATCH --output=../../job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
threads="2"
raw="combined-all.fastq.gz"
trimmed="trimmed.fastq.gz"
clean="clean.fastq.gz"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/nanoplot/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/nanoplot/lib:${LD_LIBRARY_PATH}"

#Set temporary directories for large memory operations
export TMPDIR=$(pwd | sed s/data.*/data/)
export TMP=$(pwd | sed s/data.*/data/)
export TEMP=$(pwd | sed s/data.*/data/)

mkdir nanoplot

NanoPlot -t ${threads} \
--fastq ${raw} \
--plots kde hex dot \
-o nanoplot \
-p combined-all

NanoPlot -t ${threads} \
--fastq ${trimmed} \
--plots kde hex dot \
-o nanoplot \
-p trimmed

NanoPlot -t ${threads} \
--fastq ${clean} \
--plots kde hex dot \
-o nanoplot \
-p clean

echo "Done"
