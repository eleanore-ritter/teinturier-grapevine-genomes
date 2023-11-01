#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=200GB
#SBATCH --job-name purge_dups
#SBATCH --output=%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
threads=20
datatype="ont"
asm=""

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/purge_haplotigs/bin:$PATH"
export LD_LIBRARY_PATH="${conda}/envs/purge_haplotigs/lib:$LD_LIBRARY_PATH"

#The following shouldn't need to be changed, but should set automatically
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
genotype=$(pwd | sed s/.*\\/${species}\\/// | sed s/\\/.*//)
sample=$(pwd | sed s/.*\\/${genotype}\\/// | sed s/\\/.*//)
assembly=$(pwd | sed s/^.*\\///)
path1=$(pwd | sed s/${sample}.*/${sample}/)
path2="purge_haplotigs"

#Output location
echo "Purging Duplicates for ${species} ${genotype} ${sample} ${assembly}"

#Extract reads from assembly job report
reads="fastq/${datatype}/clean.fastq.gz"

#Change preset based on datatype
if [ ${datatype} = "ont" ]
then
	preset="map-ont"
elif [ ${datatype} = "ont-cor" ]
then
	preset="map-ont"
elif [ ${datatype} = "pac" ]
then
	preset="map-pb"
elif [ ${datatype} = "pac-cor" ]
then
	preset="map-pb"
elif [ ${datatype} = "hifi" ]
then
	preset="map-pb"
else
	echo "Do not recognize ${datatype}"
	echo "Please check and resubmit"
fi

#Look for fasta file, there can only be one!
if [ -z ${asm} ]
then
	echo "No input fasta provided, looking for fasta"
	if ls *.fa >/dev/null 2>&1
	then
		asm=$(ls *fa | sed s/.*\ //)
		echo "Fasta file ${asm} found"
	elif ls *.fasta >/dev/null 2>&1
	then
		asm=$(ls *fasta | sed s/.*\ //)
		echo "Fasta file ${asm} found"
	elif ls *.fna >/dev/null 2>&1
	then
		asm=$(ls *fna | sed s/.*\ //)
		echo "Fasta file ${asm} found"
	else
		echo "No fasta file found, please check and restart"
	fi
else
	echo "Input fasta: ${asm}"
fi

#Create output directory and change directory
if [ -d ${path2} ]
then
	cd ${path2}
else
	mkdir ${path2}
	cd ${path2}
fi

#Align reads to assembly
if [ -s aligned.bam ]
then
	echo "Aligned reads found, proceeding to coverage statistics."
	echo "To repeat this step, delete ${path2}/aligned.bam and resubmit."
else
	echo "Aligning reads to assembly"
	minimap2 \
		-L \
		-t ${threads} \
		-ax ${preset} \
		../${asm} \
		${path1}/${reads} > aligned.sam
	samtools sort aligned.sam > aligned.bam
fi

#Generate read-depth histogram
if [ -s aligned.bam.genecov ]
then
	echo "Aligned reads found, proceeding to read-depth histogram."
	echo "To repeat this step, delete ${path2}/aligned.bam.genecov and resubmit."
else
	echo "Generating read-depth histogram"
	purge_haplotigs hist \
		-bam aligned.bam \
		-genome ../${asm} \
		-threads ${threads}
fi

echo "Done, look at hist and use it for presets to run step 2"
