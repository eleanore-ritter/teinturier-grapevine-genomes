#!/bin/bash --login
#SBATCH --time=03:59:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100GB
#SBATCH --job-name nucmer
#SBATCH --output=%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/variant-calling/bin:$PATH"
export LD_LIBRARY_PATH="${conda}/envs/variant-calling/lib:$LD_LIBRARY_PATH"

#The following shouldn't need to be changed, but should set automatically
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
path1=$(pwd | sed s/${species}\\/.*/${species}\\/ref/)

#Run samtools faidx on reference - only needs to be done once!

mkdir /mnt/gs21/scratch/rittere5/witchs-broom/ref/PN40024/nucmer

for i in {0..9}
do
samtools faidx /mnt/gs21/scratch/rittere5/witchs-broom/ref/PN40024/Vvinifera.fa chr0${i} -o /mnt/gs21/scratch/rittere5/witchs-broom/ref/PN40024/nucmer/chr${i}.S1
done

for i in {10..19}
do
samtools faidx /mnt/gs21/scratch/rittere5/witchs-broom/ref/PN40024/Vvinifera.fa chr${i} -o /mnt/gs21/scratch/rittere5/witchs-broom/ref/PN40024/nucmer/chr${i}.S1
done

#Run samtools faidx on sample

mkdir nucmer

for i in {0..9}
do
samtools faidx curated.fasta chr0${i}_RagTag_pilon_pilon -o nucmer/chr${i}.S1
done

for i in {10..19}
do
samtools faidx curated.fasta chr${i}_RagTag_pilon_pilon -o nucmer/chr${i}.S1
done

cd nucmer

#Run nucmer

echo "Running nucmer"

for i in {0..19}
do
nucmer --prefix chr${i} /mnt/gs21/scratch/rittere5/witchs-broom/ref/PN40024/nucmer/chr${i}.S1 chr${i}.S1
#Run delta-filter
echo "Running delta-filter on nucmer output"
delta-filter -i 90 -l 5000 chr${i}.delta > chr${i}.mdelta
#Run mummerplot
echo "Running mummerplot on mdelta"
mummerplot --prefix chr${i} chr${i}.mdelta -t png
done

echo "Done"
