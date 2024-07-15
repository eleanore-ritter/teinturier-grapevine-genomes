#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=200GB
#SBATCH --job-name LAI
#SBATCH --output=job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Set variables
input="edta/Vvi_Dakapo_without_chr00.fa.mod"
engine="rmblast" #crossmatch, wublast, abblast, ncbi, rmblast, hmmer
threads=10 #Actual cores used by RM are thread number multiplied by the cores for search engine used.
                        #These are: RMBlast=4 cores, ABBlast=4 cores, nhmmer=2 cores, crossmatch=1 core
                        #So 10 threads with RMBlast actually needs 40 cores!
# IF MULTITHREADING IS USED, CPUS PER TASK MUCH BE CHANGED TO 40
#Set what repeat library to use. This is currently set to a set of denovo TEs identified by EDTA
LTR_lib="../edta/*.fa.mod.EDTA.raw/LTR/*.fa.mod.LTRlib.fa" #non-redundant LTRlib from LTR_retriever
LTR_list="../edta/*.fa.mod.EDTA.raw/LTR/*.fa.mod.pass.list"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/EDTA/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/EDTA/lib:${LD_LIBRARY_PATH}"

#The following shouldn't need to be changed, but should set automatically
path1=$(pwd | sed s/data.*/misc/)
species=$(pwd | sed s/^.*\\/data\\/// | sed s/\\/.*//)
genotype=$(pwd | sed s/.*\\/${species}\\/// | sed s/\\/.*//)
sample=$(pwd | sed s/.*${species}\\/${genotype}\\/// | sed s/\\/.*//)
path2="lai"

##Prepare input files from edta
#cd edta
##gff to bed
#for genome in ${input}; do perl gff2bed.pl $genome.mod.EDTA.TEanno.gff3 structural > $genome.mod.EDTA.TEanno.struc.bed & done
##get pass.list
#for genome in ${input}; do grep LTR $genome.mod.EDTA.TEanno.struc.bed|grep struc|awk '{print $1":"$2".."$3"\t"$7}' > $genome.mod.EDTA.TEanno.LTR.pass.list & done
##bed to rmout
#for genome in ${input}; do perl -nle 'my ($chr, $s, $e, $anno, $dir, $supfam)=(split)[0,1,2,3,8,12]; print "10000 0.001 0.001 0.001 $chr $s $e NA $dir $anno $supfam"' $genome.mod.EDTA.TEanno.struc.bed > $genome.out.EDTA.TEanno.out & done

#Run LAI
#cd ../
#mkdir ${path2}
#cp edta/*.mod.EDTA.TEanno.LTR.pass.list lai/
cd ${path2}

LAI \
-genome ../${input} \
-intact Vvi_Dakapo_without_chr00.fa.mod.EDTA.TEanno.LTR.pass.list \
-all Vvi_Dakapo_without_chr00.fa.out.EDTA.TEanno.out

echo "Done"
