#!/bin/bash --login
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50GB
#SBATCH --job-name split-chr00
#SBATCH --output=%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

path1="/mnt/scratch/rittere5/witchs-broom/scripts/assembly"

echo "Extract all chromosomes except chr00"
bedtools getfasta -fi Vvi_Dakapo_with_chr00.fasta -bed no-chr00.bed > temp1.fasta

echo "Split chr00 up by Ns"
${path1}/split-by-Ns.py < chr00.fasta > chr00_split.fasta

echo "Add chr00 split back"
cat temp1.fasta chr00_split.fasta > temp_Vvi_Dakapo_without_chr00.fasta

echo "Done"
