#!/bin/sh
echo "Processing accession $1, allocated $2 cores and $3MB memory"
echo "Working in dir: $4"
echo "Removing adapters using: $5"
echo "bowtie2 index prefix is: $6"
echo "Genome annotation file is: $7"
echo "featureCounts will use attribute: $8"
echo "Unique tag for this run is: $9"

module load java
module load bowtie2
module load samtools

exec_loc=$PWD

# enter the work directory
command="cd $4"
echo "$(date +"%Y-%m-%d %T") RUNNING $command"
$command

# download the accession
command="fasterq-dump --threads $2 $1"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

# perform fastqc
command="fastqc -t $2 $1.fastq"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

command="rm -rf *.html"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

# remove adapters (all illumina)
command="/bin/sh bbduk.sh in=$1.fastq out=$1_c.fastq ref=$5 ktrim=r k=23 mink=11 hdist=1 stats=$1.bbdukstats tpe tbo"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

# perform quality trimming using a sliding window of 4 bases, average q of 20
command="java -jar $HOME/Trimmomatic-0.39/trimmomatic-0.39.jar SE -threads $2 $1_c.fastq $1_ct.fastq SLIDINGWINDOW:4:20"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command >> $1.trimmomaticstats 2>&1

# align reads to genome using bowtie2
command="bowtie2 --threads $2 -x $6 -U $1_ct.fastq -S $1.sam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command >> $1.bowtie2stats 2>&1

# convert sam to sorted bam for storage
command="samtools sort -o $1.bam $1.sam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
#$command

# assign alignments to features using featureCounts
command="featureCounts -T $2 -t $8 -g gene_id -a $7 -o $1_diff.counts.txt $1.sam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

command="rm -rf $1.sam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

command="rm -rf $1.bam"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command

command="rm -rf $1*.fastq"
echo "$(date +"%Y-%m-%d %T") RUNNING - $command"
$command
