(echo -e "filename\tsample\treadNum\tinstrument\trunID\tflowcellID\tlane"
for myfile in *.fastq
do 
	echo -ne "${myfile}\t"
	echo -n "${myfile}" | cut -d - -f 2 | tr '\n' '\t'
	echo -n "${myfile}" | cut -d _ -f 5 | cut -d . -f 1| tr '\n' '\t' 
	head -n 1 $myfile | cut -d ':' -f 1-4 | tr ':' '\t'
	done | sort -V) > ../raw_metadata/fastq_meta.tsv