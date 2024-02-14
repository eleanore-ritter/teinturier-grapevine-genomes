#!/bin/bash --login
#SBATCH --time=03:59:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50GB
#SBATCH --job-name rename_chr
#SBATCH --output=../job_reports/%x-%j.SLURMout

#Set variables
GFF="../VvDak_v1/VvDak_v0.1.gff"
PREFIX="VvDak_v1."
JUSTIFY="6"
ZEROS="1"
OUTPUT="VvDak_v1"
PROTEINS="../VvDak_v1/VvDak_v0.1_protein.fa"
TRANSCRIPTS="../VvDak_v1/VvDak_v0.1_transcript.fa"

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Export paths to conda
export PATH="${conda}/envs/maker/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/maker/lib:${LD_LIBRARY_PATH}"

#Get chromosome list
cut -f1 ${GFF} | grep -v \# | sort | uniq > chr_list

#Loop over chr_list and rename genes for each chromosome
mkdir tmp
cd tmp
cat ../chr_list | while read line
do
	echo "Working on ${line}"
	if [[ ${line:0:3} = "chr" ]]
	then
		awk -v a=${line} '$1==a' ../${GFF} > ${line}.gff
		if [ $(echo ${line} | wc -c) -gt 4 ]
		then
			chr=$(echo ${line} | sed s/chr//)
		else
			chr=$(echo ${line} | sed s/chr/0/)
		fi
		maker_map_ids \
		--prefix ${PREFIX}${chr}g \
		--justify ${JUSTIFY} \
		--iterate 1 \
		${line}.gff | awk -v a=${ZEROS} '{if ($2 ~ /-R/) print $0; else print $0a}' | sed s/-R/${ZEROS}./ > ${line}_renamed.map
	elif [[ CHRUN ]]
	then
		awk -v a=${line} '$1==a' ../${GFF} >> chrUN.gff
	else
		awk -v a=${line} '$1==a' ../${GFF} > ${line}.gff
		maker_map_ids \
			--prefix ${PREFIX}${line}g \
			--justify ${JUSTIFY} \
			--iterate 1 \
			${line}.gff | awk -v a=${ZEROS} '{if ($2 ~ /-R/) print $0; else print $0a}' | sed s/-R/${ZEROS}./ > ${line}_renamed.map
	fi
	chr=
done

if [[ chrUN ]]
then
	chr="UN"
	maker_map_ids \
		--prefix ${PREFIX}${chr}g \
		--justify ${JUSTIFY} \
		--iterate 1 \
		chrUN.gff | awk -v a=${ZEROS} '{if ($2 ~ /-R/) print $0; else print $0a}' | sed s/-R/${ZEROS}./ > chrUN_renamed.map
fi

#Combine files
cd ..
cat tmp/*_renamed.map > ${OUTPUT}-renamed-genes.map
rm -R tmp chr_list

#Rename gff & fasta files
map_gff_ids ${OUTPUT}-renamed-genes.map ${GFF}
map_fasta_ids ${OUTPUT}-renamed-genes.map ${TRANSCRIPTS}
map_fasta_ids ${OUTPUT}-renamed-genes.map ${PROTEINS}

echo "Done"
