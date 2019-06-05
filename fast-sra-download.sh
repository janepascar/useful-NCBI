#!/bin/bash
# Jane A. Pascar
# 2019-06-04

# purpose: download sequencing data stored in the NCBI SRA locally using Aspera for higher speed transfer
# usage: nohup ./sra-download.sh [.txt with accession #s] [output directory for .sra files] [output directory for fastq files] > output.txt &
# requirements: 
	# 1. SRA toolkit: https://github.com/ncbi/sra-tools
	# 2. Aspera: https://www.ncbi.nlm.nih.gov/books/NBK242625/
# output: 
  # 1. .sra formatted files will be downloaded using Aspera to the specified directory
  # 2. .sra files will be converted to fastq format using the SRA toolkit and stored in the specified directory 
    # Paired end data will be split into forward and reverse reads and singletons;
    # FWD *_1.fastq, REV *_2.fastq, unpaired *.fastq

# check to make sure that all arguments are provided
if [ "$#" -ne 3 ]; then
	echo "ERROR: Incorrect number of arguments supplied."
	echo "Correct syntax: ./sra-download.sh [.txt with accession #s] [output directory for .sra files] [output directory for fastq files]"
fi

# This runs if all arguments are supplied: 
if [ "$#" == 3 ]; then
	ACC=$1
	SRA_OUT=$2
	FASTQ_OUT=$3

	while read CUR_ACC; do
    	echo "Beginning to download ${CUR_ACC} .sra file..."
        # Download the .sra file using Aspera, if fasp (fast & secure protocol) is not available it will default to download via http
        # can increase verbosity of output by adding additional -v flags
        /nfs6/japascar/bin/sratoolkit.2.9.4-2-ubuntu64/bin/prefetch -a "/nfs6/japascar/.aspera/connect/bin/ascp|/nfs6/japascar/.aspera/connect/etc/asperaweb_id_dsa.openssh" -v -O ${SRA_OUT} ${CUR_ACC}
	done <${ACC}

	# need to convert the .sra files to FASTQ format using the SRA tools
	# --readids: Append read id after spot id as 'accession.spot.readid' on defline
	# --origfmt: Defline contains only original sequence name.
	# --skip-technical: Dump only biological reads.
	# --split-files: Dump each read into separate file. Files will receive suffix corresponding to read number.
	while read CUR_ACC; do
	echo "Beginning to convert ${CUR_ACC}.sra file to FASTQ format..."
	cd ${SRA_OUT}
        /nfs6/japascar/bin/sratoolkit.2.9.4-2-ubuntu64/bin/fastq-dump --readids --outdir ${FASTQ_OUT} --origfmt --skip-technical --split-files -X 5 ${CUR_ACC}.sra
	done <${ACC}
	
	if [ $? -eq 0 ]
	then
  		echo -e "\U0001f917 The script ran ok \U0001f44D \U0001f44D \U0001f44D"
  		exit 0
	else
  		echo -e "\U0001f630 Something went wrong \U0001f44E"
  		exit 1
	fi
fi
