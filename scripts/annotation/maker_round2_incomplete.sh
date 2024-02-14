#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=200GB
#SBATCH --job-name maker_round2
#SBATCH --output=job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
SR=TRUE #Use short read transcript asemblies?
LR=TRUE #Use long read transcript assemblies?
fasta="../Vvi_Dakapo_without_chr00.fa" #input fasta, if left blank, will look for it in current directory
blast_threads=10 #Leave 1 for MPI

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/maker/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/maker/lib:${LD_LIBRARY_PATH}"
#Export path to agusutus config files
#export ZOE="${conda}/envs/maker" #Need to check
export AUGUSTUS_CONFIG_PATH="${conda}/envs/maker/config/"
#export REPEATMASKER_LIB_DIR=
#export REPEATMASKER_MATRICES_DIR=

#The following shouldn't need to be changed, but should set automatically
path1=$(pwd | sed s/data.*/scripts/)
path2=$(pwd | sed s/data.*/scripts/)
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
genotype=$(pwd | sed s/.*\\/${species}\\/// | sed s/\\/.*//)
sample=$(pwd | sed s/.*${species}\\/${genotype}\\/// | sed s/\\/.*//)
path3="maker_round2"

cd ${path3}

#Set temporary directories for large memory operations
export TMPDIR=$(pwd)
export TMP=$(pwd)
export TEMP=$(pwd)

#Get gff & fasta files
gff3_merge -d Vvi_Dakapo_without_chr00.maker.output/Vvi_Dakapo_without_chr00_master_datastore_index.log
fasta_merge -d Vvi_Dakapo_without_chr00.maker.output/Vvi_Dakapo_without_chr00_master_datastore_index.log

echo "Done"
