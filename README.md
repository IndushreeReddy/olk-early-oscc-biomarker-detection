# **Oral Leukoplakia Microbiome Analysis (16S rRNA + Machine Learning)**

## **Overview**

Oral squamous cell carcinoma (OSCC) accounts for the majority of oral cancers and is often diagnosed at advanced stages. Oral leukoplakia (OLK) is the most common oral potentially malignant disorder and is widely recognised as a marker of increased oral cancer risk. Recent evidence suggests that oral microbiome dysbiosis may contribute to carcinogenesis through inflammation, immune modulation, and carcinogenic metabolites.

This project investigates whether oral microbiome profiles from non-invasive oral swabs can be used to distinguish Healthy vs Pre-cancerous (OLK) samples using:
* 16S rRNA (V1-V2) sequencing analysis with QIIME2
* statistical analysis + visualisation in Python
* machine learning classifiers (Logistic Regression, Random Forest) for prediction and biomarker discovery

## **Objectives**
* Characterise and compare oral bacterial communities in Healthy vs OLK/pre-cancerous samples using 16S rRNA gene sequencing
* Identify diversity and compositional shifts associated with OLK (dysbiosis)
* Develop predictive models to classify OLK using microbiome-derived features

## Repository Structure
```text
olk-early-oscc-biomarker-detection/
│── README.md
│── qiime2_pipeline.sh
│── Statistical_analysis_and_ML.ipynb
│
├── Data/
│   ├── Raw_data/
│   │   ├── metadata.tsv
│   │   ├── manifest.tsv
│   │   └── SRR.txt
│   │
│   └── Processed_data/
│       ├── feature_table.tsv
│       ├── taxonomy.tsv
│       └── denoised_metadata.tsv
│
└── Results/
    ├── main_figures/
    │   ├── taxanomic_barplot.jpeg
    │   ├── alpha_shannon_entropy.png
    │   ├── alpha_faithPD.png
    │   ├── beta_bray_curtis_PCoA.png
    │   ├── permanova_table.png
    │   ├── PCA.png
    │   ├── heatmap.png
    │   ├── top10_variable_genera.png
    │   ├── mean_genus_abundance.png
    │   ├── ROC_curve.png
    │   ├── Logistic_regression_confusion_matrix.png
    │   ├── random_forest_confusion_matrix.png
    │   └── imp_genera_RF.png
    │
    └── supplementary_figures/
        ├── demux_quality_plots.png
        ├── Frequency_per_sample.png
        ├── alpha_pielou_evenness.png
        ├── Group_significance_weighted_unifrac_permanova.png
        └── weighted_unifrac.png
```

## **Dataset**
- Raw sequencing data were obtained from NCBI SRA:
Project accession: PRJNA292477
- Sequencing type: 16S rRNA amplicon sequencing (V1–V2 region)
- Platform: Illumina MiSeq
- Sample type: Oral swab samples

A curated list of SRR accessions used is provided in:
```
Data/Raw_data/SRR.txt
```

## **Pipeline Summary**
### 1) Microbiome preprocessing and diversity analysis using QIIME2:
- Import + demultiplex summary
- DADA2 denoising (single-end)
- Only forward reads were used due to reverse read quality
- Truncation applied to remove low-quality tails
- Chimera removal + ASV inference
- Taxonomic classification using pretrained SILVA classifier
- Phylogenetic tree construction (MAFFT → FastTree)
- Core diversity metrics
- Alpha diversity: Shannon, Faith PD, Pielou’s evenness
- Beta diversity: Bray–Curtis PCoA
- Group-level testing: PERMANOVA (999 permutations)

Pipeline script:
```
qiime2_pipeline.sh
```

### 2) Statistical analysis (Python):
- PCA for global variability visualisation
- Heatmap of top variable genera
- Variance-based ranking of microbial genera
- Mean abundance comparisons across conditions

### 3) Machine learning (Python / scikit-learn):
- Logistic Regression
- Random Forest
- Train-test split: 80/20 stratified
- Feature filtering: variance threshold
- Log-transform: log1p
- Class balancing: SMOTE
- Evaluation: accuracy, precision, recall, F1-score, confusion matrix, ROC/AUC
- Random Forest feature importance used to identify predictive genera

Notebook:
```
Statistical_analysis_and_ML.ipynb
```

## **How to Reproduce**
### 1. Full reproducibility (starting from raw sequencing data)
- Download sequencing reads from NCBI SRA:

Project: PRJNA292477

SRR list: 
```
Data/Raw_data/SRR.txt
```
- Run QIIME2 workflow:
```
bash qiime2_pipeline.sh
```
- Run statistical analysis + machine learning:
Open and run:
```
Statistical_analysis_and_ML.ipynb
```

### 2. Reproduce stats + ML directly (without QIIME2 processing)
- Use tables in:
```
Data/Processed_data/feature-table.tsv
Data/Processed_data/taxonomy.tsv
Data/Raw_data/metadata.tsv
```
- Run:
```
Statistical_analysis_and_ML.ipynb
```

## **Tools Used**
- WSL version 2.6.1.0
- Ubuntu version: 24.04.1 LTS
- QIIME2 version 2025.10.1 (amplicon processing, diversity analysis)
- DADA2 (denoising/ASV inference via QIIME2)
- SILVA classifier for taxonomy: silva-138-99-nb-classifier.qza
- Python 3 libraries: pandas, numpy, matplotlib, seaborn, scikit-learn, imbalanced-learn (SMOTE)

## **Key Output**
The project demonstrates measurable microbiome shifts between Healthy and OLK groups (composition-level differences supported by PERMANOVA) and shows that a Random Forest classifier captures complex microbial patterns better than a linear model, highlighting genera such as Rothia, Streptococcus, Prevotella, and Leptotrichia as important predictors.

## **References / Data Sources**
- Amer, A., Galvin, S., Healy, C. M., & Moran, G. P. (2017). The Microbiome of Potentially Malignant Oral Leukoplakia Exhibits Enrichment for Fusobacterium, Leptotrichia, Campylobacter, and Rothia Species. Frontiers in microbiology, 8, 2391. https://doi.org/10.3389/fmicb.2017.02391 
- NCBI SRA Project: PRJNA292477
- QIIME2 pretrained SILVA classifier:
https://data.qiime2.org/classifiers/sklearn-1.4.2/silva/silva-138-99-nb-classifier.qza
