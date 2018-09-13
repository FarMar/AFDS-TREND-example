#!/bin/bash

#***************************************************************#
#              extracts metadata from MiSeq fastq files         #
#***************************************************************#


(echo -e "file\tinstrument\trun_num\tflowcell_id\tlane\ttile\tx-pos\ty-pos\tread\tis_filtered\tctrl_num\tsample_num"
for file in data/raw/*.fastq
do
        echo -ne "${file}\t"
        head $file |
        grep -E '^@' |
        sed -E 's/ /:/' | 
        cut -d ':' -f1-11 | 
        tr ':' '\t'
done | sort -V) > data/working/metadata_raw.tsv

# have grep to anchor the @, but only pulls filename for first loop