#!/bin/bash

# Function to display help message
show_help() {
    echo ""
    echo "UMI Extraction with GNU Parallel"
    echo "This script facilitates the parallel extraction of UMIs (Unique Molecular Identifiers)"
    echo "from .fastq.gz files using umi_tools extract. It enables processing multiple files"
    echo "simultaneously, leveraging GNU Parallel to efficiently utilize computational resources."
    echo ""
    echo "Prerequisites:"
    echo "  - umi_tools: Required for UMI extraction from sequencing data."
    echo "  - GNU Parallel: Used for efficient parallel processing."
    echo "Ensure both are installed and available in the system's PATH."
    echo ""
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -i  <path>    Specify the input directory containing .fastq.gz files."
    echo "  -o  <path>    Specify the output directory for extracted files (default: current directory)."  
    echo "  -t  <integer> Specify the number of CPUs to use for parallel processing."
    echo "  -f  <path>    Specify the path to the configuration file containing UMI tools extract options."
    echo "  -c  <boolean> Specify whether to compress the output (TRUE or FALSE, default: FALSE)."
    echo "  -h, --help    Show this help message and exit."
    echo ""
    echo "Example:"
    echo "  $0 -i /path/to/input -t 4 -c TRUE -o /path/to/output -f umi_options.conf"
    echo ""
    echo "This example processes files in /path/to/input using 4 CPUs, with UMI extraction"
    echo "options specified in umi_options.conf, compresses the output files, and writes them to /path/to/output."
}

# Function for UMI extraction with GNU Parallel
parallel_umi_extract() {
    local file="$1"
    local compress="$2"
    local output_dir="$3"
    local config_file="$4"
    local base_name
    base_name=$(basename "$file" .fastq.gz)
    local output_file="${output_dir}/${base_name}.umi.fastq"

    if [[ "$compress" == "TRUE" ]]; then
        output_file+=".gz"
        cat "$config_file" | xargs umi_tools extract --stdin="$file" --stdout=/dev/stdout --log="${output_file}.log" | gzip > "${output_file}"
    else
        cat "$config_file" | xargs umi_tools extract --stdin="$file" --stdout="${output_file}" --log="${output_file}.log"
    fi
    echo "UMI extraction completed for $base_name.fastq.gz"
}

export -f parallel_umi_extract

# Main function to parse arguments and run the extraction process
umi_extract() {
    local INPUT_DIR
    local OUTPUT_DIR="."
    local CONFIG_FILE
    local CPUs
    local COMPRESS="FALSE"

    while getopts ":i:o:t:f:c:h" opt; do
        case ${opt} in
            i )
                INPUT_DIR=$OPTARG
                ;;
            o )
                OUTPUT_DIR=$OPTARG
                ;;
            t )
                CPUs=$OPTARG
                ;;
            f )
                CONFIG_FILE=$OPTARG
                ;;
            c )
                COMPRESS=$(echo "$OPTARG" | tr '[:lower:]' '[:upper:]')
                ;;
            h )
                show_help
                exit 0
                ;;
            \? )
                echo "Invalid Option: -$OPTARG" 1>&2
                exit 1
                ;;
            : )
                echo "Invalid Option: -$OPTARG requires an argument" 1>&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    if [ ! -d "$OUTPUT_DIR" ]; then
        echo "Creating output directory: $OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
    fi

    find "$INPUT_DIR" -name '*.fastq.gz' | parallel -j "$CPUs" parallel_umi_extract {} "$COMPRESS" "$OUTPUT_DIR" "$CONFIG_FILE"

}

# If no arguments, show help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

umi_extract "$@"
