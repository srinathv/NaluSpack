#!/bin/bash

#PBS -N nalu_build_intel
#PBS -l nodes=1:ppn=24,walltime=4:00:00
#PBS -A windFlowModeling
#PBS -q short
#PBS -j oe
#PBS -W umask=002

#Script for installing Nalu on Peregrine using Spack with Intel compiler

# Control over printing and executing commands
print_cmds=true
execute_cmds=true

# Function for printing and executing commands
cmd() {
  if ${print_cmds}; then echo "+ $@"; fi
  if ${execute_cmds}; then eval "$@"; fi
}

set -e

cmd "module purge"
cmd "module load gcc/5.2.0"
cmd "module load python/2.7.8 &> /dev/null"
cmd "module unload mkl"

# The intel.cfg sets up the -xlinker rpath for the intel compiler's own libraries
for i in ICCCFG ICPCCFG IFORTCFG
do
  cmd "export $i=${SPACK_ROOT}/etc/spack/intel.cfg"
done

# Get general preferred Nalu constraints from a single location
cmd "source ../spack_config/shared_constraints.sh"

# Using a disk instead of RAM for the tmp directory for intermediate Intel compiler files
cmd "mkdir -p /scratch/${USER}/.tmp"
cmd "export TMPDIR=/scratch/${USER}/.tmp"

cmd "spack install nalu %intel@17.0.2 ^${TRILINOS}@develop ${GENERAL_CONSTRAINTS}"
