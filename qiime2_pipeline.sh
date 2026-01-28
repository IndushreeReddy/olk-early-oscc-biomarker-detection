#!/bin/bash
# QIIME2 pipeline: OLK vs Healthy (16S rRNA)
# Author: Indushree

#Download and convert raw data
cat SRR.txt | parallel -j0 prefetch {}
ls *.sra | parallel -j0 fastq-dump --split-files --origfmt {}
mv *.fastq fastq/
mv *.sra sra/

#Manifest creation (paired-end import)
d fastq
gzip *.fastq

mkdir -p manifest
echo -e "sample-id\tforward-absolute-filepath\treverse-absolute-filepath" > manifest/manifest.tsv
for f in *_1.fastq.gz; do
  sample=${f%_1.fastq.gz}
  echo -e "${sample}\t$PWD/${sample}_1.fastq.gz\t$PWD/${sample}_2.fastq.gz"
done >> manifest/manifest.tsv

#Import into QIIME2
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path fastq/manifest/manifest.tsv \
  --output-path demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

#Demultiplex summary
qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv

#Denoising(forward reads only)
#Paired-end processing was attempted initially; due to poor reverse read quality, single-end DADA2 was used.
qiime dada2 denoise-single \
  --i-demultiplexed-seqs demux.qza \
  --p-trunc-len 230 \
  --p-n-threads 2 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza \
  --o-base-transition-stats base-transition-stats.qza

#DADA2 stats visualization
qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv

#Feature table summary
qiime feature-table summarize-plus \
  --i-table table.qza \
  --m-metadata-file sample_metadata.tsv \
  --o-summary table-summary.qzv \
  --o-sample-frequencies sample-frequencies.qza \
  --o-feature-frequencies feature-frequencies.qza

#Taxonomic assignment
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza \
  --p-n-jobs 2

#Taxa relative abundance barplot
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file sample_metadata.tsv \
  --o-visualization taxa-barplot.qzv

#Phylogenetic tree
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

#Diversity analysis
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 5000 \
  --m-metadata-file sample_metadata.tsv \
  --output-dir core-metrics-results

#Alpha diversity significance
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/shannon_vector.qza \
  --m-metadata-file sample_metadata.tsv \
  --o-visualization shannon-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file sample_metadata.tsv \
  --o-visualization faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file sample_metadata.tsv \
  --o-visualization evenness-group-significance.qzv

#beta diversity significance(PERMANOVA)
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --m-metadata-file sample_metadata.tsv \
  --m-metadata-column sample_type \
  --p-method permanova \
  --p-permutations 999 \
  --o-visualization bray-curtis-permanova.qzv

#Optional additional robustness test
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample_metadata.tsv \
  --m-metadata-column sample_type \
  --p-method permanova \
  --p-permutations 999 \
  --o-visualization weighted-unifrac-permanova.qzv

#Export data for Python statistics
qiime tools export --input-path table.qza --output-path exported-table
biom convert -i exported-table/feature-table.biom -o feature-table.tsv --to-tsv

qiime tools export --input-path taxonomy.qza --output-path exported-taxonomy