#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=500GB
#SBATCH --job-name minimap2
#SBATCH --output=%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="/mnt/home/rittere5/anaconda3/"

#THIS MAY NEED TO BE CHANGED
sample="dakapowt"

#Set variables
threads=4
dt="splice:hq"
file=$(pwd | sed 's/.*rnaseq-annotation\///')

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/variant-calling/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/variant-calling/lib:${LD_LIBRARY_PATH}"

#Set temporary directories for large memory operations
export TMPDIR=$(pwd | sed s/data.*/data/)
export TMP=$(pwd | sed s/data.*/data/)
export TEMP=$(pwd | sed s/data.*/data/)

#The following shouldn't need to be changed, but should set automatically
path1="../../${sample}/assembly"
fastq="${file}.fastq"

#Zip fastq file if unzipped
echo "Zipping fastq file"
gzip ${fastq}

#Declare files
echo "minimap2 will map ${file} reads to ${sample} reference"

#Make minimap2 index
#echo "Checking for minimap2 index"

if ls ${path1}/*.mmi >/dev/null 2>&1
then
        echo "Index detected"
else
        echo "No index detected, creating index"
        minimap2 \
                -x ${dt} \
                -d ${path1}/${sample}.mmi \
               ${path1}/*.fa
fi
	
#Run minimap2
echo "Running minimap2"

minimap2 \
-ax ${dt} \
-uf \
${path1}/*.mmi \
${fastq}.gz \
-t ${threads} > ${file}_${sample}.sam

#Make sorted bam file and remove sam file
echo "Creating sorted bam file"

samtools sort ${file}_${sample}.sam > ${file}_${sample}_sorted.bam
rm ${file}_${sample}.sam

echo "Done"
