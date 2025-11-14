# LDSC Reference Data Download Guide

## Overview

LDSC (Linkage Disequilibrium Score Regression) analysis requires reference data files that are **NOT included** in the MiraMR package due to their large size (~500 MB total).

This guide will help you download and set up these files.

---

## Required Files

| File | Size | Description |
|------|------|-------------|
| `w_hm3.snplist` | ~1.2 MB | HapMap3 SNP list for quality control |
| `eur_w_ld_chr/` | ~300-500 MB | LD Score reference panel (22 chromosomes) |

---

## Quick Start (Recommended)

### Option 1: Download via Command Line

```bash
# Create directory
mkdir -p ~/ldsc_data
cd ~/ldsc_data

# Download HapMap3 SNP list
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/w_hm3.snplist.bz2
bunzip2 w_hm3.snplist.bz2

# Download LD Scores for European ancestry
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/eur_w_ld_chr.tar.bz2
tar -xjf eur_w_ld_chr.tar.bz2

# Verify files
ls -lh w_hm3.snplist
ls -lh eur_w_ld_chr/
```

### Option 2: Manual Download

1. Visit: https://alkesgroup.broadinstitute.org/LDSCORE/
2. Download:
   - `w_hm3.snplist.bz2` (HapMap3 SNPs)
   - `eur_w_ld_chr.tar.bz2` (European LD Scores)
3. Extract both files
4. Place in a convenient location (e.g., `~/ldsc_data/`)

---

## Download Links

### Primary Source (Google Cloud Storage)

**HapMap3 SNP list:**
```
https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/w_hm3.snplist.bz2
```

**LD Score Reference Panels:**

- **European (EUR):**
  ```
  https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/eur_w_ld_chr.tar.bz2
  ```

- **East Asian (EAS):**
  ```
  https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/eas_ldscores.tar.bz2
  ```

- **African (AFR):**
  ```
  https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/afr_ldscores.tar.bz2
  ```

### Alternative Source (Broad Institute)

Visit: https://data.broadinstitute.org/alkesgroup/LDSCORE/

---

## File Structure

After downloading and extracting, your directory should look like:

```
~/ldsc_data/
├── w_hm3.snplist                    # HapMap3 SNP list
└── eur_w_ld_chr/                    # LD Score directory
    ├── 1.l2.ldscore.gz              # Chromosome 1
    ├── 1.l2.M
    ├── 1.l2.M_5_50
    ├── 2.l2.ldscore.gz              # Chromosome 2
    ├── 2.l2.M
    ├── 2.l2.M_5_50
    ├── ...
    ├── 22.l2.ldscore.gz             # Chromosome 22
    ├── 22.l2.M
    └── 22.l2.M_5_50
```

---

## Usage in MiraMR

### Set Up Paths

```r
# Define paths to reference data
hm3_file <- "~/ldsc_data/w_hm3.snplist"
ld_dir <- "~/ldsc_data/eur_w_ld_chr/"

# Or use full paths
hm3_file <- "/path/to/your/ldsc_data/w_hm3.snplist"
ld_dir <- "/path/to/your/ldsc_data/eur_w_ld_chr/"
```

### Example 1: Prepare GWAS Data

```r
library(MiraMR)

# Prepare your GWAS data for LDSC
trait1_prepared <- mira_prep_ldsc(
  gwas_data = my_gwas_data,
  hm3_file = hm3_file,
  sample_size = 100000,
  trait_name = "MyTrait"
)
```

### Example 2: Run LDSC Analysis

```r
# Genetic correlation analysis
result <- mira_ldsc(
  trait1_file = "trait1.sumstats.gz",
  trait2_file = "trait2.sumstats.gz",
  trait1_name = "Trait1",
  trait2_name = "Trait2",
  ld_dir = ld_dir
)
```

### Example 3: Batch Analysis

```r
# Analyze multiple trait pairs
results <- mira_ldsc_batch(
  reference_file = "reference.sumstats.gz",
  reference_name = "Reference",
  trait_files = c("trait1.sumstats.gz", "trait2.sumstats.gz"),
  trait_names = c("Trait1", "Trait2"),
  ld_dir = ld_dir
)
```

---

## Troubleshooting

### Error: "HapMap3 file not found"

**Solution:**
- Check file path is correct
- Ensure file is uncompressed (.snplist, not .snplist.bz2)
- Verify file permissions (readable)

### Error: "LD score directory not found"

**Solution:**
- Check directory path is correct and includes trailing `/`
- Ensure directory contains .ldscore.gz files for all chromosomes
- Verify directory structure matches expected format

### Error: "No SNPs remaining after HapMap3 filtering"

**Solution:**
- Ensure your GWAS data contains SNP rsIDs (e.g., rs12345)
- Check that column names match expectations
- Verify data quality (no excessive missing values)

### Download fails or is very slow

**Solution:**
- Try alternative download source (Broad Institute website)
- Use `wget --continue` to resume interrupted downloads
- Check internet connection
- Some institutions may block Google Cloud Storage

---

## Storage Recommendations

### Disk Space Requirements

- **Minimum**: 600 MB (for EUR panel only)
- **Recommended**: 2-3 GB (for multiple populations)

### Location

Choose a location that:
1. Has sufficient disk space
2. Is accessible to R (check permissions)
3. Won't be accidentally deleted
4. Can be shared across projects

**Recommended locations:**
- Linux/Mac: `~/ldsc_data/` or `/data/ldsc_reference/`
- Windows: `C:/Users/YourName/ldsc_data/` or `D:/ldsc_data/`

---

## Multiple Populations

If you work with diverse populations, download all reference panels:

```bash
# Download all populations
cd ~/ldsc_data

# European
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/eur_w_ld_chr.tar.bz2
tar -xjf eur_w_ld_chr.tar.bz2

# East Asian
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/eas_ldscores.tar.bz2
tar -xjf eas_ldscores.tar.bz2

# African
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/afr_ldscores.tar.bz2
tar -xjf afr_ldscores.tar.bz2
```

Then use population-specific directory in your analysis:

```r
# European
ld_dir_eur <- "~/ldsc_data/eur_w_ld_chr/"

# East Asian
ld_dir_eas <- "~/ldsc_data/eas_ldscores/"

# African
ld_dir_afr <- "~/ldsc_data/afr_ldscores/"
```

---

## Citation

If you use LDSC reference data, please cite:

> Bulik-Sullivan, B. K., Loh, P. R., Finucane, H. K., Ripke, S., Yang, J.,
> Patterson, N., ... & Neale, B. M. (2015). LD Score regression distinguishes
> confounding from polygenicity in genome-wide association studies.
> Nature genetics, 47(3), 291-295.

---

## Additional Resources

- **LDSC GitHub**: https://github.com/bulik/ldsc
- **LDSC Wiki**: https://github.com/bulik/ldsc/wiki
- **LDSC Tutorial**: https://github.com/bulik/ldsc/wiki/Heritability-and-Genetic-Correlation
- **GenomicSEM**: https://github.com/GenomicSEM/GenomicSEM

---

## Support

If you encounter issues:

1. Check this guide first
2. Review MiraMR documentation: `?mira_prep_ldsc` or `?mira_ldsc`
3. Open an issue on GitHub: https://github.com/mtmmu88/MiraMR/issues
4. Email: mtmmu88@gmail.com

---

*Last updated: 2024*
