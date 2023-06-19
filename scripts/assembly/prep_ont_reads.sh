#!/bin/bash --login
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=500GB
#SBATCH --job-name prep_ont_reads
#SBATCH --output=job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="/mnt/home/rittere5/anaconda3/"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/assembly/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/assembly/lib:${LD_LIBRARY_PATH}"

#Set variables
threads=20
quality=0 #guppy filtered on quality of 7
length=300 #Needs to be >0 or else reads of 0 length will be included!

#The following shouldn't need to be changed, but should set automatically
sample=$(pwd | sed s/^.*\\///)
input="/mnt/home/rittere5/witchs-broom/data/wb-nanopore/pass/barcode12/*fastq.gz"
input2="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/dakapowt/fastq/ont/20221115_gDNA_ONT/fastq_pass/*fastq.gz"
output1A="combined.fastq.gz"
output1B="combined-new.fastq.gz"
output1C="combined-all.fastq.gz"
output2="trimmed.fastq.gz"
output3="clean.fastq.gz"
path1=$(pwd | sed s/data.*// | sed s/$/misc/)
lambda="${path1}/lambda_3.6kb.fasta"
path2="fastqc"

#Combine reads from old ONT sequencing run if needed
echo "Combining reads from old ONT sequencing run if needed"
cd fastq/ont/old-ont/
if ls ${output1A} >/dev/null 2>&1
then
	echo "${output1A} already exists"
	echo "To redo this step, delete ${output1A} and resubmit"
else
	echo "Combining fastq files"
	cat ${input} > ${output1A}
fi

#Combine reads from new ONT sequencing run if needed
echo "Combining reads from new ONT sequencing run if needed"
cd ../20221115_gDNA_ONT/
if ls ${output1B} >/dev/null 2>&1
then
        echo "${output1B} already exists"
        echo "To redo this step, delete ${output1B} and resubmit"
else
        echo "Combining fastq files"
        cat ${input2} > ${output1B}
fi

#Combine reads from both sequencing runs if needed
echo "Combining reads from both sequencing runs if needed"
cd ../
if ls ${output1C} >/dev/null 2>&1
then
        echo "${output1C} already exists"
        echo "To redo this step, delete ${output1C} and resubmit"
else
        echo "Combining fastq files"
        cat old-ont/${output1A} 20221115_gDNA_ONT/${output1B} > ${output1C}
fi

#Trim reads
if ls ${output2} >/dev/null 2>&1
then
	echo "${output2} already exists"
	echo "To redo this step, delete ${output2} and resubmit"
else
	echo "Trimming fastq files with porechop"
	porechop \
		-i ${output1C} \
		-o ${output2} \
		-t ${threads} \
		--min_trim_size 5 \
		--extra_end_trim 2 \
		--end_threshold 80 \
		--middle_threshold 90 \
		--extra_middle_trim_good_side 2 \
		--extra_middle_trim_bad_side 50 \
		--min_split_read_size ${length}
fi

#Filter reads
if ls ${output3} >/dev/null 2>&1
then
	echo "${output3} already exists"
	echo "To redo this step, delete ${output3} and resubmit"
else
	echo "Filtering and trimming reads"
	zcat ${output2} | \
	NanoLyse -r ${lambda} | \
	NanoFilt -q ${quality} -l ${length} | \
	gzip > ${output3} 
fi

#FastQC analysis of reads
echo "Running FastQC on reads"
mkdir ${path2}
for i in ${output1C} ${output2} ${output3}
do
	echo "Running FastQC on ${i}"
	fastqc \
		-t ${threads} \
		-o ${path2} ${i}
done

echo "Done"

