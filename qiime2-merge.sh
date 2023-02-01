#!/bin/bash

echo "merging may 2022 and march 2019 sequence runs"

#qiime feature-table merge \
#	--i-tables /home/skhu/slo-pier-comparison-2023/march2019-output/slo-19-asv-table.qza \
#	--i-tables /home/skhu/slo-pier-comparison-2023/may2022-output/slo-22-asv-table.qza \
#	--o-merged-table /scratch/user/skhu/slo-merged-asv-table.qza

qiime feature-table merge-seqs \
        --i-data /home/skhu/slo-pier-comparison-2023/march2019-output/slo-19-ref-seqs.qza \
        --i-data /home/skhu/slo-pier-comparison-2023/may2022-output/slo-22-ref-seqs.qza \
        --o-merged-data /scratch/user/skhu/slo-merged-ref-seqs.qza


# Assign taxonomy
echo "assigning taxonomy, vsearch"
echo "threads queued" $OMP_NUM_THREADS

qiime feature-classifier classify-consensus-vsearch \
        --i-query /scratch/user/skhu/slo-merged-ref-seqs.qza \
        --i-reference-reads /home/skhu/db/pr2_version_4.14_seqs.qza \
        --i-reference-taxonomy /home/skhu/db/pr2_version_4.14_tax.qza  \
        --o-classification /scratch/user/skhu/slo-merged-output/slo-merged-taxa.qza \
        --o-search-results /scratch/user/skhu/slo-merged-output/slo-merged-blast6.qza \
        --p-threads $OMP_NUM_THREADS \
        --p-maxaccepts 10 \
        --p-perc-identity 0.8 \
        --p-min-consensus 0.70

# Export taxonomy table
echo "final export taxonomy table step"

qiime tools export \
        --input-path /scratch/user/skhu/slo-merged-output/slo-merged-taxa.qza \
        --output-path /scratch/user/skhu/slo-merged-output/


echo "converting to TSV table"
qiime tools export \
        --input-path /scratch/user/skhu/slo-merged-asv-table.qza \
        --output-path /scratch/user/skhu/slo-merged-output/
        
biom convert -i /scratch/user/skhu/slo-merged-output/feature-table.biom \
       -o /scratch/user/skhu/slo-merged-output/slo-merged-asv-table.tsv \
       --to-tsv
