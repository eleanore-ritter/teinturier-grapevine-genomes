#!/bin/bash --login
#SBATCH --time=167:59:59            # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=1                   # number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks-per-node=1         # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=1           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem=80G                   # memory required per allocated CPU (or core) - amount of memory (in bytes)
#SBATCH --job-name liftoff             # you can give your job a name for easier identification (same as -J)
#SBATCH --output=assembly/job_reports/%x_%j.SLURMout

#change to working directory
cd $PBS_O_WORKDIR

export PATH=/mnt/home/rittere5/anaconda3/envs/witchsbroom_py3/bin:$PATH
export LD_LIBRARY_PATH="$HOME/anaconda3/envs/witchsbroom_py3/lib:$LD_LIBRARY_PATH"

#These variables will need to be set/checked
rpath="/mnt/gs21/scratch/rittere5/witchs-broom/data/Vvinifera/PN40024-v4"
ref="PN40024.v4.REF.fasta"
ann="PN40024.v4.1.REF.gff3"
opath="annotations"

#This variable should be set automatically and should not need to be changed
sample="dakapowt"

#Move to output directory
if ls ${opath} >/dev/null 2>&1
then
        echo "Output directory ${opath} already exists"
else
        mkdir ${opath}
        echo "Made output directory: ${opath}"
fi

cd ${opath}

#Run liftoff
echo "Running liftoff on ${sample}"
echo "Reference genome is ${rpath}/${ref}"
echo "Reference annotation file is ${rpath}/${ann}"

liftoff ../assembly/Vvi_Dakapo_without_chr00.fa \
${rpath}/${ref} \
-g ${rpath}/${ann} \
-o ${sample}_liftoff.gff \
-dir temp

echo "Done"
