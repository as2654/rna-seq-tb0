# rna-seq-tb0

Running split_accessions.sh with the correct parameters will take all the rows in the given TSV
while, which should correspond to SRA accessions. For each SRR sequencing run under that
accession, and for whether that run is paired-end or single-end, a call is made  to the appropriate
script to get the counts for a given reference.
