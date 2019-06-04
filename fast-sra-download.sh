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
if [ -z $1 ]; then 
	echo "ERROR: Missing .txt file containing NCBI SRA accession numbers"
    exit 1
fi

if [ -z $2 ]; then 
	echo "ERROR: Missing path to output directory for .sra files"
	exit 1
fi

if [ -z $3 ]; then 
	echo "ERROR: Missing path to output directory for .fastq files"
	exit 1
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

	while read CUR_ACC; do
		echo "Beginning to convert ${CUR_ACC}.sra file to FASTQ format..."
        /nfs6/japascar/bin/sratoolkit.2.9.4-2-ubuntu64/bin/fastq-dump --readids --outdir ${FASTQ_OUT} --origfmt --skip-technical --split-files ${SRA_OUT}/${CUR_ACC}.sra
	done <${ACC}
	
	if [ $? -eq 0 ]
	then
  		echo "The script ran ok :D"
  		exit 0
	else
  		echo "Something went wrong :("
  		exit 1
	fi
fi
