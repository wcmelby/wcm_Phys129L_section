#!/bin/bash

# Input and output directories
INPUT_FILE="./qe_file/qe_file/pw.graphene.scf.in"
OUTPUT_DIR="output"
PSEUDO_DIR="/root/Desktop/host/Section/Section_10/pseudo"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Energy cutoff values to test
ECUT_VALUES=(10 15 20 25 30 35 40 60)

# Loop over each ecutwfc value
for ECUT in "${ECUT_VALUES[@]}"; do
    # Create a modified input file for each ecutwfc value
    MODIFIED_INPUT="${OUTPUT_DIR}/pw.graphene.scf.ecut${ECUT}.in"
    MODIFIED_OUTPUT="${OUTPUT_DIR}/pw.graphene.scf.ecut${ECUT}.out"

    # Copy the original input file and modify ecutwfc value
    sed "s/ecutwfc *= *[0-9.]*,/ecutwfc = ${ECUT},/" $INPUT_FILE > $MODIFIED_INPUT

    # Run pw.x
    pw.x < $MODIFIED_INPUT > $MODIFIED_OUTPUT

done

echo "Calculations complete. Results are in the '$OUTPUT_DIR' directory."