#!/bin/bash --login
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=200GB
#SBATCH --job-name rename_chr
#SBATCH --output=../job_reports/%x-%j.SLURMout

#Set this variable to the path to wherever you have conda installed
conda="${HOME}/anaconda3"

#Change to current directory
cd ${PBS_O_WORKDIR}
#Export paths to conda
export PATH="${conda}/envs/maker/bin:${PATH}"
export LD_LIBRARY_PATH="${conda}/envs/maker/lib:${LD_LIBRARY_PATH}"

#Set temporary directories for large memory operations
export TMPDIR=$(pwd)
export TMP=$(pwd)
export TEMP=$(pwd)

#Run bash script
bash /mnt/scratch/rittere5/witchs-broom/scripts/annotation/rename_annotations_by_chr.sh \
--chrUN \
--prefix VvDak_v1 \
--justify 6 \
--zeros_at_end 1 \
--input_gff ../VvDak_v1/VvDak_v0.1.gff \
--input_protein_fa ../VvDak_v1/VvDak_v0.1_protein.fa \
--input_transcript_fa ../VvDak_v1/VvDak_v0.1_transcript.fa \
--output_prefix VvDak_v1

echo "Done"
