#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=500GB
#SBATCH --job-name canu
#SBATCH --output=job_reports/%x-%j.SLURMout

#Set variables
threads=20
sample="dakapowt"
size="500m"

#In general dont change this, unless using a similar datatype
#This should match the dataype in the misc/samples.csv file
datatype="ont"
reads="fastq/${datatype}/clean.fastq.gz"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Path to canu
canu="$HOME/programs/canu-2.2/build/bin/canu"

#Run canu
${canu} \
-p ${sample} \
-d canu \
genomeSize=${size} \
-corrected \
-trimmed \
-nanopore ${reads}

echo "Done"