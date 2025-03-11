#!/bin/bash

# Directory containing output files
OUTPUT_DIR="output"
ENERGY_FILE="energy_data.txt"

# Clear previous data file
> $ENERGY_FILE

# Extract energy values from each output file
for OUTPUT in $OUTPUT_DIR/pw.graphene.scf.ecut*.out; do
    # Extract the ecutwfc value from the filename
    ECUT=$(echo $OUTPUT | grep -oP '(?<=ecut)\d+')

    # Extract the total energy using grep
    ENERGY=$(grep "!    total energy" $OUTPUT | awk '{print $5}')

    # Write the ecutwfc and energy to the data file
    if [ -n "$ENERGY" ]; then
        echo "$ECUT $ENERGY" >> $ENERGY_FILE
    fi
done

# Python plotting script
python3 - << EOF
import matplotlib.pyplot as plt
import numpy as np

# Load data
data = np.loadtxt('$ENERGY_FILE')
ecutwfc = data[:, 0]
energy = data[:, 1]

# Plotting
plt.figure(figsize=(8, 5))
plt.plot(ecutwfc, energy, marker='o', linestyle='-', label='Total Energy (Ry)')
plt.xlabel('ecutwfc (Ry)')
plt.ylabel('Total Energy (Ry)')
plt.title('Total Energy vs. ecutwfc')
plt.grid(True)
plt.legend()
plt.savefig('energy_vs_ecutwfc.png')
plt.show()
EOF

echo "Energy plot saved as 'energy_vs_ecutwfc.png'"