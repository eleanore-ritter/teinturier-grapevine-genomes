#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100GB
#SBATCH --job-name nanostat
#SBATCH --output=%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
threads=10

#Change to current directory
cd ${PBS_O_WORKDIR}

#Export paths to conda
export PATH="${conda}/envs/assembly/bin:$PATH"
export LD_LIBRARY_PATH="${conda}/envs/assembly/lib:$LD_LIBRARY_PATH"

echo "Running NanoStat on raw reads"

NanoStat --fastq combined.fastq.gz -n raw-combined-reads -t ${threads}

echo "Running NanoStat on prepped reads"

NanoStat --fastq clean.fastq.gz -n prepped-clean-reads -t ${threads}

echo "Done"
