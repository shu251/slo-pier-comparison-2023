#!/bin/bash
echo "analyzing March 2022 data slo pier"

# Import data
echo "importing data"

qiime tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-path /home/skhu/slo-pier-comparison-2023/18S_AV_SequencingRawData_May2022/manifest22.tsv \
        --output-path slo-22-pe.qza \
        --input-format PairedEndFastqManifestPhred33V2

# Get starting stats on input sequences
qiime demux summarize \
        --i-data slo-22-pe.qza \
        --o-visualization slo-22-pe.qzv

# Remove 18S V4 primers
echo "run cutadapt"

qiime cutadapt trim-paired \
        --i-demultiplexed-sequences slo-22-pe.qza \
        --p-cores 4 \
        --p-front-f CCAGCASCYGCGGTAATTCC \
        --p-front-r ACTTTCGTTCTTGATYRA \
        --p-error-rate 0.1 \
        --p-overlap 3 \
       --p-match-adapter-wildcards \
        --o-trimmed-sequences slo-22-pe-trimmed.qza 

# Grab trim stats from cutadapt
qiime demux summarize \
        --i-data slo-22-pe-trimmed.qza \
        --o-visualization slo-22-pe-trimmed.qzv

# Run dada2
echo "executing dada2"
echo "threads queued" $OMP_NUM_THREADS

qiime dada2 denoise-paired \
        --i-demultiplexed-seqs slo-22-pe-trimmed.qza \
        --p-trunc-len-f 225 \
        --p-trunc-len-r 210 \
        --p-max-ee-f 2 \
        --p-max-ee-r 2 \
        --p-min-overlap 10 \
        --p-pooling-method independent \
        --p-n-reads-learn 100000 \
        --p-n-threads $OMP_NUM_THREADS \
        --p-chimera-method pooled \
        --o-table /scratch/user/skhu/slo-22-asv-table.qza \
        --o-representative-sequences /scratch/user/skhu/slo-22-ref-seqs.qza \
        --o-denoising-stats /scratch/user/skhu/slo-22-dada2-stats.qza

# Get dada2 stats
echo "dada2 stats"

qiime metadata tabulate \
  --m-input-file slo-22-dada2-stats.qza \
  --o-visualization slo-22-dada2-stats-summ.qzv


## Convert to TSV ASV table
echo "converting to TSV table"
qiime tools export \
        --input-path /scratch/user/skhu/slo-22-asv-table.qza \
	--output-path /scratch/user/skhu/slo-22-output/
        
biom convert -i /scratch/user/skhu/slo-22-output/feature-table.biom \
       -o /scratch/user/skhu/slo-19-output/slo-22-asv-table.tsv \
       --to-tsv

# Get dada2 stats
qiime metadata tabulate \
       --m-input-file /scratch/user/skhu/slo-22-dada2-stats.qza \
       --o-visualization /scratch/user/skhu/slo-22-dada2-stats.qzv

# Assign taxonomy
echo "assigning taxonomy, vsearch"
echo "threads queued" $OMP_NUM_THREADS

qiime feature-classifier classify-consensus-vsearch \
        --i-query /scratch/user/skhu/slo-22-ref-seqs.qza \
        --i-reference-reads /home/skhu/db/pr2_version_4.14_seqs.qza \
        --i-reference-taxonomy /home/skhu/db/pr2_version_4.14_tax.qza  \
        --o-classification /scratch/user/skhu/slo-22-output/slo-22-taxa.qza \
        --o-search-results /scratch/user/skhu/slo-22-output/slo-22-blast6.qza \
        --p-threads $OMP_NUM_THREADS \
        --p-maxaccepts 10 \
        --p-perc-identity 0.8 \
        --p-min-consensus 0.70
# Export taxonomy table
echo "final export taxonomy table step"

qiime tools export \
        --input-path /scratch/user/skhu/slo-22-output/slo-22-taxa.qza \
        --output-path /scratch/user/skhu/slo-22-output/
