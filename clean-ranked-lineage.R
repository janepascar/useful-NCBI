#!/usr/bin/env Rscript
# Jane A. Pascar
# 2019-01-28
# usage: Rscript --vanilla bracken_transform.R [directory to rankedlineage.dmp from NCBI FTP] [optional: path to output directory]
# if no output directory is specified, it will output to the same directory where the .dmp file is stored
# output: cleaned up rankedlineage.dmp file in .csv format

args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("Missing arguements! Indicate the directory that contains the rankedlineage.dmp file and the output directory for this script", call.=FALSE)
} else if (length(args)==1) {
  args[2] = args[1] # output will be directed to the same directory
}

library(readr)

# clean up the rankedlineage.dmp file from the NCBI taxonomy FTP site ----
  # the file is deliminated by "\t|\t" but i cant figure out how to have that read automatically so this is sooo messy
  # there are a bunch of hidden tabs since with the read_delim command I think I can only read one deliminator, "|"
lineage <- read_delim(file = paste(args[1], "rankedlineage.dmp", sep = ""), delim = "|", col_names = F, col_types = cols())
lineage <- lineage[, 1:10] # the last column is filled with NAs and is useless
header <- c("tax_id", "tax_name", "species", "genus", "family", "order", "class", "phylum", "kingdom", "superkingdom")
colnames(lineage) <- header
# Currently missing values are indicated by two tabs 
  # this replaces all of the missing values with NA
for (h in header) {
  lineage[[h]] <- gsub("\t\t", "NA", fixed = FALSE, x = lineage[[h]])
}
# Need to remove the "\t" before and after the strings in each column
# the first column only has "\t" at the end of the string
for (h in header) {
  lineage[[h]] <- gsub("\t$", "", x = lineage[[h]])
}
names <- c("tax_name", "species", "genus", "family", "order", "class", "phylum", "kingdom", "superkingdom")
for (n in names) {
  lineage[[n]] <- gsub("^\t", "", x = lineage[[n]])
}
# change appropriate columns to factors
col.name <- c("species", "genus", "family", "order", "class", "phylum", "kingdom", "superkingdom")
lineage[col.name] <- lapply(lineage[col.name], factor)  # as.factor() could also be used

write_csv(lineage, paste(args[2], "cleaned_rankedlineage.csv", sep = ""), col_names = T)
