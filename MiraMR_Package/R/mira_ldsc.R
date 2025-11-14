#' Prepare GWAS Data for LDSC Analysis
#'
#' @title Prepare GWAS Summary Statistics for LDSC
#' @description Formats GWAS summary statistics for LDSC (Linkage Disequilibrium Score Regression)
#'   analysis using HapMap3 SNPs as reference. Performs quality control, allele harmonization,
#'   and calculates Z-scores.
#' @param gwas_data Data frame containing GWAS summary statistics
#' @param hm3_file Path to HapMap3 SNP list file (w_hm3.snplist)
#' @param sample_size Sample size of the GWAS study. If NULL, will use N column from data.
#' @param trait_name Name of the trait (used for output filename)
#' @param snp_col Column name for SNP rsID. Default is "SNP".
#' @param a1_col Column name for effect allele. Default is "A1".
#' @param a2_col Column name for other allele. Default is "A2".
#' @param effect_col Column name for effect size (beta or OR). Default is "effect".
#' @param p_col Column name for p-value. Default is "P".
#' @param maf_col Column name for MAF (optional). Default is "MAF".
#' @param n_col Column name for sample size (optional). Default is "N".
#' @param convert_or Logical, whether to convert OR to beta (log transform). Default is FALSE.
#' @param output_dir Output directory. Default is current directory.
#' @param overwrite Logical, whether to overwrite existing files. Default is TRUE.
#' @return Path to the output .sumstats.gz file
#' @details
#' The function performs the following steps:
#' \itemize{
#'   \item Merges GWAS data with HapMap3 reference SNPs
#'   \item Converts MAF to minor allele frequency if > 0.5
#'   \item Harmonizes alleles
#'   \item Converts OR to beta if specified
#'   \item Calculates Z-scores from p-values
#'   \item Outputs compressed .sumstats.gz file for LDSC
#' }
#' @note Requires HapMap3 SNP list which can be downloaded from:
#'   https://alkesgroup.broadinstitute.org/LDSCORE/
#' @examples
#' \dontrun{
#' # Prepare data for LDSC
#' mira_prep_ldsc(
#'   gwas_data = vitiligo_data,
#'   hm3_file = "w_hm3.snplist",
#'   sample_size = 784627,
#'   trait_name = "Vitiligo"
#' )
#' }
#' @export
mira_prep_ldsc <- function(gwas_data,
                           hm3_file,
                           sample_size = NULL,
                           trait_name,
                           snp_col = "SNP",
                           a1_col = "A1",
                           a2_col = "A2",
                           effect_col = "effect",
                           p_col = "P",
                           maf_col = "MAF",
                           n_col = "N",
                           convert_or = FALSE,
                           output_dir = ".",
                           overwrite = TRUE) {

  library(data.table)
  library(dplyr)
  library(stringr)

  # Check if HapMap3 file exists
  if(!file.exists(hm3_file)) {
    stop("HapMap3 SNP list file not found: ", hm3_file)
  }

  message("Reading HapMap3 reference SNPs...")
  ref <- fread(hm3_file, header = TRUE, data.table = FALSE)

  # Standardize column names
  gwas_data <- as.data.frame(gwas_data)
  if(snp_col != "SNP") gwas_data$SNP <- gwas_data[[snp_col]]
  if(a1_col != "A1") gwas_data$A1 <- gwas_data[[a1_col]]
  if(a2_col != "A2") gwas_data$A2 <- gwas_data[[a2_col]]
  if(effect_col != "effect") gwas_data$effect <- gwas_data[[effect_col]]
  if(p_col != "P") gwas_data$P <- gwas_data[[p_col]]

  # Handle MAF
  if(maf_col %in% colnames(gwas_data)) {
    gwas_data$MAF <- gwas_data[[maf_col]]
    gwas_data$MAF <- ifelse(gwas_data$MAF <= 0.5, gwas_data$MAF, (1 - gwas_data$MAF))
  }

  # Convert OR to beta if needed
  if(convert_or) {
    message("Converting OR to beta (log transformation)...")
    gwas_data$effect <- log(gwas_data$effect)
  }

  # Standardize alleles to uppercase
  gwas_data$A1 <- factor(toupper(gwas_data$A1), c("A", "C", "G", "T"))
  gwas_data$A2 <- factor(toupper(gwas_data$A2), c("A", "C", "G", "T"))

  message("Merging with HapMap3 SNPs...")
  file <- merge(ref, gwas_data, by = "SNP", all.x = FALSE, all.y = FALSE)
  message("Retained ", nrow(file), " SNPs after HapMap3 filtering")

  # Remove missing values
  before_na <- nrow(file)
  file <- subset(file, !(is.na(file$P)))
  file <- subset(file, !(is.na(file$effect)))
  message("Removed ", before_na - nrow(file), " SNPs with missing P or effect")

  # Check if effect is OR (median around 1) and convert to log scale
  median_effect <- median(file$effect, na.rm = TRUE)
  if(round(median_effect) == 1 && !convert_or) {
    message("Detected OR format (median = ", round(median_effect, 3), "), converting to beta...")
    file$effect <- log(file$effect)
  }

  # Harmonize alleles
  message("Harmonizing alleles...")
  # Flip effect if A1 doesn't match
  file$effect <- ifelse(file$A1.x != file$A1.y & file$A1.x == file$A2.y,
                       file$effect * -1,
                       file$effect)

  # Remove SNPs where alleles don't match
  before_harmonize <- nrow(file)
  file <- subset(file, !(file$A1.x != file$A1.y & file$A1.x != file$A2.y))
  file <- subset(file, !(file$A2.x != file$A2.y & file$A2.x != file$A1.y))
  message("Removed ", before_harmonize - nrow(file), " SNPs due to allele mismatch")

  # Calculate Z-scores
  message("Calculating Z-scores...")
  file$Z <- sign(file$effect) * sqrt(qchisq(file$P, 1, lower.tail = FALSE))

  # Prepare output
  if(n_col %in% colnames(file) && !is.null(file[[n_col]])) {
    output <- data.frame(
      SNP = file$SNP,
      N = file[[n_col]],
      Z = file$Z,
      A1 = file$A1.x,
      A2 = file$A2.x
    )
  } else if(!is.null(sample_size)) {
    output <- data.frame(
      SNP = file$SNP,
      N = sample_size,
      Z = file$Z,
      A1 = file$A1.x,
      A2 = file$A2.x
    )
  } else {
    stop("Sample size not provided. Please specify sample_size parameter or include N column in data.")
  }

  # Clean trait name
  trait_name <- str_replace_all(trait_name, fixed(" "), "")

  # Create output directory
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

  # Save output
  output_file <- file.path(output_dir, paste0(trait_name, ".sumstats"))
  fwrite(x = output, file = output_file, sep = "\t", quote = FALSE, row.names = FALSE)

  # Compress
  output_gz <- paste0(output_file, ".gz")
  R.utils::gzip(output_file, destname = output_gz, overwrite = overwrite, remove = TRUE)

  message("LDSC-formatted data saved to: ", output_gz)
  message("Final SNP count: ", nrow(output))

  return(output_gz)
}


