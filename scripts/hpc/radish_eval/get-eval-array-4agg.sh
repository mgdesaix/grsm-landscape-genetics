#!/bin/bash
#SBATCH --job-name=eval-array-agg4
#SBATCH --output=./err-out/eval-array-agg4.%A_%a.out
#SBATCH --error=./err-out/eval-array-agg4.%A_%a.err
#SBATCH --partition=cpu_compute
#SBATCH --time=00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
################################
#SBATCH --array=1-16
################################

module load R

# model_file=$(awk -v FS="=" -v n=$SLURM_ARRAY_TASK_ID 'NR == n {print $1}' 64pcs-4agg-array.txt)
model_file=$(awk -v FS="=" -v n=$SLURM_ARRAY_TASK_ID 'NR == n {print $1}' 64pcs-4agg-array-waterFactor.txt)

# ex. fit_mlpe_64PCs_4agg.slope_roads_canopy_waterFactor.Rds

prefix=$(echo ${model_file} | cut -f3- -d"_" | sed 's/.Rds//')
# ex. 64PCs_4agg.slope_roads_canopy_waterFactor

outdir_end=$(echo ${prefix} | cut -f2 -d".")
# ex. slope_roads_canopy_waterFactor
outdir=./eval/${outdir_end}

agg=$(echo ${prefix} | cut -f1 -d"." | cut -f2 -d"_")
# ex. 4agg

mkdir -p ${outdir}

Rscript ./run-eval-array-4agg.R ${model_file} ${prefix} ${outdir} ${agg}

