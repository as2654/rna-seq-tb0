import pandas as pd
import sys
import os
import os.path

print("Input to split_accessions.py is:", sys.argv[1:])

n_cores = sys.argv[1] # each process gets this many cores
mem = sys.argv[2]  # each process gets this much memory
n_workloads = int(sys.argv[3]) # this many concurrent processes allowed
input_tsv = sys.argv[4] # the accesiosn to process
work_dir = sys.argv[5] # where to be working
max_runtime = sys.argv[6] # max runtime before node closed
bt2index = sys.argv[7] # genome index prefix for alignment with bowtie2
annotations = sys.argv[8] # genome annotations
adapters = sys.argv[9] # for removal with bbduk
feature = sys.argv[10] # for featureCounts
runtag = sys.argv[11] # user defined string
runid = sys.argv[12] # random string 
script_dir = sys.argv[13] # where scripts should be written
main_script_loc = sys.argv[14] # where the main scripts (process single/paired acc).sh
print(script_dir)

df = pd.read_csv(sys.argv[4], header=0, sep="\t")


# make sure checkign working directory for completed accessions
os.chdir(work_dir)

groups = [[] for k in range(n_workloads)]
group_iter = 0

main_arg = " " + n_cores + " " + mem + " " + work_dir + " " + adapters + " " + bt2index + " " + annotations + " " + feature + " " + runtag

# extract accessions, produce command for each XRR run
# librarylayout influences which script is called
for k in range(df.shape[0]):
    for run in df['Run'][k].split(";"):
        if run not in str(os.listdir(".")) or True: # avoid processing completed samples
            if df['LibraryLayout'][k]=="SINGLE":
                groups[group_iter % len(groups)].append("/bin/sh " + main_script_loc + "/process_single_end_accession.sh " + run + main_arg)
            elif df['LibraryLayout'][k]=="PAIRED":
                groups[group_iter % len(groups)].append("/bin/sh " + main_script_loc + "/process_paired_end_accession.sh " + run + main_arg)
            group_iter += 1
        else:
            print("Skipping " + run)

# script_dir is where these scripts are run from by other processes
# NOTE this script ("split_accessions.py") must be run from the same
#      location as split_accessions.sh
os.chdir(work_dir + "/" + script_dir)

file_names = []

# each workload needs to be parameterized and given work
for k in range(n_workloads):
    #print("Group " + str(k))
    file_names.append((str(k) + "_" + runid + ".sh"))
    with open(file_names[-1], "w") as file:
        file.write("#!/bin/bash\n")
        file.write("#SBATCH --partition=main\n")
        file.write("#SBATCH --requeue\n")
        file.write("#SBATCH --job-name=" + runid + "\n")
        file.write("#SBATCH --ntasks=1\n")
        file.write("#SBATCH --cpus-per-task=" + n_cores + "\n")
        file.write("#SBATCH --mem=" + mem + "\n")
        file.write("#SBATCH --time=" + max_runtime + "\n")
        file.write("#SBATCH --output=" + runid + str(k) + ".log.txt\n")
        for line in groups[k]:
            file.write(line + "\n")
            #print(line)
        file.write("exit\n")
    #print("\n")

# write master script to submit all jobs
with open("exec_" + runid + ".sh", "w") as file:
    for fn in file_names:
        file.write("sbatch " + fn)
        file.write("\n")
        


