#!/bin/bash --login
#SBATCH --time=3:59:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50GB
#SBATCH --job-name train_snap
#SBATCH --output=job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
maker_dir="../maker_round1" #maker dir with gff & transcripts, not needed if input_gff & transcripts specified
input_gff="../maker_round1/Vvi_Dakapo_without_chr00.all.gff" #input gff file, if left blank will look in maker_dir
fasta= "../Vvi_Dakapo_without_chr00.fa" #input fasta, if left blank, will look for it in current directory

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/maker/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/maker/lib:${LD_LIBRARY_PATH}"

#The following shouldn't need to be changed, but should set automatically
path1=$(pwd | sed s/data.*/misc/)
path2=$(pwd | sed s/data.*/scripts/)
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
genotype=$(pwd | sed s/.*\\/${species}\\/// | sed s/\\/.*//)
sample=$(pwd | sed s/.*${species}\\/${genotype}\\/// | sed s/\\/.*//)
path3="snap_training"

#Make & cd to directory
if [ -d ${path3} ]
then
	cd ${path3}
else
	mkdir ${path3}
	cd ${path3}
fi

#Set some more inputs
if [ -z ${input_gff} ]
then
	input_gff="${maker_dir}/${fasta/.f*/}.all.gff"
fi

#Run maker2zff
echo "Running maker2zff"
maker2zff -x 0.1 ${input_gff}

#Run fathom
echo "Running fathom"
fathom \
	genome.ann \
	genome.dna \
	-categorize 1000

#Run fathom again
fathom \
	-export 1000 \
	-plus \
	uni.ann \
	uni.dna

#Run forge
echo "Running forge"
mkdir forge
cd forge
forge ../export.ann ../export.dna
cd ..

#Run hmm-assembler
echo "Running hmm-assembler.pl"
hmm-assembler.pl \
	${fasta/.f*/}_snap \
	forge/ > SNAP.hmm

echo "Done"