#!/bin/bash --login
#SBATCH --time=3:59:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20GB
#SBATCH --job-name liftoff
#SBATCH --output=../job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
target_fa="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/dakapowt/assembly/Vvi_Dakapo_without_chr00.fa" #target genome fasta to map gff files to, if left blank, look in current directory
target_gff="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/dakapowt/assembly/gene_filtering/Vvi_Dakapo_without_chr00.gff" #gff file for target genome, only necessary if gffcompare=TRUE
i="PN40024-v4"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/witchsbroom_py3/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/witchsbroom_py3/lib:${LD_LIBRARY_PATH}"

#Set temporary directories for large memory operations
export TMPDIR=$(pwd | sed s/data.*/data/)
export TMP=$(pwd | sed s/data.*/data/)
export TEMP=$(pwd | sed s/data.*/data/)

#The following shouldn't need to be changed, but should set automatically
path1=$(pwd | sed s/data.*/misc/)
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
genotype=$(pwd | sed s/.*\\/${species}\\/// | sed s/\\/.*//)
sample=$(pwd | sed s/.*\\/${species}\\/${genotype}\\/// | sed s/\\/.*//)
condition="annotation"
datatype="liftoff"
path2=$(pwd | sed s/data.*/data/)
path3="liftoff"

#Look for fasta file, there can only be one!
if [ -z ${target_fa} ]
then
	echo "No input fasta provided, looking for fasta"
	if ls *.fa >/dev/null 2>&1
	then
		fasta=$(ls *fa | sed s/.*\ //)
		echo "Fasta file ${target_fa} found"
	elif ls *.fasta >/dev/null 2>&1
	then
		fasta=$(ls *fasta | sed s/.*\ //)
		echo "Fasta file ${target_fa} found"
	elif ls *.fna >/dev/null 2>&1
	then
		fasta=$(ls *fna | sed s/.*\ //)
		echo "Fasta file ${target_fa} found"
	else
		echo "No fasta file found, please check and restart"
	fi
else
	echo "Input fasta: ${target_fa}"
fi

#Check for and make/cd working directory
if [ -d ${path3} ]
then
	cd ${path3}
else
	mkdir ${path3}
	cd ${path3}
fi


#Liftover & process the annotations

mkdir PN40024_v4
cd PN40024_v4

ref_fa="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/PN40024-v4/PN40024.v4.REF.fasta"
ref_gff="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/PN40024-v4/PN40024.v4.1.REF.gff3"
chroms="${path1}/annotation/PN40024v4_dakapo_chr_mapping.txt"
#ignore_transcripts="${path1}/annotation/${i}_ignore_transcripts.txt"

#Run liftoff
mkdir liftoff
cd liftoff
#Filter the ref_gff
#fgrep -v -f ${ignore_transcripts} ${ref_gff} > ${i}.gff
echo "Lifting over annotations from ${ref_gff} to ${target_fa} with liftoff"
liftoff \
	-cds \
	-polish \
	-o mapped.gff \
	-g ${ref_gff} \
	-chroms ${chroms} \
	${target_fa} \
	${ref_fa}

#Change out of directory
cd ../
mkdir gffcompare

echo "Done"
