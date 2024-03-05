#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=500GB
#SBATCH --job-name genespace
#SBATCH --output=%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="/mnt/home/rittere5/anaconda3/"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/orthofinder/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/orthofinder/lib:${LD_LIBRARY_PATH}"

module purge
module load GCC/11.2.0 OpenMPI/4.1.1 R/4.3.1

R < /mnt/scratch/rittere5/witchs-broom/results/genespace.R --vanilla

echo "Done"
