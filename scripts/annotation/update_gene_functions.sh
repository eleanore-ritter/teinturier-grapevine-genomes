#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=50GB
#SBATCH --job-name=update-gene-functions
#SBATCH --output=job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
threads=50 #Threads for interproscan
new_proteins="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/dakapowt/assembly/VvDak_v1/VvDak_v1.1_protein.fa"
new_gff="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/dakapowt/assembly/VvDak_v1/VvDak_v1.1.gff"
output="VvDak_v1.1"
arabidopsis_blast=

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/interproscan/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/interproscan/lib:${LD_LIBRARY_PATH}"

#Set temporary directories for large memory operations
export TMPDIR=$(pwd)
export TMP=$(pwd)
export TEMP=$(pwd)

#The following shouldn't need to be changed, but should set automatically
homepath="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/Dakapo/dakapowt/assembly"
path1=$(pwd | sed s/data.*/misc/)
path2=$(pwd | sed s/data.*/scripts/)
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
genotype=$(pwd | sed s/.*\\/${species}\\/// | sed s/\\/.*//)
sample=$(pwd | sed s/.*${species}\\/${genotype}\\/// | sed s/\\/.*//)
path3="update_gene_functions"
path4="/mnt/gs21/scratch/rittere5/my_interproscan"

cd ${path4}
wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.66-98.0/interproscan-5.66-98.0-64-bit.tar.gz
gunzip interproscan-5.66-98.0-64-bit.tar.gz

cd ${homepath}

#Make & cd to directory
if [ -d ${path3} ]
then
	cd ${path3}
else
	mkdir ${path3}
	cd ${path3}
fi

#Copy over the new proteins
cp ${new_proteins} new_proteins.fa
#Get gene names for new proteins
grep \> new_proteins.fa | sed s/\>// > new_proteins_list 

#Run interproscan
echo "Running interproscan"
${path4}/interproscan-5.66-98.0/interproscan.sh \
	--cpu ${threads} \
	-appl pfam \
	-goterms \
	-pa \
	-dp \
	-iprlookup \
	-t p \
	-f TSV \
	-i new_proteins.fa \
	-o ${output}.iprscan

#Check if BLAST results provided, if not, then run BLAST
if [ -z ${arabidopsis_blast} ]
then
	#Download Arabidopsis genes and create diamond DB
	echo "Downloading Arabidopsis TAIR10 proteins"
	wget -q https://www.arabidopsis.org/download_files/Proteins/TAIR10_protein_lists/TAIR10_pep_20110103_representative_gene_model
	echo "Making diamond blast DB for "
	diamond makedb \
		--threads ${threads} \
		--in TAIR10_pep_20110103_representative_gene_model \
		--db TAIR10.dmnd

	#Run diamond blastp against Arabidopsis 
	echo "Running diamond blastp on "
	diamond blastp \
		--threads ${threads} \
		--db TAIR10.dmnd \
		--query ${new_proteins} \
		--out ${output}_TAIR10_blast.out \
		--evalue 1e-6 \
		--max-hsps 1 \
		--max-target-seqs 5 \
		--outfmt 0
	arabidopsis_blast="${output}_TAIR10_blast.out"
fi

#Download and format Arabidopsis TAIR10 functional descriptions
echo "Downloading and formatting Arabidopsis TAIR10 functional descriptions"
wget -q https://www.arabidopsis.org/download_files/Genes/TAIR10_genome_release/TAIR10_functional_descriptions
perl -e  'while (my $line = <>){ my @elems = split "\t", $line; if($elems[2] ne "") {print "$elems[0]\t$elems[2]\n"}}' \
TAIR10_functional_descriptions > TAIR10_short_functional_descriptions.txt

#Download Arabidopsis GO terms
echo "Downloading Arabidopsis GO terms"
wget -q https://www.arabidopsis.org/download_files/GO_and_PO_Annotations/Gene_Ontology_Annotations/gene_association.tair.gz
gunzip gene_association.tair.gz

#Create header for output file
echo "Transcript Locus Arabidopsis_blast_hit Arabidopsis_GO_terms PFAM_hits PFAM_GO_terms Combined_Arabidopsis_PFAM_GO_terms Short_functional_description" | \
tr ' ' '\t' > ${output}-functional-annotations.tsv
#Loop over each gene and format data
cat new_proteins_list | while read line
do
	echo ${line}
	#Handle the Arabidopsis BLAST
	AtID=$(grep ${line} ${blast} | sort -r -k12 | head -1 | cut -f2)
	if [[ ! -z ${AtID} ]]
	then
		#Get the Arabidopsis Description
		AtDesc=$(grep ${AtID} TAIR10_short_functional_descriptions.txt | cut -f2)
		if [[ ! -z ${AtDesc} ]]
		then
			AtDesc=$(echo "Arabidopsis BLAST: ${AtDesc}" | cut -f2 | tr ' ' ';')
		else
			AtDesc=NA
		fi
		#Get Arabidopsis GO terms
		AtGO=$(grep ${AtID} gene_association.tair | cut -f5 | tr '|' '\n' | sort | uniq | tr '\n' '|' | \
			sed s/\|$//)
		if [ -z ${AtGO} ]
		then
			AtGO=NA
		fi
	else
		AtID=NA
		AtDesc=NA
		AtGO=NA
	fi
	#Get the Pfam domains
	grep ${line} ${output}.iprscan > tmp
	#If tmp is not empty
	if [ -s tmp ]
	then
		#List the PfamIDs
		PfamID=$(cut -f5 tmp | sort | uniq | tr '\n' '|' | sed s/\|$//)
		#Get the Pfam Descriptions
		PfamDesc=$(echo "PFAM: $(cut -f6 tmp | sort | uniq | tr '\n' ',')" | tr ' ' ';' | sed s/\,$//)
		if [ -z ${PfamDesc} ]
		then
			PfamDesc=NA
		fi
		#List the PfamGO terms
		PfamGO=$(cut -f14 tmp | tr '|' '\n' | sort | uniq | grep -v "-" | tr '\n' '|' | sed s/\|$//)
		if [ -z ${PfamGO} ]
		then
			PfamGO=NA
		fi
	else
		PfamID=NA
		PfamDesc=NA
		PfamGO=NA
	fi
	if [[ ${AtDesc} != "NA" ]]
	then
		FuncDesc=${AtDesc}
	else
		if [[ ${PfamDesc} != "NA" ]]
		then
			FuncDesc=${PfamDesc}
		else
			if [ -f old_proteins_list ]
			then
				if [[ ! -z $(grep ${line} old_proteins_list | cut -d ' ' -f5 | awk -v FS="|" '$3 > 0') ]]
				then
					FuncDesc="Expressed;gene;of;unknown;function"
				else
					FuncDesc="Hypothetical;gene;of;unknown;function"
				fi
			else
				FuncDesc="Hypothetical;gene;of;unknown;function"
			fi
		fi
	fi
	#Combine the GO term sets
	combinedGO=$(echo "${AtGO}|${PfamGO}" | tr '|' '\n' | grep -v NA | sort | uniq | tr '\n' '|' | sed s/\|$//)
	#Get the gene name
	gene=$(grep ${line} ${new_gff} | awk '$3=="mRNA"' | cut -f9 | sed s/.*Parent\=// | sed s/\;.*//)
	#Output the results
	echo "${line} ${gene} ${AtID} ${AtGO} ${PfamID} ${PfamGO} ${combinedGO} ${FuncDesc}" | \
	tr ' ' '\t' | tr ';' ' ' >> ${output}-functional-annotations.tsv
	#Remove tmp file
	rm tmp
done

#Remove interposcan temp directory
rmdir temp

echo "Done"