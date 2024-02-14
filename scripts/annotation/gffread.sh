#!/bin/bash --login
#SBATCH --time=03:59:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50GB
#SBATCH --job-name gffread
#SBATCH --output=../job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
input_gff="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/dakapowt/assembly/annotations/liftoff/final_valid_genes_with_maker_annots.gff"
prefix="VvDak_v1"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/annotations/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/annotations/lib:${LD_LIBRARY_PATH}"

#Automatically set variables
wd=$(pwd)

#Cp gff file with valid lifted annotations and valid maker annotations to current directory
echo "Copying over ${input_gff} to ${wd}"
cp ${input_gff} ${prefix}.gff

#Get transcript fasta file
echo "Creating transcript fasta file"
gffread -w ${prefix}_transcript.fa -g ${prefix}.fa ${prefix}.gff

#Get protein fasta file
echo "Creating protein fasta file"
gffread -y ${prefix}_protein.fa -g ${prefix}.fa ${prefix}.gff

echo "Done"
