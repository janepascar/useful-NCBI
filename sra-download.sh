#!/bin/bash
# Jane A. Pascar
# 2019-01-22
# run on the command line: nohup bash ./sra-download.sh [.txt with accession #s] [path to output directory] > output.txt &
# Output: 
  # 1. sequencing data will be output as [sra accession #].fastq to specified directory
    # Paired end data will be split into forward and reverse reads and singletons;
    # FWD *_1.fastq, REV *_2.fastq, unpaired *.fastq
  # 2. If you redirect the stdout to a .txt file it includes any errors retrieving data from NCBI
  # Also included some info about total runtime
date # start date and time will be reported
startmin=$(date +%M)
starthr=$(date +%H)
startday=$(date +%j)

# check to make sure that both arguments are provided
if [ -z $1 ]; then 
	echo "ERROR: Missing .txt file containing NCBI SRA accession numbers"
    exit 1
fi

if [ -z $2 ]; then 
	echo "ERROR: Missing path to output directory"
	exit 1
fi

# This runs if both arguments are supplied: 
if [ "$#" == 2 ]; then
	ACC=$1
	DIR=$2
	while read CUR_ACC; do
		echo "*** BEGINNING TO DOWNLOAD ${CUR_ACC} ***"
    		fastq-dump --readids --outdir ${DIR} --origfmt --skip-technical --split-3 ${CUR_ACC}
    		echo "*** ${CUR_ACC} DOWNLOAD COMPLETE ***"
	done <${ACC}
	echo "*** SCRIPT COMPLETE ***"
	endmin=$(date +%M)
	endhr=$(date +%H)
	endday=$(date +%j)   
	runtimemin=$(python -c "print(${endmin} - ${startmin})")
	runtimehr=$(python -c "print(${endhr} - ${starthr})")
	runtimeday=$(python -c "print(${endday} - ${startday})")
	echo "Total Time: ${runtimeday} Day(s), ${runtimehr} Hour(s), ${runtimemin} Minute(s)"
	exit 0
fi
