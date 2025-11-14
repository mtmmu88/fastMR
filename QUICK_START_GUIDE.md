# MiraMR Quick Start Guide

## For New Users

### Installation (5 minutes)

```r
# 1. Install package
devtools::install_github("mtmmu88/MiraMR")

# 2. Get your machine ID
MiraMR::mira_get_machine_id()

# 3. Copy the machine ID and email to mtmmu88@gmail.com with:
#    - Your name
#    - Your email
#    - Your institution
#    - Your machine ID
#    - What you'll use MiraMR for

# 4. Wait for license key (usually within 24-48 hours)

# 5. When you receive the key, activate it:
MiraMR::mira_activate("paste_your_license_key_here")

# 6. Load and use!
library(MiraMR)
mira_help()
```

---

## For Returning Users

```r
# Just load and go!
library(MiraMR)

# Check your license expiry
mira_license_status()
```

---

## Common Commands

### Basic MR Analysis

```r
library(MiraMR)

# Univariable MR (local data)
result <- mira_uvmr_local_local(
  exposure_gwas = exp_data,
  outcome_gwas = out_data,
  output_dir = "results"
)

# Univariable MR (IEU data)
result <- mira_uvmr_ieu_ieu(
  gwas_id_exp = "ieu-a-2",
  gwas_id_out = "ieu-a-7",
  output_dir = "results"
)
```

### Prepare Omics Data

```r
# Inflammatory factors
data <- mira_prep_inflammatory(
  input_dir = "raw_data",
  output_dir = "processed_data"
)

# Immune cells
data <- mira_prep_immune(
  input_dir = "raw_data",
  output_dir = "processed_data"
)

# Metabolites
data <- mira_prep_metabolite(
  input_dir = "raw_data",
  output_dir = "processed_data"
)

# Gut microbiome
data <- mira_prep_gut(
  input_dir = "raw_data",
  output_dir = "processed_data"
)
```

### LDSC Analysis

```r
# Download reference data first (one time setup)
# See README.md for download instructions

# Prepare GWAS for LDSC
mira_prep_ldsc(
  gwas_data = my_data,
  hm3_file = "~/ldsc_data/w_hm3.snplist",
  sample_size = 100000,
  trait_name = "MyTrait"
)

# Run genetic correlation
result <- mira_ldsc(
  trait1_file = "trait1.sumstats.gz",
  trait2_file = "trait2.sumstats.gz",
  ld_dir = "~/ldsc_data/eur_w_ld_chr/"
)
```

### Convert CHR:BP to rsID

```r
# Single dataset
data_with_rsid <- mira_chr_to_rsid(
  data = gwas_data,
  chr_col = "CHR",
  bp_col = "BP",
  build = "GRCh37"
)

# Batch processing
results <- mira_chr_to_rsid_batch(
  file_dir = "gwas_files/",
  file_pattern = "*.txt",
  build = "GRCh37",
  merge = TRUE
)
```

---

## Troubleshooting

### "License required" error

```r
# Make sure you activated your license
MiraMR::mira_activate("your_license_key")

# Check if it worked
MiraMR::mira_license_status()
```

### "License expired" error

```r
# Request renewal from mtmmu88@gmail.com
# Include your name and machine ID
```

### "Machine mismatch" error

```r
# This license won't work on this computer
# Get new machine ID and request new license
MiraMR::mira_get_machine_id()
```

### Switching to a new computer

```r
# On old computer:
MiraMR::mira_deactivate()

# On new computer:
MiraMR::mira_get_machine_id()
# Email the new machine ID to request new license
```

---

## Getting Help

- **Package help**: `mira_help()`
- **Function help**: `?mira_uvmr_local_local`
- **License issues**: mtmmu88@gmail.com
- **Bug reports**: https://github.com/mtmmu88/MiraMR/issues

---

## Example Workflow

```r
# 1. Load package
library(MiraMR)

# 2. Read GWAS data
exp_data <- mira_read_gwas("exposure.txt")
out_data <- mira_read_gwas("outcome.txt")

# 3. Run MR analysis
result <- mira_uvmr_local_local(
  exposure_gwas = exp_data,
  outcome_gwas = out_data,
  clump_p1 = 5e-8,
  clump_r2 = 0.001,
  use_steiger = TRUE,
  use_fvalue = TRUE,
  use_presso = TRUE,
  create_plots = TRUE,
  output_dir = "MR_results"
)

# 4. Check results
list.files("MR_results")
# Output includes:
# - MR.csv (main results)
# - het.csv (heterogeneity)
# - ple.csv (pleiotropy)
# - IV.csv (instrumental variables)
# - plots (scatter, forest, funnel, LOO)

# 5. View results
mr_results <- read.csv("MR_results/MR.csv")
View(mr_results)
```

---

*For detailed documentation, see README.md and LICENSE_SYSTEM_README.md*
