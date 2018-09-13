#!/bin/bash

#***************************************************************#
#              extracts metadata from MiSeq fastq files         #
#***************************************************************#


(echo -e "file\tinstrument\trun_num\tflowcell_id\tlane\ttile\tx-pos\ty-pos\tread\tis_filtered\tctrl_num\tsample_num"
for file in data/raw/*.fastq
do
	echo -ne "${file}\t"
	head -1 $file | 
	sed -E 's/ /:/' | 
	cut -d ':' -f1-11 | 
	tr ':' '\t'
done
) > metadata.tsv


# some help

# Need to work out how to cut the space and the final four colon columns
# http://support.illumina.com/content/dam/illumina-support/help/BaseSpaceHelp_v2/Content/Vault/Informatics/Sequencing_Analysis/BS/swSEQ_mBS_FASTQFiles.htm
# https://unix.stackexchange.com/questions/87529/using-cut-awk-sed-with-two-different-delimiters
# https://spriggsy83.github.io/regex-tutorial/

# @M01177:43:000000000-AU3ED:1:1101:9742:1105 1:N:0:1
# NATTCCGGAAACTTAAATGAATTGACGGGGGCCCGCACAAGCAGCGGAGCATGTTCTTTAATTCGATGCAACGCGAAGAACCTTACCTGGGCCTGACATGCATCTCTNAGGAGNNGNAAGCCGTCGAGTTCCGCNAGGANCNNNNNNNANANGTNNNNCANGNCTNTNNTNNGNNCGTGTCGTGNGNNNNNNNGTTANNTCNCGCNNNNNNNNNAACCCTTGTNACCTGNTGCCACCGGCCNNNNNNNNGAGCACTNNNNNNNNNNNGNNCTGTNGNNNNNGGAGNAAGGTGGGGATGCCG
# +
# #8ACCFGGGGGGGGFFGGGGGGGFGFG>FGCEGE:F7:FGGGGGGCEGGGG,FD9F99?FDCFGGG<<FFGGGCCGGGGG8F@FF,BE?<FFDEGGFG9FGGGFFDE#:BD+B##:#::A+BCFGGGEFGGFCF#+3+:#:#######6#3#65####56#6#66#1##4##6##164;CCGBC#1#######*414##44#4/;#########*21C;*282#2**:8#2;@8=C8EGEE########2**12;+###########1##1*/*#*#####11*/#//*9*).)))8B))0