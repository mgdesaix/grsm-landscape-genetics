#!/bin/bash
#set a job name
#SBATCH --job-name=test-ancestry-DL-k5
#SBATCH --output=./err-out/test-ancestry-DL-k5.%A_%a.out
#SBATCH --error=./err-out/test-ancestry-DL-k5.%A_%a.err
#SBATCH --partition=cpu_compute
################
#SBATCH --time=00:00:00
#################
#SBATCH --array=3-29
#################

# 29 total subsets
start=$(awk -v n=$SLURM_ARRAY_TASK_ID 'NR == n {print $1}' ./data/arrays/start-stop-array.txt)
# ex. 1
stop=$(awk -v n=$SLURM_ARRAY_TASK_ID 'NR == n {print $2}' ./data/arrays/start-stop-array.txt)
# ex. 20

# outname=full_DL_18790_18790_snps

module load R

out=/lustrefs/nwrc/projects/DeSaix/GSMNP/out/dl-and-ancestry/ancestry

dl_outdir=/lustrefs/nwrc/projects/DeSaix/GSMNP/out/dl-and-ancestry/deltaL

for i in `seq ${start} 1 ${stop}`
do
    ## Run Ancestry
    ancestry_script=./scripts/asf-ancestry-pipeline.sh
    ref=/lustrefs/nwrc/projects/DeSaix/GSMNP/data/genotypes/buffer-10k/deltaL_genotypes/K5_1421RefSet_3422.intersect
    test=/lustrefs/nwrc/projects/DeSaix/GSMNP/data/genotypes/buffer-10k/deltaL_genotypes/grsm-10k-deltaL_snps.intersect.3422
    local=false

    echo ${i} ${outname} "starting ancestry"
    ${ancestry_script} -i ${i} -k 5 -o ${out} -r ${ref} -t ${test} -l ${local}

    # echo ${i} ${outname} "finished ancestry...onto deltaL"
    ## Run Delta Likelihood
    # Rscript ./scripts/asf-deltaL-pipeline.R ${outname} ${i} ${dl_outdir}
done