#' Perform LDSC Analysis
#'
#' @title Linkage Disequilibrium Score Regression Analysis
#' @description Performs LDSC analysis to estimate genetic correlation, heritability,
#'   and LD Score intercepts between two traits using GenomicSEM package.
#' @param trait1_file Path to trait 1 .sumstats.gz file (from mira_prep_ldsc)
#' @param trait2_file Path to trait 2 .sumstats.gz file (from mira_prep_ldsc)
#' @param trait1_name Name of trait 1
#' @param trait2_name Name of trait 2
#' @param ld_dir Path to LD score directory (eur_w_ld_chr folder)
#' @param sample_prev Sample prevalence for each trait (for binary traits). Vector of length 2 or c(NA, NA).
#' @param population_prev Population prevalence for each trait (for binary traits). Vector of length 2 or c(NA, NA).
#' @param stand Logical, whether to standardize genetic covariance. Default is TRUE.
#' @param output_file Output file name. Default is "ldsc_result.txt".
#' @param output_dir Output directory. Default is current directory.
#' @return Data frame containing LDSC results including genetic correlation, heritability, and intercepts
#' @details
#' The function calculates:
#' \itemize{
#'   \item h2 - SNP heritability for both traits
#'   \item rg - Genetic correlation between traits
#'   \item intercept - LD Score intercepts (indicates population stratification/confounding)
#'   \item rgcov - Genetic covariance
#' }
#'
#' Results interpretation:
#' \itemize{
#'   \item rg > 0: Positive genetic correlation
#'   \item rg < 0: Negative genetic correlation
#'   \item rg_p < 0.05: Significant genetic correlation
#'   \item Intercept close to 1: No population stratification
#' }
#' @note Requires LD Score files which can be downloaded from:
#'   https://alkesgroup.broadinstitute.org/LDSCORE/
#' @examples
#' \dontrun{
#' # Run LDSC analysis
#' result <- mira_ldsc(
#'   trait1_file = "Vitiligo.sumstats.gz",
#'   trait2_file = "Depression.sumstats.gz",
#'   trait1_name = "Vitiligo",
#'   trait2_name = "Depression",
#'   ld_dir = "eur_w_ld_chr/"
#' )
#' }
#' @export
mira_ldsc <- function(trait1_file,
                     trait2_file,
                     trait1_name,
                     trait2_name,
                     ld_dir,
                     sample_prev = c(NA, NA),
                     population_prev = c(NA, NA),
                     stand = TRUE,
                     output_file = "ldsc_result.txt",
                     output_dir = ".") {

  library(GenomicSEM)
  library(data.table)
  library(stringr)

  # Check if files exist
  if(!file.exists(trait1_file)) stop("Trait 1 file not found: ", trait1_file)
  if(!file.exists(trait2_file)) stop("Trait 2 file not found: ", trait2_file)
  if(!dir.exists(ld_dir)) stop("LD score directory not found: ", ld_dir)

  message("Running LDSC analysis for:")
  message("  Trait 1: ", trait1_name)
  message("  Trait 2: ", trait2_name)

  # Prepare input
  traits <- c(trait1_file, trait2_file)
  trait_names <- c(trait1_name, trait2_name)

  # Run LDSC
  message("Running GenomicSEM::ldsc()...")
  LDSCoutput <- tryCatch({
    GenomicSEM::ldsc(
      traits = traits,
      sample.prev = sample_prev,
      population.prev = population_prev,
      ld = ld_dir,
      wld = ld_dir,
      trait.names = trait_names,
      stand = stand
    )
  }, error = function(e) {
    stop("LDSC analysis failed: ", e$message)
  })

  message("Extracting results...")

  # Extract results
  h2_exp <- as.numeric(LDSCoutput$S[1, 1])
  h2_exp_SE <- sqrt(LDSCoutput$V[1, 1])
  int_exp <- LDSCoutput$I[1, 1]
  int_out <- LDSCoutput$I[2, 2]
  h2_out <- as.numeric(LDSCoutput$S[2, 2])
  h2_out_SE <- sqrt(LDSCoutput$V[3, 3])
  rgcov <- as.numeric(LDSCoutput$S[1, 2])

  # Calculate genetic correlation
  rg <- as.numeric(LDSCoutput$S[1, 2] / sqrt(LDSCoutput$S[1, 1] * LDSCoutput$S[2, 2]))

  # Calculate SE for genetic correlation
  k <- nrow(LDSCoutput$S)
  SE <- matrix(0, k, k)
  SE[lower.tri(SE, diag = TRUE)] <- sqrt(diag(LDSCoutput$V_Stand))
  rg_SE <- SE[2, 1]
  rg_P <- 2 * pnorm(q = abs(rg / rg_SE), lower.tail = FALSE)
  rgcov_SE <- sqrt(LDSCoutput$V[2, 2])

  # Genetic covariance intercept
  gcov_int <- as.numeric(LDSCoutput$I[1, 2])

  # Prepare results
  ldsc_result <- data.frame(
    trait1 = trait1_name,
    trait2 = trait2_name,
    h2_trait1 = h2_exp,
    h2_trait1_se = h2_exp_SE,
    h2_trait2 = h2_out,
    h2_trait2_se = h2_out_SE,
    int_trait1 = int_exp,
    int_trait2 = int_out,
    gcov_int = gcov_int,
    rgcov = rgcov,
    rgcov_se = rgcov_SE,
    rg = rg,
    rg_se = rg_SE,
    rg_p = rg_P
  )

  # Create output directory
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

  # Save results
  output_path <- file.path(output_dir, output_file)
  write.table(ldsc_result, output_path, sep = "\t", quote = FALSE,
             row.names = FALSE, col.names = TRUE)

  message("LDSC results saved to: ", output_path)
  message("\nResults summary:")
  message("  Genetic correlation (rg): ", round(rg, 4), " (SE = ", round(rg_SE, 4), ")")
  message("  P-value: ", formatC(rg_P, format = "e", digits = 2))
  message("  Heritability trait 1 (h2): ", round(h2_exp, 4), " (SE = ", round(h2_exp_SE, 4), ")")
  message("  Heritability trait 2 (h2): ", round(h2_out, 4), " (SE = ", round(h2_out_SE, 4), ")")

  return(ldsc_result)
}


