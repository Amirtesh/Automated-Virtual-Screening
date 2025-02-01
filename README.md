# Automated-Virtual-Screening

---

This repository contains a **binary executable** that automates ligand screening using three different docking software tools: **Vina**, **Smina**, and **QVina** and either one of them can be used. The binary includes features for ligand file conversion, docking, and results management. It is designed for researchers, students, and computational chemists who need an easy way to automate molecular docking workflows.

## Features

- **Support for Multiple Docking Software**: Run docking simulations using **Vina**, **Smina**, or **QVina**.
- **Ligand File Conversion**: Automatically converts ligand files in `.sdf`, `.mol2`, or `.pdb` formats to the `.pdbqt` format, which is required for docking.
- **Customizable Parameters**: Set the exhaustiveness, number of CPU cores, and docking grid configurations.
- **Automated Docking and Results Collection**: Dock multiple ligands in parallel and collect results (binding scores) into a CSV file.

## Prerequisites

Before running the binary, ensure the following tools are installed and accessible in your system's default path:

1. **OpenBabel**: For converting ligand files to `.pdbqt` format. Install it via:
   - **Ubuntu/Debian**: `sudo apt install openbabel`
   - **MacOS (using Homebrew)**: `brew install open-babel`

2. **Docking Software**:
   - **Vina**: [Vina Installation Guide](https://vina.scripps.edu/downloads/)
   - **Smina**: [Smina Installation Guide](https://sourceforge.net/projects/smina/)
   - **QVina**: [QVina Installation Guide](https://qvina.github.io/)

Ensure that **Vina**, **Smina**, and **QVina** are installed and available in your system's default path, as the binary will call these programs directly.

## Usage

1. **Download the Binary**: Download the compiled binary file **vscreen** from the repository.

2. **Make the Binary Executable**:
   ```bash
   chmod +x vscreen
   ```

3. **Run the Binary**:
   To run the ligand screening process, execute the binary after placing it in current working directory with the desired parameters:
   ```bash
   ./vscreen -dock <vina|smina|qvina> -exhaustiveness <exhaustiveness_level> -cpu <cpu_cores> -grid <grid_file> -convert <yes|no>
   ```
   The executable file can also be placed in default path to be used directly from any directory:
   ```bash
   vscreen -dock <vina|smina|qvina> -exhaustiveness <exhaustiveness_level> -cpu <cpu_cores> -grid <grid_file> -convert <yes|no>
   ```

   - `-dock`: Choose the docking program (`vina`, `smina`, or `qvina`). Docked poses are kept in a separate directory and results file is kept in current directory
   - `-exhaustiveness`: Set the exhaustiveness for the docking program (default: 16).
   - `-cpu`: Set the number of CPU cores to use (default: 1).
   - `-grid`: Provide the grid configuration file (required).
   - `-convert`: Convert ligand files to `.pdbqt` format (default: no). Converted files and original files are both kept in separate directories.

   Example usage:
   ```bash
   ./vscreen -dock vina -exhaustiveness 16 -cpu 4 -grid grid.txt -convert yes
   ```
   If your ligands are already prepared (energy minimized and in pdbqt form) please make sure to place all the ligands in a folder named `pdbqt_ligands` and give `convert` parameter as `no`.

5. **Check Results**: After docking completes, results will be saved in a file named `docking_results.csv`. This file contains the ligand names and the corresponding docking scores.

## Supported Formats for Ligand Files

The binary accepts the following ligand file formats for conversion to `.pdbqt` format:
- `.sdf`
- `.mol2`
- `.pdb`

Ligand files must be located in the current directory.
## Troubleshooting

- If you receive an error about missing docking software, ensure that **Vina**, **Smina**, and **QVina** are correctly installed and included in your system's PATH.
- If ligand file conversion fails, check that OpenBabel is installed and accessible in the PATH.

---
