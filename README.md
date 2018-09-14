# AFDS First Big Data Challenge
*Mark Farrell, CSIRO Agriculture & Food*

The original Markdown syntax specification can be found [here](http://daringfireball.net/projects/markdown/syntax).
A more helpful Markdown cheat sheet is available [here] (https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet). All this was written in [MacDown](https://macdown.uranusjr.com/).

___

## Data management plan
It's much easier to make a start on this and consider how you will be making your data available in the longer term. The [data management plan](https://confluence.csiro.au/display/RDM/Research+Data+Planner) provides a comprehensive set of concepts that require consideration, including metadata formats, licenses and inherited licenses. Default *home* for the raw and processed data is likely [CSIRO's Data Access Portal](https://data.csiro.au/dap/home?execution=e1s1), with workflow deposited in [Github](https://github.com/).

___

## Setting up the workplace environment
* Start new project in Github
* `git clone` the github project to home directory
* Get started on the `README.md`
* Make a bash script to build a sensible folder structure, called `dir.sh`, and add a `.gitignore` file which excludes the data directory, images, zips, and other files that shouldn't be tracked in github
* Push to Github in preparation for running on pearcey
* SSH into pearcey, navigate to `/flush1/far218` and `git clone`
* `rsync -vhra dir/where/files/are/ ./the/data/structure/` to copy the raw files to the appropriate folder
* Write / modify bash script to extract metadata from the .fastq files



### Directory structure
To have an ordered workspace that is clean, easy to navigate, and ensures that code changes etc. are tracked whilst not trying to commit large data or output files to Github, it is important that a standard working structure of directories is created. This can be done in a simple bash script. 

```sh
#!/bin/bash

#***************************************************************#
#              makes directory structure                        #
#***************************************************************#

# should be run from the root of your working directory

mkdir data/
mkdir data/raw/
mkdir data/working/
mkdir data/processed/
mkdir scripts/
mkdir outputs/
mkdir logs/
```
When written and saved, simply run `sh dir.sh`
___

## Pre-processing of data
A lot of technical data on the quality of the molecular data, and the factors within the run (e.g. lanes, etc) can be gleaned by some relatively simple steps. This can be very useful as a check for final analysis to see if there is any systematic bias resulting from the machine or lane in which an individual sample ran on.

### Metadata extraction
First of these is to extract the metadata. For MiSeq data, at the most basic level, metadata can be extracted from the first row of the sequence files. A short script to do this is displayed below:

```
#!/bin/bash

#***************************************************************#
#              extracts metadata from MiSeq fastq files         #
#***************************************************************#


(echo -e "file\tinstrument\trun_num\tflowcell_id\tlane\ttile\tx-pos\ty-pos\tread\tis_filtered\tctrl_num\tsample_num"
for file in data/raw/*.fastq
do
        echo -ne "${file}\t"
        head -1 $file |
        grep -E '^@' |
        sed -E 's/ /:/' | 
        cut -d ':' -f1-11 | 
        tr ':' '\t'
done | sort -V) > data/working/metadata_raw.tsv
```

Order of operations is as follows

* The first `echo` writes the columne headers, taken from [the Illumina help pages](http://support.illumina.com/content/dam/illumina-support/help/BaseSpaceHelp_v2/Content/Vault/Informatics/Sequencing_Analysis/BS/swSEQ_mBS_FASTQFiles.htm)
*  The `for` loop iterates through all the .fastq files
*  The second `echo` prints the file name and a tab, `-ne` means no new line, and allow extended (special) characters
*  `head` reads the opening lines of each file, limited to the first by `-1`
*  `grep -E '^@'` is redundant here, but in cases where more lines were beingprinted from `head` or `cat`, this would find only lines that begin with "@", i.e. sequence headers
*  As these Illumina files have two parts to the header which are separated by a space character. Here, `sed` is used to find the space and replace it with a ":", which matches the other delimiters. Transliterate (`tr`) would also work
*  We then split the file using `cut`. Here `-d` delimits on the specified character, and `-f` tells it that we want all 11 fields. These can be specified with a mixture of commas and hyphens.
*  The colons are then transliterated to tabs
*  The loop is finished, content is sorted, then piped to an output file

This is a bit of an unfinished task. Ideally I'd also like to extract quality data for each read. I've been trying to do this within the existing loop, but get caught out as the filename is only echoed once. Some alternatives might be:

1. To use `sed` to insert the filename and a tab as part of the loop under `head`/`cat`, rather than `echo`ing it at the start of the `for` loop.
2. To not use the bracketed loop to pipe to one file, and instead append `>>` for each file in the loop. **TBC...**

It's worth noting that this last part in some ways is a purely academic exercise. To do this for every read would generate a multi-GB sized file as the header info makes us a significant proportion of the whole .fastq file. In the case of these files, they will need demultiplexing in Qiime to generate 42 .fastq files for each amplicon (16S, 18S, ITS). Metadata would then be extracted from the header of these files using the `meta_one_line.sh` script above.

### Run Fastqc to assess quality of the data
Fastqc is a simple tool that outputs .zip and .html files which give a visualisation. We're now getting to the stage where jobs are bigger and should be submitted as batches or batch array jobs using `slurm`. Some examples of this are provided [here](https://confluence.csiro.au/download/attachments/278168292/ScientificComputingIntroductionWorkshop.pdf?version=4&modificationDate=1423198599850&api=v2), and [here](https://confluence.csiro.au/display/BIOK/Slurm+array+job+examples). [The Slurm page](https://slurm.schedmd.com/sbatch.html) is also very helpful. The script used to submit this as an array job for teh 12 .fastq files as supplied from the sequencer facility is `fastqc.sh`. (Though note that this should be modified and re-run after the files are demuxed)

```
#!/bin/bash

#***************************************************************#
#               runs fastqc on gzipped raw data files           #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=fastqc
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=4gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mark.farrell@csiro.au
#SBATCH --output=logs/fastqc_%A.out
#SBATCH --array=0-11

#----------------------project variables------------------------# 
IN_DIR=/flush1/far218/AFDS-TREND-example/data/raw/
OUT_DIR=/flush1/far218/AFDS-TREND-example/data/working/FastQC

#---------------------------------------------------------------#

mkdir -p $OUT_DIR
module load fastqc

IN_FILE_LIST=( $(ls ${IN_DIR}/*.fastq) );

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
        i=$SLURM_ARRAY_TASK_ID
        IN_FILE=${IN_FILE_LIST[$i]}
        fastqc ${IN_FILE} --noextract -o ${OUT_DIR}
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi
```
To run the array job, the command takes the form `sbatch -a (startIndex)-(endIndex) mySlurmScript.sh`. So for the immediate script above, the command would be `sbatch -a 0-11 fastqc.sh`. N.B. in both the script and the command, numbering starts at zero. N.B. also that the logs folder must already exist.

Walking through the above script, we see:

* Time (hhh:mm:ss) - keep under 2 h to gain access to shortest queue. However, if you're not done in two hours the process(es) will be killed. This might take a bit of playing with
* `--nodes` requests the minimum amount of nodes for the job
* `--ntasks-per-node` is the maximum number of tasks to be run on each node
* `--mem` is the amount of memory available for each node. As with time, this may need fine tuning, but best to start low
* `--output` - this folder must exist before running the script or no outut will be recorded (the script will still run)
* `--array` selects the jobs to be run
* Project variables are pretty simple at this stage, but could be more complex depending on the script to be executed
* The `-p` option on `mkdir` makes all intermediate directories as required
* The list is then assembled from the file names
* The `if` checks that this has an array task ID, then `$SLURM_ARRAY_TASK_ID` is re-mapped as `i` for convenience
* `fastqc` is then set to run on each file in the list

The files can then be viewed in a browser, with interpretation guidance available [here](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).

### MultiQC
This is a bit of a fudge on Pearcey, requiring Python 2.7.13 before it is run. For the small number of samples / data here, running from the login node is fine. However, it may need running as a submitted batch for bigger jobs.

```
module load python/2.7.13
multiqc FastQC/
```

This outputs an html file and a folder. Help on interpreting is available [here](http://multiqc.info/). Also interpretation is on the excellently designed webpage. However, it's worth noting thats ome of these quality aspects are less of a concern in some cases for the sort of multiplexed metagenomic data I will be dealing with.

### Further insights into metadata and QC
The next steps would be to take the metadata and sequence quality / numbers data into R to look for systematic differences between samples across machines / lanes. In my case this will need to be done after re/demux in qiime.






 
