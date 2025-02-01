#!/bin/bash


show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h                    Show this help message."
    echo "  -dock <vina|smina|qvina>  Choose the docking software to use."
    echo "  -exhaustiveness <int>   Set exhaustiveness (default: 16)."
    echo "  -cpu <int>              Set number of CPU cores (default: 1)."
    echo "  -grid <grid.txt>        Provide the grid configuration file."
    echo "  -convert <yes|no>       Convert ligand files to .pdbqt format (default: no)."
}

conversion_function() {
    WORKDIR="$(pwd)"
    ORIGINAL_DIR="$WORKDIR/Original_ligands"
    PDBQT_DIR="$WORKDIR/pdbqt_ligands"

    mkdir -p "$ORIGINAL_DIR" "$PDBQT_DIR"

    for file in "$WORKDIR"/*.{sdf,mol2,pdb}; do
        [ -e "$file" ] || continue
        filename=$(basename "$file" | cut -d. -f1)
        obabel "$file" -O "$PDBQT_DIR/${filename}.pdbqt" 

        if [ -f "$PDBQT_DIR/${filename}.pdbqt" ]; then
            mv "$file" "$ORIGINAL_DIR"
        else
            echo "Failed to convert $file"
        fi
    done

    echo "Conversion of ligand files completed"
}

vina_dock_function() {
    if [ ! -f "grid.txt" ]; then
        echo "Error: grid.txt file not found!"
        exit 1
    fi

    if [ $# -ne 2 ]; then
        echo "Usage: ./vina_dock.sh <exhaustiveness> <cpu>"
        exit 1
    fi

    EXHAUSTIVENESS=$1
    CPU=$2
    LIGAND_DIR="./pdbqt_ligands"
    RECEPTOR="receptor.pdbqt"
    OUTPUT_DIR="./docking_results"
    OUTPUT_CSV="docking_results.csv"  

    mkdir -p "$OUTPUT_DIR"

    echo "Ligand,Score1,Score2,Score3,Score4,Score5" > "$OUTPUT_CSV"

    for ligand in "$LIGAND_DIR"/*.pdbqt; do
        ligand_name=$(basename "$ligand" .pdbqt)
        output_file="$OUTPUT_DIR/${ligand_name}_docked.pdbqt"

        docking_output=$(vina --receptor "$RECEPTOR" --ligand "$ligand" --config grid.txt --exhaustiveness "$EXHAUSTIVENESS" --cpu "$CPU" --out "$output_file")

        echo "$docking_output"
        
        scores=$(echo "$docking_output" | grep -E "^[[:space:]]*[0-9]+[[:space:]]+[-+]?[0-9]*\.?[0-9]+" | awk '{print $2}' | head -n 5 | tr '\n' ',' | sed 's/,$//')

        if [ -n "$scores" ]; then
            echo "$ligand_name,$scores" >> "$OUTPUT_CSV"
        else
            echo "Docking failed for $ligand_name"
        fi
    done

    echo "Docking completed. Results stored in $OUTPUT_CSV"
}

smina_dock_function() {
    if [ ! -f "grid.txt" ]; then
        echo "Error: grid.txt file not found!"
        exit 1
    fi

    if [ $# -ne 2 ]; then
        echo "Usage: ./smina_dock.sh <exhaustiveness> <cpu>"
        exit 1
    fi

    EXHAUSTIVENESS=$1
    CPU=$2
    LIGAND_DIR="./pdbqt_ligands"
    RECEPTOR="receptor.pdbqt"
    OUTPUT_DIR="./docking_results"
    OUTPUT_CSV="docking_results.csv" 

    mkdir -p "$OUTPUT_DIR"

    echo "Ligand,Score1,Score2,Score3,Score4,Score5" > "$OUTPUT_CSV"

    for ligand in "$LIGAND_DIR"/*.pdbqt; do
        ligand_name=$(basename "$ligand" .pdbqt)
        output_file="$OUTPUT_DIR/${ligand_name}_docked.pdbqt"

        docking_output=$(qvina --receptor "$RECEPTOR" --ligand "$ligand" --config grid.txt --exhaustiveness "$EXHAUSTIVENESS" --cpu "$CPU" --out "$output_file")

        echo "$docking_output"
        
        scores=$(echo "$docking_output" | grep -E "^[[:space:]]*[0-9]+[[:space:]]+[-+]?[0-9]*\.?[0-9]+" | awk '{print $2}' | head -n 5 | tr '\n' ',' | sed 's/,$//')

        if [ -n "$scores" ]; then
            echo "$ligand_name,$scores" >> "$OUTPUT_CSV"
        else
            echo "Docking failed for $ligand_name"
        fi
    done

    echo "Docking completed. Results stored in $OUTPUT_CSV"
}

qvina_dock_function() {
    if [ ! -f "grid.txt" ]; then
        echo "Error: grid.txt file not found!"
        exit 1
    fi

    if [ $# -ne 2 ]; then
        echo "Usage: ./qvina_dock.sh <exhaustiveness> <cpu>"
        exit 1
    fi

    EXHAUSTIVENESS=$1
    CPU=$2
    LIGAND_DIR="./pdbqt_ligands"
    RECEPTOR="receptor.pdbqt"
    OUTPUT_DIR="./docking_results"
    OUTPUT_CSV="docking_results.csv"  

    mkdir -p "$OUTPUT_DIR"

    echo "Ligand,Score1,Score2,Score3,Score4,Score5" > "$OUTPUT_CSV"

    for ligand in "$LIGAND_DIR"/*.pdbqt; do
        ligand_name=$(basename "$ligand" .pdbqt)
        output_file="$OUTPUT_DIR/${ligand_name}_docked.pdbqt"

        docking_output=$(qvina --receptor "$RECEPTOR" --ligand "$ligand" --config grid.txt --exhaustiveness "$EXHAUSTIVENESS" --cpu "$CPU" --out "$output_file")

        echo "$docking_output"
        
        scores=$(echo "$docking_output" | grep -E "^[[:space:]]*[0-9]+[[:space:]]+[-+]?[0-9]*\.?[0-9]+" | awk '{print $2}' | head -n 5 | tr '\n' ',' | sed 's/,$//')

        if [ -n "$scores" ]; then
            echo "$ligand_name,$scores" >> "$OUTPUT_CSV"
        else
            echo "Docking failed for $ligand_name"
        fi
    done

    echo "Docking completed. Results stored in $OUTPUT_CSV"
}

DOCK_PROGRAM=""
EXHAUSTIVENESS=""
CPU=""
GRID_FILE=""
CONVERT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h)
            show_help
            exit 0
            ;;
        -dock)
            DOCK_PROGRAM="$2"
            shift 2
            ;;
        -exhaustiveness)
            EXHAUSTIVENESS="$2"
            shift 2
            ;;
        -cpu)
            CPU="$2"
            shift 2
            ;;
        -grid)
            GRID_FILE="$2"
            shift 2
            ;;
        -convert)
            CONVERT="$2"
            shift 2
            ;;
        *)
            echo "Invalid option: $1"
            show_help
            exit 1
            ;;
    esac
done

: ${EXHAUSTIVENESS:=16}
: ${CPU:=1}
: ${GRID_FILE:="grid.txt"}
: ${CONVERT:="no"}

if [ -z "$DOCK_PROGRAM" ]; then
    echo "Error: You must specify a docking program (vina, smina, or qvina)."
    show_help
    exit 1
fi

if [ "$CONVERT" == "yes" ]; then
    conversion_function
fi

if [ "$DOCK_PROGRAM" == "vina" ]; then
    echo "Running Vina..."
    vina_dock_function $EXHAUSTIVENESS $CPU
elif [ "$DOCK_PROGRAM" == "smina" ]; then
    echo "Running Smina..."
    smina_dock_function $EXHAUSTIVENESS $CPU
elif [ "$DOCK_PROGRAM" == "qvina" ]; then
    echo "Running QVina..."
    qvina_dock_function $EXHAUSTIVENESS $CPU
else
    echo "Error: Invalid docking program specified. Choose either vina, smina, or qvina."
    show_help
    exit 1
fi
