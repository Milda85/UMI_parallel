#!/bin/bash


# Function to display help message
show_help() {
    echo ""
    echo "UMI Deduplication with GNU Parallel"
    echo "This script facilitates the parallel deduplication of bam files based on UMIs (Unique Molecular Identifiers)"
    echo "using umi_tools dedup. It assumes that the FASTQ files were processed with umi_tools extract before mapping"
    echo "and thus the UMI is the last word of the read name. It enables processing multiple files simultaneously,"
    echo "leveraging GNU Parallel to efficiently utilize computational resources."
    echo ""
    echo "Prerequisites:"
    echo "  - umi_tools: Required for UMI deduplication from sequencing data."
    echo "  - GNU Parallel: Used for efficient parallel processing."
    echo "Ensure both are installed and available in the system's PATH."
    echo ""
    echo "Usage: para_umi_dedup.sh [options]"
    echo "Options:"
    echo "  -i  <path>    Specify the input directory containing .bam files."
    echo "  -o  <path>    Specify the output directory for deduplicated files (default: current directory)."  
    echo "  -t  <integer> Specify the number of CPUs to use for parallel processing."
    echo "  -f  <path>    Specify the path to the configuration file containing UMI tools dedup options."
    echo "  -h, --help    Show this help message and exit."
    echo ""
    echo "Example:"
    echo " para_umi_dedup.sh -i /path/to/input -t 4 -c TRUE -o /path/to/output -f umi_options.conf"
    echo ""
    echo "This example processes files in /path/to/input using 4 CPUs, with UMI deduplication"
    echo "options specified in umi_options.conf, compresses the output files, and writes them to /path/to/output."
}

# Function for UMI deduplication with GNU Parallel

parallel_umi_dedup() {
    local file="$1"
    local output_dir="$2"
    local config_file="$3"
    local base_name
    base_name=$(basename "$file" .bam)
    local output_file="${output_dir}/${base_name}.dedup.bam"

    # Apply configuration and run umi_tools dedup
    cat "$config_file" | xargs umi_tools dedup --stdin="$file" --stdout="${output_file}" --log="${output_file}.log"
    
    echo "UMI deduplication completed for $base_name.bam"
}

export -f parallel_umi_dedup

# Main function to parse arguments and run the deduplication process
umi_dedup () {
    local INPUT_DIR
    local OUTPUT_DIR="."
    local CONFIG_FILE
    local CPUs

    # Parse command line options
        while getopts ":i:o:t:f:h" opt; do
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

    find "$INPUT_DIR" -name '*.bam' | parallel -j "$CPUs" parallel_umi_dedup {} "$OUTPUT_DIR" "$CONFIG_FILE"

}

# If no arguments, show help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

umi_dedup "$@"
