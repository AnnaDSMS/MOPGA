#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks=31
##SBATCH --constraint=BDW28
#SBATCH --mem=110GB
#SBATCH --array=0-50%8
#SBATCH --constraint=HSW24
#SBATCH -J box-LS-filtr
#SBATCH -e box-LS-filtr.o%j
#SBATCH -o box-LS-filtr.o%j
#SBATCH --time=03:30:00
#SBATCH --exclusive

NB_NPROC=31 ##

runcode() { srun --mpi=pmi2 -m cyclic -n $@ ; }
liste=''

input="Time_file.txt"
readarray -t dtime < ${input}

date=${dtime[$SLURM_ARRAY_TASK_ID - 1]}

set -vx
ulimit -s
ulimit -s unlimited

rm -f fdr1_filtr_${dtime[$SLURM_ARRAY_TASK_ID - 1]}.dat
for k in $(seq 1 31); do 
        km=$(echo $(( $k - 1)))
	#echo "python extractions-gradients-all-variables-boxes.py 'LS' $km $date" > extract-boxLS${km}-${date}.ksh
        #echo "python extractions-gradients-all-variables-boxes-ADS.py 'LS' $km $date" > extract-boxLS${km}-${date}.ksh
        echo "python extractions-gradients-all-variables-boxes-2019-11-13.py 'MNA' $km ${dtime[$SLURM_ARRAY_TASK_ID - 1]}" >> fdr1_filtr_${dtime[$SLURM_ARRAY_TASK_ID - 1]}.dat
done

echo "Now is the time"

# Good to check before running
module load pserie
module list

which python
srun -n $SLURM_NTASKS pserie_single < fdr1_filtr_${dtime[$SLURM_ARRAY_TASK_ID - 1]}.dat
#runcode  $NB_NPROC /scratch/cnt0024/hmg2840/albert7a/bin/mpi_shell $liste
