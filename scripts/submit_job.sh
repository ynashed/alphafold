#!/bin/bash
#SBATCH --partition=cryoem
#SBATCH --job-name=alphafold
#SBATCH --output=output-%j.txt --error=output-%j.txt
#SBATCH --nodes=1
#SBATCH --gpus=a100:1
#SBATCH --mem=131072

DBS_PATH=/sdf/group/ml/CryoNet/alphafold/databases/
SIF_PATH=/sdf/group/ml/CryoNet/singularity_images/alphafold_latest.sif
OUT_PATH=/sdf/group/ml/CryoNet/alphafold/results_${SLURM_JOBID}/
FASTA_PATH=/sdf/group/ml/CryoNet/alphafold/test_fasta/T1050.fasta
LSCRATCH_PATH="${LSCRATCH}"/alphafold/data/

#mkdir -p "${LSCRATCH_PATH}"
#cp -aruv "${DBS_PATH}/." "${LSCRATCH_PATH}"
#DBS_PATH="${LSCRATCH_PATH}"

mkdir -p "${OUT_PATH}"
cp "$0" "${OUT_PATH}"/submit_job_"${SLURM_NTASKS}".sh

singularity run --env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0 \
                --env OPENMM_CPU_THREADS=${SLURM_NTASKS},NVIDIA_VISIBLE_DEVICES=all \
                -B /sdf -B ${DBS_PATH}:/data -B .:/etc --nv ${SIF_PATH} \
                --n_cpu=${SLURM_NTASKS} \
                --fasta_paths=${FASTA_PATH} \
                --output_dir=${OUT_PATH} \
                --data_dir=/data/ \
                --uniref90_database_path=/data/uniref90/uniref90.fasta \
                --mgnify_database_path=/data/mgnify/mgy_clusters_2018_12.fa \
                --pdb70_database_path=/data/pdb70/pdb70 \
                --template_mmcif_dir=/data/pdb_mmcif/mmcif_files \
                --obsolete_pdbs_path=/data/pdb_mmcif/obsolete.dat \
                --small_bfd_database_path=/data/small_bfd/bfd-first_non_consensus_sequences.fasta \
                --max_template_date=2021-07-28 \
                --model_preset=monomer \
                --benchmark=True \
                --use_precomputed_msas=False \
                --db_preset=reduced_dbs

# To run with --db_preset=full_dbs
#                --uniclust30_database_path=/data/uniclust30/uniclust30_2018_08/uniclust30_2018_08 \
#                --bfd_database_path=/data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt
