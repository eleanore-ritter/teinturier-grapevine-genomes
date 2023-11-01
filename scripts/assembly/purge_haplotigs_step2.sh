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

#Set these variables EACH RUN based on hist resulting from step 1
low="15"
mid="88"
high="195"

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

#Change directory
cd ${path2}

#Get coverage stats
if [ -s coverage_stats.csv ]
then
	echo "Aligned reads found, proceeding to coverage statistics."
	echo "To repeat this step, delete ${path2}/coverage_stats.csv and resubmit."
else
	echo "Generating coverage statistics"
	purge_haplotigs cov \
		-in aligned.bam.gencov \
		-low ${low} \
		-high ${high} \
		-mid ${mid} \
		-out coverage_stats.csv
fi

#Purge haplotigs
if [ -s curated.fasta ]
then
	echo "Fasta with purged haplotigs found. Why were you trying to run this again?"
	echo "To repeat this step, delete curated.fasta and resubmit."
else
	echo "Running purge_haplotigs"
	purge_haplotigs purge \
	-g ../${asm} \
	-c coverage_stats.csv \
	-t ${threads} \
	-d \
	-b aligned.bam
fi

mkdir hap
mv *haplotigs.fasta hap/
mv *artefacts.fasta hap/

echo "Done"
