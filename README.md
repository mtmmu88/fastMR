# MiraMR

> *Dedicated to my daughter Mira* 💝

**MiraMR** (Mira's Mendelian Randomization Toolkit) is a comprehensive R package for Mendelian Randomization analysis, created with love for academic research and education.

---

## 🎯 Overview

MiraMR provides an intuitive and powerful toolkit for conducting Mendelian Randomization (MR) analysis. All functions use the `mira_` prefix, making them easy to discover and use. This package is designed for researchers and students who want to perform high-quality causal inference using genetic variants as instrumental variables.

### Key Features

- ✅ **Comprehensive MR Analysis**: Univariable and multivariable MR with multiple methods
- ✅ **Omics Integration**: Support for inflammatory factors, immune cells, metabolomics, and gut microbiome
- ✅ **IEU OpenGWAS Integration**: Seamless access to publicly available GWAS data
- ✅ **Quality Control**: F-statistic filtering, Steiger filtering, and MR-PRESSO outlier detection
- ✅ **Advanced Methods**: SMR, GWAS meta-analysis, and pleiotropic analysis (PLACO)
- ✅ **Visualization**: Automated generation of scatter plots, forest plots, funnel plots, and leave-one-out plots
- ✅ **User-Friendly**: Consistent naming convention and comprehensive documentation
- ✅ **No Licensing Restrictions**: Free for academic use under GPL-3

---

## 📦 Installation

### From GitHub

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install MiraMR from GitHub
devtools::install_github("mtmmu88/MiraMR")
```

### From Local Source

```r
devtools::install("/path/to/MiraMR")
```

---

## 🚀 Quick Start

```r
# Load the package
library(MiraMR)

# View package help
mira_help()

# Example 1: Univariable MR with local data
result <- mira_uvmr_local_local(
  exposure_gwas = exposure_data,
  outcome_gwas = outcome_data,
  output_dir = "results",
  create_plots = TRUE
)

# Example 2: Univariable MR with IEU OpenGWAS
result <- mira_uvmr_ieu_ieu(
  gwas_id_exp = "ieu-a-2",
  gwas_id_out = "ieu-a-7",
  output_dir = "results"
)

# Example 3: Prepare inflammatory factor data
inflammatory_data <- mira_prep_inflammatory(
  input_dir = "raw_data",
  output_dir = "processed_data",
  as_exposure = TRUE
)
```

---

## 📚 Main Functions

### Core MR Analysis

#### Univariable MR
- `mira_uvmr_local_local()` - Both exposure and outcome from local data
- `mira_uvmr_local_ieu()` - Local exposure, IEU outcome
- `mira_uvmr_ieu_local()` - IEU exposure, local outcome
- `mira_uvmr_ieu_ieu()` - Both from IEU OpenGWAS

#### Multivariable MR
- `mira_mvmr_local_local()` - Multiple exposures and outcome from local data
- `mira_mvmr_local_ieu()` - Local exposures, IEU outcome
- `mira_mvmr_ieu_local()` - IEU exposures, local outcome
- `mira_mvmr_ieu_ieu()` - Both from IEU OpenGWAS

### Data Preprocessing

- `mira_prep_inflammatory()` - Preprocess inflammatory factor data (91 factors)
- `mira_prep_immune()` - Preprocess immune cell data (731 cell types)
- `mira_prep_metabolite()` - Preprocess metabolomics data (1,400 metabolites)
- `mira_prep_gut()` - Preprocess gut microbiome data (211 taxa)
- `mira_split_gut()` - Split gut microbiome exposure data

### Advanced Analysis

- `mira_smr_qtl()` - Summary-based Mendelian Randomization for QTL analysis
- `mira_smr_plot()` - Visualize SMR results
- `mira_gwas_meta()` - GWAS meta-analysis
- `mira_placo()` - Pleiotropic analysis
- `mira_omic_local()` - Omics-wide MR analysis
- `mira_omic_loo()` - Leave-one-out sensitivity analysis for omics

### LDSC Analysis (Genetic Correlation)

- `mira_prep_ldsc()` - Prepare GWAS data for LDSC analysis
- `mira_ldsc()` - Perform LDSC analysis for two traits
- `mira_ldsc_batch()` - Batch LDSC analysis for multiple trait pairs
- `mira_ldsc_forest()` - Create forest plot for LDSC results

### Gut Microbiome Analysis

- `mira_gut_ieu()` - Gut microbiome (exposure) → IEU outcome
- `mira_gut_local()` - Gut microbiome (exposure) → Local outcome
- `mira_ieu_gut()` - IEU exposure → Gut microbiome (outcome)
- `mira_local_gut()` - Local exposure → Gut microbiome (outcome)

### Utility Functions

- `mira_read_gwas()` - Read GWAS summary data
- `mira_read_finn()` - Read FinnGen data
- `mira_read_giant()` - Read GIANT consortium data
- `mira_find_gene()` - Map SNPs to nearest genes (hg18/hg19/hg38)
- `mira_trans_eaf()` - Transform sample size, beta, SE to EAF
- `mira_trans_z()` - Transform Z-scores to beta and SE

---

## 📖 Documentation

Each function comes with comprehensive documentation. View help for any function:

```r
?mira_uvmr_local_local
?mira_prep_inflammatory
?mira_smr_qtl
```

---

## 🔬 Typical Workflow

### 1. Prepare Your Data

```r
# For inflammatory factors
exp_data <- mira_prep_inflammatory(
  input_dir = "data/inflammatory",
  output_dir = "data/processed",
  as_exposure = TRUE,
  p_threshold = 5e-8
)
```

### 2. Run MR Analysis

```r
# Univariable MR
result <- mira_uvmr_local_local(
  exposure_gwas = exp_data,
  outcome_gwas = outcome_data,
  clump_p1 = 5e-8,
  clump_r2 = 0.001,
  use_steiger = TRUE,
  use_fvalue = TRUE,
  use_presso = TRUE,
  create_plots = TRUE,
  output_dir = "MR_results"
)
```

### 3. Review Results

MiraMR automatically generates:
- `MR.csv` - Main MR results with OR and 95% CI
- `het.csv` - Heterogeneity test results
- `ple.csv` - Pleiotropy test results
- `IV.csv` - Instrumental variable details
- Diagnostic plots (scatter, forest, funnel, leave-one-out)

---

## 🔧 Requirements

### R Version
- R >= 3.5.0

### Dependencies

The package automatically installs required dependencies:

- **Core MR**: TwoSampleMR, MendelianRandomization, MRPRESSO, ieugwasr
- **Data Processing**: dplyr, tidyr, data.table, sqldf
- **Visualization**: ggplot2, forestploter
- **LDSC Analysis**: GenomicSEM, R.utils, stringr

### Reference Data for LDSC Analysis

**IMPORTANT**: LDSC functions require reference data files which are **NOT included** in the package due to their large size (~500 MB).

#### Required Files:

1. **HapMap3 SNP list** (`w_hm3.snplist` - ~1.2 MB)
2. **LD Score reference panel** (`eur_w_ld_chr/` - ~300-500 MB)

#### Download Instructions:

```bash
# Create a directory for reference data
mkdir -p ~/ldsc_data
cd ~/ldsc_data

# Download HapMap3 SNP list
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/w_hm3.snplist.bz2
bunzip2 w_hm3.snplist.bz2

# Download LD Scores for European ancestry
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/eur_w_ld_chr.tar.bz2
tar -xjf eur_w_ld_chr.tar.bz2
```

**Alternative download source:**
- Official LDSC page: https://alkesgroup.broadinstitute.org/LDSCORE/
- Direct links:
  - HapMap3: https://data.broadinstitute.org/alkesgroup/LDSCORE/
  - LD Scores: https://data.broadinstitute.org/alkesgroup/LDSCORE/

#### For Other Populations:

```bash
# East Asian ancestry
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/eas_ldscores.tar.bz2

# African ancestry
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/afr_ldscores.tar.bz2
```

#### Usage in R:

```r
# Specify paths to downloaded reference files
hm3_file <- "~/ldsc_data/w_hm3.snplist"
ld_dir <- "~/ldsc_data/eur_w_ld_chr/"

# Use in LDSC analysis
mira_prep_ldsc(
  gwas_data = my_data,
  hm3_file = hm3_file,
  sample_size = 100000,
  trait_name = "MyTrait"
)

mira_ldsc(
  trait1_file = "trait1.sumstats.gz",
  trait2_file = "trait2.sumstats.gz",
  ld_dir = ld_dir,
  ...
)
```

---

## 💡 Tips

1. **For Large-Scale Analysis**: Use the omics functions like `mira_omic_local()` to analyze hundreds of exposures efficiently

2. **Quality Control**: Always use `use_steiger = TRUE` and `use_fvalue = TRUE` for robust IV selection

3. **Outlier Detection**: Enable `use_presso = TRUE` to detect and correct for horizontal pleiotropy

4. **Local LD Clumping**: For faster analysis or when API is slow, download 1000 Genomes reference data and use `local_clump = TRUE`

5. **IEU OpenGWAS**: Browse available GWAS at https://gwas.mrcieu.ac.uk/ to find dataset IDs

---

## 📧 Contact

**Author**: Mira's Father
**Email**: mtmmu88@gmail.com
**GitHub**: https://github.com/mtmmu88/MiraMR

---

## 📄 License

This package is licensed under the **GPL-3 License**.

**For Academic Use Only** - Not for unauthorized commercial purposes.

---

## 🙏 Acknowledgments

This package was created with inspiration from the MR research community and is dedicated to promoting open science and causal inference in epidemiology.

Special thanks to:
- The TwoSampleMR team for their excellent framework
- The IEU OpenGWAS project for making GWAS data accessible
- The MR-Base collaboration

---

## 📝 Citation

If you use MiraMR in your research, please cite:

```
MiraMR: A Comprehensive Mendelian Randomization Toolkit
Author: mtmmu88
Year: 2024
URL: https://github.com/mtmmu88/MiraMR
```

---

## 🌟 Version History

### Version 1.0.0 (Current)
- Initial release
- Complete implementation of UVMR and MVMR functions
- Support for omics data integration
- IEU OpenGWAS integration
- Comprehensive documentation

---

*For Mira, with gratitude to Candice, and for the scientific community* ❤️