#' Batch LDSC Analysis
#'
#' @title Batch LDSC Analysis for Multiple Trait Pairs
#' @description Performs LDSC analysis for multiple trait pairs against a reference trait.
#'   Useful for testing genetic correlation between one trait and multiple candidate traits.
#' @param reference_file Path to reference trait .sumstats.gz file
#' @param reference_name Name of reference trait
#' @param trait_files Vector of paths to trait .sumstats.gz files
#' @param trait_names Vector of trait names (same order as trait_files)
#' @param ld_dir Path to LD score directory
#' @param sample_prev List of sample prevalence vectors for each comparison. Default is NULL (continuous traits).
#' @param population_prev List of population prevalence vectors for each comparison. Default is NULL.
#' @param stand Logical, whether to standardize. Default is TRUE.
#' @param output_file Output file name. Default is "ldsc_batch_results.txt".
#' @param output_dir Output directory. Default is current directory.
#' @return Data frame containing all LDSC results
#' @examples
#' \dontrun{
#' # Batch LDSC analysis
#' results <- mira_ldsc_batch(
#'   reference_file = "Vitiligo.sumstats.gz",
#'   reference_name = "Vitiligo",
#'   trait_files = c("Depression.sumstats.gz", "Anxiety.sumstats.gz"),
#'   trait_names = c("Depression", "Anxiety"),
#'   ld_dir = "eur_w_ld_chr/"
#' )
#' }
#' @export
mira_ldsc_batch <- function(reference_file,
                           reference_name,
                           trait_files,
                           trait_names,
                           ld_dir,
                           sample_prev = NULL,
                           population_prev = NULL,
                           stand = TRUE,
                           output_file = "ldsc_batch_results.txt",
                           output_dir = ".") {

  if(length(trait_files) != length(trait_names)) {
    stop("Length of trait_files and trait_names must match")
  }

  message("Running batch LDSC analysis for ", length(trait_files), " trait pairs...")

  all_results <- NULL

  for(i in 1:length(trait_files)) {
    message("\n[", i, "/", length(trait_files), "] Processing: ", trait_names[i])

    # Prepare sample and population prevalence
    if(!is.null(sample_prev)) {
      sp <- sample_prev[[i]]
    } else {
      sp <- c(NA, NA)
    }

    if(!is.null(population_prev)) {
      pp <- population_prev[[i]]
    } else {
      pp <- c(NA, NA)
    }

    # Run LDSC
    result <- tryCatch({
      mira_ldsc(
        trait1_file = reference_file,
        trait2_file = trait_files[i],
        trait1_name = reference_name,
        trait2_name = trait_names[i],
        ld_dir = ld_dir,
        sample_prev = sp,
        population_prev = pp,
        stand = stand,
        output_file = paste0(reference_name, "_", trait_names[i], "_ldsc.txt"),
        output_dir = output_dir
      )
    }, error = function(e) {
      warning("Failed to process ", trait_names[i], ": ", e$message)
      return(NULL)
    })

    if(!is.null(result)) {
      all_results <- rbind(all_results, result)
    }
  }

  # Save combined results
  if(!is.null(all_results)) {
    output_path <- file.path(output_dir, output_file)
    write.table(all_results, output_path, sep = "\t", quote = FALSE,
               row.names = FALSE, col.names = TRUE)
    message("\nAll results saved to: ", output_path)
  }

  return(all_results)
}


