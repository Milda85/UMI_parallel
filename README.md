# UMI_parallel

## Overview

`UMI_parallel` is designed to facilitate the parallel processing `umi_tools extract` and `umi_tools dedup`. The primary motivation for creating this tool was to address a limitation of the current `umi_tools`—its inability to utilize parallel processing.
The tool is designed to be used in a UNIX-like environment and is implemented as a shell script that utilizes GNU Parallel for parallel processing.

## Prerequisites

Before using `UMI_parallel`, ensure you have the following software installed and available in your system's PATH:

- [umi_tools](https://github.com/CGATOxford/UMI-tools): Required for UMI extraction from sequencing data.

```
conda install -c bioconda -c conda-forge umi_tools
```

or

```
pip install umi_tools
```

- [GNU Parallel](https://www.gnu.org/software/parallel/): Utilized for efficient parallel processing of multiple files.
```
sudo apt-get install parallel
```

Always give credit to the original authors of the tools by citing their work:
- umi_tools: Smith, T., Heger, A., & Sudbery, I. (2017). UMI-tools: modeling sequencing errors in Unique Molecular Identifiers to improve quantification accuracy. Genome Research, 27(3), 491–499. https://doi.org/10.1101/gr.209601.116

- GNU Parallel: Tange, O. (2011). GNU Parallel - The Command-Line Power Tool. The USENIX Magazine, 36(1), 42–47. https://doi.org/10.5281/zenodo.16303

## Installation

To install `UMI_parallel`, simply clone the repository and add the `bin` directory to your system's PATH:

```
git clone
cd UMI_parallel
export PATH=$PATH:$(pwd)/bin
```

## Usage

### UMI extraction
```
para_umi_extract.sh
```
This script facilitates the parallel extraction of UMIs (Unique Molecular Identifiers)from .fastq.gz files using umi_tools extract. It enables processing multiple files
simultaneously, leveraging GNU Parallel to efficiently utilize computational resources. So far tested with `--method=regex` option for UMI extraction.
    
```
para_umi_extract.sh -i <path> -o <path> -t <integer> -f <path> -c <boolean>

Options:
  -i  <path>    Specify the input directory containing .fastq.gz files.
  -o  <path>    Specify the output directory for UMI extracted files (default: current directory).  
  -t  <integer> Specify the number of CPUs to use for parallel processing.
  -f  <path>    Specify the path to the configuration file containing UMI tools extract options.
  -c  <boolean> Specify whether to compress the output (TRUE or FALSE, default: FALSE).
  -h, --help    Show this help message and exit.


Example:
 para_umi_extract.sh -i /path/to/input/dir -t 4 -c TRUE -o /path/to/output/dir -f umi_options.conf
```
This example processes files in /path/to/input using 4 CPUs, with UMI extraction
options specified in umi_options.conf, compresses the output files and writes them to /path/to/output.

#### Expected Input and Output

The script expects input files in the format `basename.fastq.gz`. Based on the compression option selected (`-c`), the output files will be named either `basename.umi.fastq.gz` (if compression is enabled with `-c TRUE`) or `basename.umi.fastq` (if compression is disabled with `-c FALSE`).

#### Configuration File

The configuration file should list `umi_tools extract` options as defined in the [umi_tools documentation](https://umi-tools.readthedocs.io/en/latest/reference/extract.html), with one option per line. Do not include the input (`--stdin=`), output (`--stdout=`) and log (`--log=`) file options, as these are managed by the script.

## Performance and Testing

`UMI_parallel` has been thoroughly tested on Ubuntu 22.04. During these tests, it was observed that running the tool on systems with Solid State Drives (SSDs) significantly enhances the performance of `umi_tools extract`, and `umi_tools dedup` leading to faster processing times. However, when the tool is used with Hard Disk Drives (HDDs), the performance improvement is less pronounced.

## Disclaimer
This tool is provided as is, without any warranty or guarantee of its performance. The user assumes full responsibility for the use of this tool and any associated data. The authors are not responsible for any damages or loss of data as a result of using this tool.

