/bin/sh /scratch/as2654/build_compendium.0/split_accessions.sh \
    8 \
    16000 \
    8 \
    /scratch/as2654/build_compendium.0/Mtb_0_sorted_H37Rv.tsv \
    /scratch/as2654/build_compendium.0/work_dir_NCBI \
    48:30:00 \
    GCF_000195955.2_ASM19595v2_genomic \
    GCF_000195955.2_ASM19595v2_genomic.gtf \
    $HOME/bbmap/resources/adapters.fa \
    gene \
    _NCBI

/bin/sh split_accessions.sh \
    8 \
    16000 \
    12 \
    /scratch/as2654/build_compendium.0/Mtb_0_sorted_H37Rv.tsv \
    /scratch/as2654/build_compendium.0/work_dir_AllandRv \
    48:30:00 \
    H37Rv_Alland \
    H37Rv_Alland.gtf \
    $HOME/bbmap/resources/adapters.fa \
    transcript \
    _AllandRv