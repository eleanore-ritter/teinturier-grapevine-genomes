#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=500GB
#SBATCH --job-name bwa
#SBATCH --output=%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/polishing/bin:$PATH"
export LD_LIBRARY_PATH="${conda}/envs/polishing/lib:$LD_LIBRARY_PATH"

echo "Creating bwa index for fasta"

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
threads=20
java_options="-Xmx490G"
input="curated.fasta" #Can set to empty and script will find fasta in directory submitted
sample="dakapowt"

#In general dont change this, unless using a similar datatype
#This should match the dataype in the misc/samples.csv file
datatype="wgs"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/polishing/bin:$PATH"
export LD_LIBRARY_PATH="${conda}/envs/polishing/lib:$LD_LIBRARY_PATH"
#Path to picard
picard="${conda}/envs/polishing/share/picard-*/picard.jar"
#Path to pilon
pilon="${conda}/envs/polishing/share/pilon-*/pilon.jar"
#Path to trimmomatic fastas
adapter_path="${conda}/envs/polishing/share/trimmomatic/adapters"

#The following shouldn't need to be changed, but should set automatically
path1=$(pwd | sed s/data.*/misc/)
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
genotype=$(pwd | sed s/.*\\/${species}\\/// | sed s/\\/.*//)


#Adapter fasta, set automatically from misc/samples.csv
adapters="TruSeq3-PE-2"

#Fastq files, these should not have to be changed, but should set automatically
path3a="$(pwd | sed "s/${sample}.*/${sample}/")"
path3="${path3a}/fastq/${datatype}"
r1="${path3}/combined.1.fastq.gz"
r2="${path3}/combined.2.fastq.gz"
t1="${path3}/trimmed.1.fastq.gz"
t2="${path3}/trimmed.2.fastq.gz"
t3="${path3}/trimmed.1.single.fastq.gz"
t4="${path3}/trimmed.2.single.fastq.gz"
if ls ${path3}/*_R1_001.fastq.gz >/dev/null 2>&1
then
        if ls ${path3}/*_R2_001.fastq.gz >/dev/null 2>&1
        then
                echo "Data is Paired-end"
                PE="TRUE"
                if [ -f ${t1} ]
                then
                        echo "Trimmed reads found, skipping trimming"
                else
                        cat ${path3}/*_R1_001.fastq.gz > $r1
                        cat ${path3}/*_R2_001.fastq.gz > $r2
                fi
        else
                echo "Data is Single-end"
                PE="FALSE"
                if [ -f ${t1} ]
                then
                        echo "Trimmed reads found, skipping trimming"
                else
                        cat ${path3}/*_R1_001.fastq.gz > $r1
                fi
        fi
elif ls ${path3}/*_1.fastq.gz >/dev/null 2>&1
then
        if ls ${path3}/*_2.fastq.gz >/dev/null 2>&1
        then
                echo "Data is Paired-end"
                PE="TRUE"
                if [ -f ${t1} ]
                then
                        echo "Trimmed reads found, skipping trimming"
                else
                        cat ${path3}/*_1.fastq.gz > $r1
                        cat ${path3}/*_2.fastq.gz > $r2
                fi
        else
                echo "Data is Single-end"
                PE="FALSE"
                if [ -f ${t1} ]
                then
                        echo "Trimmed reads found, skipping trimming"
                else
                        cat ${path3}/*_1.fastq.gz > $r1
                fi
        fi
else
        echo "Data Missing"
fi

#Trim & QC reads
if [ -f ${t1} ]
then
        if [ ${PE} = "TRUE" ]
        then
                echo "To rerun this step, please delete ${t1} & ${t2} and resubmit"
        else
                echo "To rerun this step, please delete ${t1} and resubmit"
        fi
else
        if [ ${PE} = "TRUE" ]
        then
                echo "Running trimmomatic PE"
                trimmomatic PE \
                        -threads ${threads} \
                        -phred33 \
                        -trimlog ${path3}/trim_log.txt \
                        -summary ${path3}/trim_summary.txt \
                        ${r1} ${r2} ${t1} ${t3} ${t2} $t4 \
                        ILLUMINACLIP:${adapter_path}/${adapters}.fa:2:30:10:4:TRUE \
                        LEADING:3 \
                        TRAILING:3 \
                        SLIDINGWINDOW:4:15 \
                        MINLEN:30
                echo "Running fastqc"
                mkdir ${path3}/fastqc
                fastqc -t ${threads} -o ${path3}/fastqc/ ${t1} ${t2} ${r1} ${r2}
        elif [ ${PE} = "FALSE" ]
        then
                echo "Running trimmomatic SE"
                trimmomatic SE \
                        -threads ${threads} \
                        -phred33 \
                        -trimlog ${path3}/trim_log.txt \
                        -summary ${path3}/trim_summary.txt \
                        ${r1} ${t1} \
                        ILLUMINACLIP:${adapter_path}/${adapters}.fa:2:30:10:4:TRUE \
                        LEADING:3 \
                        TRAILING:3 \
                        SLIDINGWINDOW:4:15 \
                        MINLEN:30
                echo "Running fastqc"
                mkdir ${path3}/fastqc
                fastqc -t ${threads} -o ${path3}/fastqc/ ${t1} ${r1}
        fi
fi
rm ${r1} ${r2}

#Define Read Group
ID=$(zcat ${t1} | head -1 | cut -d ':' -f 3,4 | tr ':' '.')
PU=$(zcat ${t1} | head -1 | cut -d ':' -f 3,4,10 | tr ':' '.')
SM=$(pwd | sed s/^.*\\///)
PL="ILLUMINA"
LB="lib1"

#Look for fasta file, there can only be one!
if [ -z ${input} ]
then
        echo "No input fasta provided, looking for fasta"
        if ls *.fa >/dev/null 2>&1
        then
                input=$(ls *fa | sed s/.*\ //)
                echo "Fasta file ${input} found"
        elif ls *.fasta >/dev/null 2>&1
        then
                input=$(ls *fasta | sed s/.*\ //)
                echo "Fasta file ${input} found"
        elif ls *.fna >/dev/null 2>&1
        then
                input=$(ls *fna | sed s/.*\ //)
                echo "Fasta file ${input} found"
        else
                echo "No fasta file found, please check and restart"
        fi
else
        echo "Input fasta: ${input}"
fi

#Look for bwamem index
if ls *.pac >/dev/null 2>&1
then
        echo "Bwamem index files found"
else
        echo "Bwamem index files not found, creating index files"
        bwa index ${input}
fi

bwa mem -t ${threads} \
-R "@RG\tID:${ID}\tLB:${LB}\tPL:${PL}\tSM:${SM}\tPU:${PU}" \
-M ${input} ${t1} ${t2} | samtools view -@ 4 -bSh | samtools sort -@ 4 > mapped_wgs_reads.bam

echo "Done"
