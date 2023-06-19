#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=500GB
#SBATCH --job-name tigmint-long-ER
#SBATCH --output=../../job_reports/%x-%j.SLURMout

#Heavily modified from CEN's tigment-long script

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
threads=6 #doesn't seem to want to use more than 6
cut=500 #cut length for long reads
span=auto #Number of spanning molecules threshold. Set span=auto to automatically select
dist=auto #Max dist between reads to be considered same molecule. auto to automatically calculate
window=1000 #Window size (bp) for checking spanning molecules
minsize=1000 #Minimum molecule size
trim=0 #Number of bases to trim off contigs following cuts
datatype="ont" #ont or pb
input="consensus" #input fasta, if left blank, will look for it in current directory, mutually exclusive with input_dir
input2="consensus.fa"
name="consensus"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/scaffolding/bin:$PATH"
export LD_LIBRARY_PATH="${conda}/envs/scaffolding/lib:$LD_LIBRARY_PATH"

#The following shouldn't need to be changed, but should set automatically
path1=$(pwd | sed s/data.*/misc/)
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
genotype=$(pwd | sed s/.*\\/${species}\\/// | sed s/\\/.*//)
sample=$(pwd | sed s/.*\\/${species}\\/${genotype}\\/// | sed s/\\/.*//)
condition="assembly"
assembly=$(pwd | sed s/^.*\\///)
path2=$(pwd | sed s/${genotype}\\/${sample}.*/${genotype}\\/${sample}/)
path3="tigmint_long"
path4=".."
path5=$(pwd)

#Get genome size estimate
genomeSize=$(awk -v FS="," \
	-v a=${species} \
	-v b=${genotype} \
	-v c=${sample} \
	-v d=${condition} \
	-v e=${datatype} \
	'{if ($1 == a && $2 == b && $3 == c && $4 == d && $5 == e) print $9}' \
	${path1}/samples.csv)
genomeSize2="500000000"

#Make and cd to output directory
if [ -d ${path3} ]
then
	echo "Previous run for $i already found, skipping"
	echo "To rerun this step, delete directory ${path3} and resubmit"
else
	mkdir ${path3}
	cd ${path3}
fi

#Copy and rename files...because of stupid eccentricities of some code
cp ${path2}/fastq/${datatype}/clean.fastq.gz reads.fq.gz
cp ${path5}/${input}.fasta ${input}.fa

#Run tigmint
echo "Running tigmint-long on ${input}"

tigmint-make tigmint-long \
draft=${input} \
reads=reads \
longmap=${datatype} \
cut=${cut} \
span=${span} \
dist=${dist} \
window=${window} \
minsize=${minsize} \
trim=${trim} \
G=${genomeSize2} \
t=${threads}

#Clean some stuff up for downstream analyses
unlink ${name}.cut${cut}.tigmint.fa
rm reads.fq.gz
rm ${input2}

#rename fasta & bed file to something more easily handled
long_part=cut${cut}.molecule.size${minsize}.trim${trim}.window${window}.span${span}.breaktigs
name2=${name}.reads.${long_part}
mv ${name2}.fa ${name}_tigmint.fa
mv ${name2}.fa.bed ${name}_tigmint.fa.bed

cd ../
echo "tigmint-long on ${input} complete"

echo "Done"
