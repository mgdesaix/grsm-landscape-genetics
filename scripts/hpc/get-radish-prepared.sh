#!/bin/bash
#SBATCH --job-name=prepare-radish
#SBATCH --output=./err-out/prepare-radish.%j.out
#SBATCH --error=./err-out/prepare-radish.%j.err
#SBATCH --partition=high_mem
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=00:00:00
################################
################################

module load R
agg_fact=10
Rscript ./prepare-radish.R ${agg_fact}

agg_fact=4
Rscript ./prepare-radish.R ${agg_fact}

agg_fact=2
Rscript ./prepare-radish.R ${agg_fact}