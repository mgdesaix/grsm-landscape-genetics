#!/bin/bash
#SBATCH --job-name=radish-null-64PCs
#SBATCH --output=./err-out/radish-null-64PCs.%j.out
#SBATCH --error=./err-out/radish-null-64PCs.%j.err
#SBATCH --partition=high_mem
#SBATCH --time=00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
################################

################################

module load R

# Get null model for spatial resolution of agg_fact
agg_fact=4
Rscript ./run-radish-null.R ${agg_fact}

# Get null model for spatial resolution of agg_fact
agg_fact=2
Rscript ./run-radish-null.R ${agg_fact}
