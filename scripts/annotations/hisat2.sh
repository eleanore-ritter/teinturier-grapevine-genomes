#!/bin/sh -login


#SBATCH --time=168:00:00             # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=4                   # number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks-per-node=1         # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=1           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem=200G                   # memory required per allocated CPU (or core) - amount of memory (in bytes)
#SBATCH --job-name hisat2             # you can give your job a name for easier identification (same as -J)
#SBATCH --output=%x_%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
threads="4"
sample="dakapowt"
file=$(pwd | sed 's/.*rnaseq-annotation\///')
r1="${file}_1.fastq.gz"
r2="${file}_2.fastq.gz"
t1="${file}.trimmed.1.fastq.gz"
t2="${file}.trimmed.2.fastq.gz"
t3="${file}.trimmed.1.single.fastq.gz"
t4="${file}.trimmed.2.single.fastq.gz"
adapters="TruSeq3-PE-2"
path1="fastqc"
path2="../../${sample}/assembly"

#Path to trimmomatic fastas
adapter_path="${conda}/envs/annotations/share/trimmomatic/adapters"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/annotations/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/annotations/lib:${LD_LIBRARY_PATH}"

#Set temporary directories for large memory operations
export TMPDIR=$(pwd | sed s/data.*/data/)
export TMP=$(pwd | sed s/data.*/data/)
export TEMP=$(pwd | sed s/data.*/data/)

gzip ${file}_1.fastq
gzip ${file}_2.fastq

mkdir job_reports

echo "Running trimmomatic on ${r1} and ${r2}"

trimmomatic PE \
-threads ${threads} \
-phred33 \
-trimlog job_reports/trim_log.txt \
-summary job_reports/trim_summary.txt \
${r1} ${r2} ${t1} ${t3} ${t2} ${t4} \
ILLUMINACLIP:${adapter_path}/${adapters}.fa:2:30:10

echo "Running FastQC on trimmed reads"
mkdir ${path1}

fastqc \
-t ${threads} \
-o ${path1} ${t1}

fastqc \
-t ${threads} \
-o ${path1} ${t2}

#Run hisat2
echo "Running hisat2"

hisat2 \
-x ${path2}/${sample} \
-1 ${t1} \
-2 ${t2} \
-p ${threads} \
--phred33 \
-S ${file}_${sample}.sam

#Make sorted bam file and remove sam file
echo "Creating sorted bam file"

samtools sort ${file}_${sample}.sam > ${file}_${sample}_sorted.bam
rm ${file}_${sample}.sam

echo "Done"
