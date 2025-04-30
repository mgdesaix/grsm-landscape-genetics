#!/bin/bash
#SBATCH --job-name=radish-array-64PCs-agg4
#SBATCH --output=./err-out/radish-array-64PCs-agg4.%A_%a.out
#SBATCH --error=./err-out/radish-array-64PCs-agg4.%A_%a.err
#SBATCH --partition=high_mem
#SBATCH --time=00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
################################
#SBATCH --array=16
################################

module load R

#31 total covariate combinations
# 16 combinations for supplementing the waterFactor models (vs waterBinary)

prefix=$(awk -v FS="=" -v n=$SLURM_ARRAY_TASK_ID 'NR == n {print $1}' radish-array-waterFactor.txt)
radish_func=$(awk -v FS="=" -v n=$SLURM_ARRAY_TASK_ID 'NR == n {print $2}' radish-array-waterFactor.txt)
agg_fact=4

Rscript ./run-radish-array.R ${prefix} ${radish_func} ${agg_fact}
