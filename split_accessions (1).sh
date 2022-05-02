#!/bin/sh
echo "Each job will have $1 cores and $2MB memory"
echo "Will create $3 concurrent workloads"
echo "Splitting accessions $4 into $3 groups"

exec_loc=$(pwd)
rundate=$(date +"%Y_%m_%d")
runid=$(uuidgen)

echo "The working directory is: $5"
echo "Max running time for jobs is $6"

echo "bowtie2 index prefix is $7"
echo "Genome annotation file is $8"
echo "Remove adapters from $9"
echo "featureCounts will use attribute $10"
echo "Unique ID for these runs will be $11"

cd $5

script_dir="script_dir_$runid"
echo "Scripts for all these processes are in $script_dir"
mkdir $script_dir

cmd1="python3 $exec_loc/split_accessions.py $@ $runid $script_dir $exec_loc"
echo "RUNNING - $cmd1"
$cmd1

cmd2="/bin/sh $script_dir/exec_$runid.sh"
echo "RUNNING - $cmd2"
$cmd2


