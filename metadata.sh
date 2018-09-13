#!/bin/bash

#***************************************************************#
#              extracts metadata from MiSeq fastq files         #
#***************************************************************#

$(echo -e "instrument\trun_num\tflowcell_id\tlane\ttile\tx-pos\ty-pos\t"
for file in data/raw/*.fastq; do echo -ne "${file}\t"
head -1 $file | cut -d':' -f1-7 | tr ':' '\t' 
done) > metadata.tsv


# some help

# Need to work out how to cut the space and the final four colon columns
# http://support.illumina.com/content/dam/illumina-support/help/BaseSpaceHelp_v2/Content/Vault/Informatics/Sequencing_Analysis/BS/swSEQ_mBS_FASTQFiles.htm
# https://unix.stackexchange.com/questions/87529/using-cut-awk-sed-with-two-different-delimiters
# https://spriggsy83.github.io/regex-tutorial/