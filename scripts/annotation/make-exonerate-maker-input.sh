#!/bin/bash --login
#SBATCH --time=03:59:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50GB
#SBATCH --job-name reformat
#SBATCH --output=../job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/maker/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/maker/lib:${LD_LIBRARY_PATH}"

#Combine and reformat exonerate data into gff
path1=$(pwd | sed s/data.*/scripts/)
a=$(pwd | sed s/.*\\///)
species=$(ls)
path2="exonerate_output"

mkdir tmp
mkdir ${path2}

for k in ${species}
do
	cd ${k}
	for i in $(ls | grep "myseq")
	do
		cd ${i}
		for j in target_chunk_*_query_chunk_*
		do
			sed '1,2d' ${j} | grep -v "\-\-\ completed\ exonerate\ analysis" > ../../tmp/${k}_${i}_${j}.tmp
		done
		cd ../
	done
	cd ../
done

cat tmp/*tmp > ${a}

#Reformat exonerate output
perl ${path1}/annotation/pl/reformat_exonerate_protein_gff.pl --input_gff ${a} --output_gff tmp.gff

#Sort the gff file
gff3_sort -g tmp.gff -og ${a}.gff
rm tmp.gff

#Rename for maker
cat ${a}.gff | sed 's/mRNA/protein_match/g' | \
sed 's/exon/match_part/g' | sed s/protein2genome/protein_gff\:protein2genome/ > protein_alignments_maker_input.gff

rm -R tmp

echo "Done"
