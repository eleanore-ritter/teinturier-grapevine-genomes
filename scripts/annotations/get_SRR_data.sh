#!/bin/bash --login
#SBATCH --time=03:59:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20GB
#SBATCH --job-name fastqdump
#SBATCH --output=%x-%j.SLURMout

#change to working directory
cd $PBS_O_WORKDIR

module load sra-toolkit

$HOME/programs/sratoolkit.3.0.0-centos_linux64/bin/fasterq-dump \
--outdir /mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/rnaseq-annotation/SRR18138591 \
--split-3 SRR18138591

echo "Done"

