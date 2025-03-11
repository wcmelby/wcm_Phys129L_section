#!/bin/bash

# Input and output directories
INPUT_FILE="./qe_file/qe_file/pw.graphene.scf.in"
OUTPUT_DIR="output_lattice"
ENERGY_FILE="lattice_energy_data.txt"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR
> $ENERGY_FILE  # Clear previous data file

# Range of b-axis values (from 0.4 to 0.7 with 10 points)
B_VALUES=$(seq 0.4 0.03 0.7)

# Loop over each b-axis value
for B_AXIS in $B_VALUES; do
    # Create a modified input file for each b-axis value
    MODIFIED_INPUT="${OUTPUT_DIR}/pw.graphene.scf.b${B_AXIS}.in"
    MODIFIED_OUTPUT="${OUTPUT_DIR}/pw.graphene.scf.b${B_AXIS}.out"

    # Copy original input file and modify the b-axis value
    sed "s/celldm(1) *= *[0-9.]*,/celldm(1) = ${B_AXIS},/" $INPUT_FILE > $MODIFIED_INPUT

    # Run pw.x
    pw.x < $MODIFIED_INPUT > $MODIFIED_OUTPUT

    # Extract total energy using grep
    ENERGY=$(grep "!    total energy" $MODIFIED_OUTPUT | awk '{print $5}')

    # Save b-axis value and energy to file
    if [ -n "$ENERGY" ]; then
        echo "$B_AXIS $ENERGY" >> $ENERGY_FILE
    fi
done

# Python plotting script
python3 - << EOF
import numpy as np
import matplotlib.pyplot as plt

# Load data
data = np.loadtxt('$ENERGY_FILE')
b_values = data[:, 0]
energy = data[:, 1]

# Plotting
plt.figure(figsize=(8, 5))
plt.plot(b_values, energy, marker='o', linestyle='-', label='Total Energy (Ry)')
plt.xlabel('b-axis lattice constant (alat units)')
plt.ylabel('Total Energy (Ry)')
plt.title('Total Energy vs. b-axis Lattice Constant')
plt.grid(True)
plt.legend()

# Find optimal lattice constant (minimum energy)
optimal_b = b_values[np.argmin(energy)]
plt.axvline(optimal_b, color='r', linestyle='--', label=f'Optimal b = {optimal_b:.3f}')
plt.legend()

plt.savefig('lattice_energy_plot.png')
plt.show()
EOF

echo "Energy plot saved as 'lattice_energy_plot.png'"