#' Plot LDSC Forest Plot
#'
#' @title Create Forest Plot for LDSC Results
#' @description Creates a forest plot to visualize genetic correlation results from LDSC analysis.
#' @param ldsc_results Data frame containing LDSC results (output from mira_ldsc or mira_ldsc_batch)
#' @param trait_col Column name for trait names. Default is "trait2".
#' @param rg_col Column name for genetic correlation. Default is "rg".
#' @param se_col Column name for standard error. Default is "rg_se".
#' @param p_col Column name for p-value. Default is "rg_p".
#' @param title Plot title. Default is "Genetic Correlation - LDSC Results".
#' @param xlim X-axis limits. Default is c(-0.5, 0.5).
#' @param output_file Output file name. Default is "ldsc_forest_plot.pdf".
#' @param width Plot width in inches. Default is 8.
#' @param height Plot height in inches. Default is 6.
#' @return Invisible NULL (saves plot to file)
#' @examples
#' \dontrun{
#' # Create forest plot
#' mira_ldsc_forest(
#'   ldsc_results = results,
#'   output_file = "ldsc_forest.pdf"
#' )
#' }
#' @export
mira_ldsc_forest <- function(ldsc_results,
                             trait_col = "trait2",
                             rg_col = "rg",
                             se_col = "rg_se",
                             p_col = "rg_p",
                             title = "Genetic Correlation - LDSC Results",
                             xlim = c(-0.5, 0.5),
                             output_file = "ldsc_forest_plot.pdf",
                             width = 8,
                             height = 6) {

  library(forestploter)
  library(grid)

  # Prepare data
  mydata <- ldsc_results[, c(trait_col, rg_col, se_col, p_col)]
  colnames(mydata) <- c("trait", "rg", "rg_se", "rg_p")

  # Calculate confidence intervals
  mydata$rg_lower <- mydata$rg - 1.96 * mydata$rg_se
  mydata$rg_upper <- mydata$rg + 1.96 * mydata$rg_se

  # Round values
  mydata$rg <- round(mydata$rg, 3)
  mydata$rg_se <- round(mydata$rg_se, 3)
  mydata$rg_p <- formatC(mydata$rg_p, format = "e", digits = 2)

  # Add spacing column for forest plot
  mydata$` ` <- paste(rep(" ", 20), collapse = " ")

  message("Creating forest plot...")

  # Create plot
  pdf(output_file, width = width, height = height)

  forest(
    mydata[, c("trait", "rg", "rg_se", " ", "rg_p")],
    est = mydata$rg,
    lower = mydata$rg_lower,
    upper = mydata$rg_upper,
    sizes = 0.5,
    ci_column = 4,
    ref_line = 0,
    xlim = xlim,
    arrow_lab = c("Negative correlation", "Positive correlation"),
    xlab = "Genetic Correlation (rg)"
  )

  dev.off()

  message("Forest plot saved to: ", output_file)

  invisible(NULL)
}
