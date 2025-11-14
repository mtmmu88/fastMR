#' Univariable Mendelian Randomization with Local Exposure and Local Outcome Data
#'
#' @title UVMR Analysis with Both Local GWAS Datasets
#' @description Performs standard univariable Mendelian randomization analysis when both
#'   exposure and outcome data are available locally as GWAS summary statistics.
#'
#' @param exposure_gwas Data frame containing exposure GWAS summary statistics with columns:
#'   SNP, effect_allele.exposure, other_allele.exposure, eaf.exposure, beta.exposure,
#'   se.exposure, pval.exposure, id.exposure, exposure, samplesize.exposure
#' @param outcome_gwas Data frame containing outcome GWAS summary statistics with columns:
#'   SNP, effect_allele.outcome, other_allele.outcome, eaf.outcome, beta.outcome,
#'   se.outcome, pval.outcome, id.outcome, outcome, samplesize.outcome
#' @param local_clump Logical, whether to use local LD clumping with PLINK (default: FALSE)
#' @param confounding_snps Character vector of SNP rsIDs to exclude as potential confounders (default: NULL)
#' @param clump_p1 P-value threshold for instrument selection (default: 5e-08)
#' @param clump_r2 LD r-squared threshold for clumping (default: 0.001)
#' @param clump_kb Distance threshold for clumping in kilobases (default: 10000)
#' @param pop Population for LD reference panel, one of "EUR", "SAS", "EAS", "AFR", "AMR" (default: "EUR")
#' @param output_folder Path to folder for saving results (default: "MR_results")
#' @param use_presso Logical, whether to perform MR-PRESSO outlier detection (default: FALSE)
#' @param use_steiger Logical, whether to perform Steiger filtering for directionality (default: TRUE)
#' @param use_fvalue Logical, whether to filter instruments by F-statistic > 10 (default: TRUE)
#' @param create_plots Logical, whether to generate diagnostic plots (default: TRUE)
#'
#' @return Invisibly returns a list with MR results, heterogeneity tests, pleiotropy tests, and IV data
#' @export
#'
#' @examples
#' \dontrun{
#' results <- mira_uvmr_local_local(
#'   exposure_gwas = exp_data,
#'   outcome_gwas = out_data,
#'   clump_p1 = 5e-08,
#'   output_folder = "my_mr_results"
#' )
#' }
mira_uvmr_local_local <- function(exposure_gwas, outcome_gwas,
                                  local_clump = FALSE,
                                  confounding_snps = NULL,
                                  clump_p1 = 5e-08,
                                  clump_r2 = 0.001,
                                  clump_kb = 10000,
                                  pop = "EUR",
                                  output_folder = "MR_results",
                                  use_presso = FALSE,
                                  use_steiger = TRUE,
                                  use_fvalue = TRUE,
                                  create_plots = TRUE) {

  # Load required packages
  require(tidyr)
  require(TwoSampleMR)

  # Create output directory
  dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

  # Select required columns from exposure data
  exp_data <- exposure_gwas[, c("SNP", "effect_allele.exposure", "other_allele.exposure",
                                "eaf.exposure", "beta.exposure", "se.exposure",
                                "pval.exposure", "id.exposure", "exposure",
                                "samplesize.exposure")]

  # Select required columns from outcome data
  out_data <- outcome_gwas[, c("SNP", "effect_allele.outcome", "other_allele.outcome",
                               "eaf.outcome", "beta.outcome", "se.outcome",
                               "pval.outcome", "id.outcome", "outcome",
                               "samplesize.outcome")]

  # Filter exposure SNPs by p-value threshold
  exp_iv <- subset(exp_data, pval.exposure < clump_p1)

  # Perform LD clumping
  if (!local_clump) {
    exp_iv <- clump_data(exp_iv, clump_kb = clump_kb, clump_r2 = clump_r2,
                        clump_p1 = 1, clump_p2 = 1, pop = pop)
  } else {
    exp_iv <- .mira_local_clump(exp_iv, pop = pop, clump_kb = clump_kb, clump_r2 = clump_r2)
  }

  # Apply F-value filtering if requested
  if (use_fvalue) {
    exp_iv <- .mira_filter_fvalue(exp_iv)
  }

  # Check if instruments remain after filtering
  if (nrow(exp_iv) == 0) {
    message("No instrumental variables found with current thresholds. Try relaxing filtering criteria.")
    return(invisible(NULL))
  }

  # Merge exposure IVs with outcome data
  merged_data <- merge(out_data, exp_iv, by = "SNP", all = FALSE)

  # Filter out SNPs with genome-wide significance in outcome
  merged_data <- subset(merged_data, pval.outcome > 5e-08)

  # Remove duplicate SNPs
  merged_data <- merged_data[!duplicated(merged_data$SNP), ]

  # Remove confounding SNPs if specified
  if (!is.null(confounding_snps)) {
    merged_data <- merged_data %>% dplyr::filter(!SNP %in% confounding_snps)
  }

  # Check if SNPs remain after filtering
  if (nrow(merged_data) == 0) {
    message("No instrumental variables found after filtering. Current thresholds may be too strict.")
    return(invisible(NULL))
  }

  # Extract harmonized exposure and outcome data
  exp_harmonized <- merged_data[, c("SNP", "effect_allele.exposure", "other_allele.exposure",
                                   "eaf.exposure", "beta.exposure", "se.exposure",
                                   "pval.exposure", "id.exposure", "exposure",
                                   "samplesize.exposure")]

  out_harmonized <- merged_data[, c("SNP", "effect_allele.outcome", "other_allele.outcome",
                                   "eaf.outcome", "beta.outcome", "se.outcome",
                                   "pval.outcome", "id.outcome", "outcome",
                                   "samplesize.outcome")]

  # Harmonize data and remove palindromic SNPs
  harmonized_dat <- harmonise_data(exposure_dat = exp_harmonized,
                                  outcome_dat = out_harmonized,
                                  action = 2)

  # Apply Steiger filtering if requested
  if (use_steiger) {
    harmonized_dat <- steiger_filtering(harmonized_dat)
    harmonized_dat <- subset(harmonized_dat, steiger_dir == TRUE)
  }

  # Check if SNPs remain after harmonization
  if (nrow(harmonized_dat) == 0) {
    message("No SNPs remaining after harmonization and filtering.")
    return(invisible(NULL))
  }

  # Perform MR analysis
  mr_results <- mr(harmonized_dat)
  mr_or <- generate_odds_ratios(mr_results)
  mr_or$or <- round(mr_or$or, 3)
  mr_or$or_lci95 <- round(mr_or$or_lci95, 3)
  mr_or$or_uci95 <- round(mr_or$or_uci95, 3)
  mr_or$OR_CI <- paste0(mr_or$or, " (", mr_or$or_lci95, "-", mr_or$or_uci95, ")")

  # Perform heterogeneity and pleiotropy tests
  het_results <- mr_heterogeneity(harmonized_dat)
  ple_results <- mr_pleiotropy_test(harmonized_dat)

  # Calculate R2 and F-statistics for instruments
  iv_data <- harmonized_dat
  iv_data$R2 <- iv_data$beta.exposure^2 * 2 * iv_data$eaf.exposure * (1 - iv_data$eaf.exposure)
  iv_data$Fvalue <- (iv_data$samplesize.exposure - 2) * iv_data$R2 / (1 - iv_data$R2)

  # Save results
  write.csv(mr_or, file.path(output_folder, "MR_results.csv"), row.names = FALSE)
  write.csv(het_results, file.path(output_folder, "heterogeneity.csv"), row.names = FALSE)
  write.csv(ple_results, file.path(output_folder, "pleiotropy.csv"), row.names = FALSE)
  write.csv(iv_data, file.path(output_folder, "instrumental_variables.csv"), row.names = FALSE)

  # Generate plots if requested
  if (create_plots) {
    .mira_generate_plots(mr_results, harmonized_dat, output_folder)
  }

  # Perform MR-PRESSO if requested
  if (use_presso) {
    .mira_run_presso(harmonized_dat, output_folder)
  }

  message("Analysis complete. Results saved to: ", output_folder)

  # Return results invisibly
  invisible(list(
    mr_results = mr_or,
    heterogeneity = het_results,
    pleiotropy = ple_results,
    instruments = iv_data
  ))
}


#' Univariable Mendelian Randomization with Local Exposure and IEU Outcome Data
#'
#' @title UVMR Analysis with Local Exposure and IEU OpenGWAS Outcome
#' @description Performs standard univariable Mendelian randomization analysis when exposure
#'   data is available locally and outcome data is retrieved from IEU OpenGWAS database.
#'
#' @param exposure_gwas Data frame containing exposure GWAS summary statistics
#' @param gwas_id_outcome Character string, IEU OpenGWAS ID for outcome trait (e.g., "ieu-a-2")
#' @param outcome_name Character string, descriptive name for outcome (default: "outcome")
#' @param outcome_sample_size Numeric, sample size for outcome GWAS (default: 100000)
#' @param local_clump Logical, whether to use local LD clumping with PLINK (default: FALSE)
#' @param confounding_snps Character vector of SNP rsIDs to exclude (default: NULL)
#' @param clump_p1 P-value threshold for instrument selection (default: 5e-08)
#' @param clump_r2 LD r-squared threshold for clumping (default: 0.001)
#' @param clump_kb Distance threshold for clumping in kilobases (default: 10000)
#' @param pop Population for LD reference panel (default: "EUR")
#' @param output_folder Path to folder for saving results (default: "MR_results")
#' @param use_presso Logical, whether to perform MR-PRESSO (default: FALSE)
#' @param use_steiger Logical, whether to perform Steiger filtering (default: TRUE)
#' @param use_fvalue Logical, whether to filter by F-statistic (default: TRUE)
#' @param create_plots Logical, whether to generate plots (default: TRUE)
#'
#' @return Invisibly returns a list with MR results
#' @export
mira_uvmr_local_ieu <- function(exposure_gwas, gwas_id_outcome,
                                outcome_name = "outcome",
                                outcome_sample_size = 100000,
                                local_clump = FALSE,
                                confounding_snps = NULL,
                                clump_p1 = 5e-08,
                                clump_r2 = 0.001,
                                clump_kb = 10000,
                                pop = "EUR",
                                output_folder = "MR_results",
                                use_presso = FALSE,
                                use_steiger = TRUE,
                                use_fvalue = TRUE,
                                create_plots = TRUE) {

  require(tidyr)
  require(TwoSampleMR)

  dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

  # Prepare exposure data
  exp_data <- exposure_gwas[, c("SNP", "effect_allele.exposure", "other_allele.exposure",
                                "eaf.exposure", "beta.exposure", "se.exposure",
                                "pval.exposure", "id.exposure", "exposure",
                                "samplesize.exposure")]

  # Filter and clump exposure data
  exp_iv <- subset(exp_data, pval.exposure < clump_p1)

  if (!local_clump) {
    exp_iv <- clump_data(exp_iv, clump_kb = clump_kb, clump_r2 = clump_r2,
                        clump_p1 = clump_p1, clump_p2 = 1, pop = pop)
  } else {
    exp_iv <- .mira_local_clump(exp_iv, pop = pop, clump_kb = clump_kb, clump_r2 = clump_r2)
  }

  # Apply F-value filtering
  if (use_fvalue) {
    exp_iv <- .mira_filter_fvalue(exp_iv)
  }

  if (nrow(exp_iv) == 0) {
    message("No instrumental variables found with current thresholds.")
    return(invisible(NULL))
  }

  # Extract outcome data from IEU OpenGWAS
  out_data <- extract_outcome_data(snps = exp_iv$SNP,
                                  outcomes = gwas_id_outcome,
                                  proxies = TRUE,
                                  maf_threshold = 0.01)

  out_data$id.outcome <- outcome_name
  out_data$outcome <- outcome_name
  out_data$samplesize.outcome <- outcome_sample_size

  # Filter outcome SNPs
  out_data <- subset(out_data, pval.outcome > 5e-08)
  out_data <- out_data[!duplicated(out_data$SNP), ]

  # Merge datasets
  merged_data <- merge(out_data, exp_iv, by = "SNP", all = FALSE)

  if (nrow(merged_data) == 0) {
    message("No instrumental variables found after merging with outcome data.")
    return(invisible(NULL))
  }

  # Remove confounding SNPs
  if (!is.null(confounding_snps)) {
    merged_data <- merged_data %>% dplyr::filter(!SNP %in% confounding_snps)
  }

  # Prepare for harmonization
  exp_harmonized <- merged_data[, c("SNP", "effect_allele.exposure", "other_allele.exposure",
                                   "eaf.exposure", "beta.exposure", "se.exposure",
                                   "pval.exposure", "id.exposure", "exposure",
                                   "samplesize.exposure")]

  out_harmonized <- merged_data[, c("SNP", "effect_allele.outcome", "other_allele.outcome",
                                   "eaf.outcome", "beta.outcome", "se.outcome",
                                   "pval.outcome", "id.outcome", "outcome",
                                   "samplesize.outcome")]

  # Harmonize
  harmonized_dat <- harmonise_data(exposure_dat = exp_harmonized,
                                  outcome_dat = out_harmonized,
                                  action = 2)

  # Steiger filtering
  if (use_steiger) {
    harmonized_dat <- steiger_filtering(harmonized_dat)
    harmonized_dat <- subset(harmonized_dat, steiger_dir == TRUE)
  }

  if (nrow(harmonized_dat) == 0) {
    message("No SNPs remaining after harmonization and filtering.")
    return(invisible(NULL))
  }

  # Perform MR and save results
  mr_results <- mr(harmonized_dat)
  mr_or <- generate_odds_ratios(mr_results)
  mr_or$or <- round(mr_or$or, 3)
  mr_or$or_lci95 <- round(mr_or$or_lci95, 3)
  mr_or$or_uci95 <- round(mr_or$or_uci95, 3)
  mr_or$OR_CI <- paste0(mr_or$or, " (", mr_or$or_lci95, "-", mr_or$or_uci95, ")")

  het_results <- mr_heterogeneity(harmonized_dat)
  ple_results <- mr_pleiotropy_test(harmonized_dat)

  iv_data <- harmonized_dat
  iv_data$R2 <- iv_data$beta.exposure^2 * 2 * iv_data$eaf.exposure * (1 - iv_data$eaf.exposure)
  iv_data$Fvalue <- (iv_data$samplesize.exposure - 2) * iv_data$R2 / (1 - iv_data$R2)

  write.csv(mr_or, file.path(output_folder, "MR_results.csv"), row.names = FALSE)
  write.csv(het_results, file.path(output_folder, "heterogeneity.csv"), row.names = FALSE)
  write.csv(ple_results, file.path(output_folder, "pleiotropy.csv"), row.names = FALSE)
  write.csv(iv_data, file.path(output_folder, "instrumental_variables.csv"), row.names = FALSE)

  if (create_plots) {
    .mira_generate_plots(mr_results, harmonized_dat, output_folder)
  }

  if (use_presso) {
    .mira_run_presso(harmonized_dat, output_folder)
  }

  message("Analysis complete. Results saved to: ", output_folder)

  invisible(list(
    mr_results = mr_or,
    heterogeneity = het_results,
    pleiotropy = ple_results,
    instruments = iv_data
  ))
}


#' Univariable Mendelian Randomization with IEU Exposure and Local Outcome Data
#'
#' @title UVMR Analysis with IEU OpenGWAS Exposure and Local Outcome
#' @description Performs standard univariable Mendelian randomization analysis when exposure
#'   data is retrieved from IEU OpenGWAS and outcome data is available locally.
#'
#' @param gwas_id_exposure Character string, IEU OpenGWAS ID for exposure trait
#' @param outcome_gwas Data frame containing outcome GWAS summary statistics
#' @param exposure_name Character string, descriptive name for exposure (default: "exposure")
#' @param exposure_sample_size Numeric, sample size for exposure GWAS (default: 100000)
#' @param local_clump Logical, whether to use local LD clumping (default: FALSE)
#' @param confounding_snps Character vector of SNP rsIDs to exclude (default: NULL)
#' @param clump_p1 P-value threshold for instrument selection (default: 5e-08)
#' @param clump_r2 LD r-squared threshold for clumping (default: 0.001)
#' @param clump_kb Distance threshold for clumping in kilobases (default: 10000)
#' @param pop Population for LD reference panel (default: "EUR")
#' @param output_folder Path to folder for saving results (default: "MR_results")
#' @param use_presso Logical, whether to perform MR-PRESSO (default: FALSE)
#' @param use_steiger Logical, whether to perform Steiger filtering (default: TRUE)
#' @param use_fvalue Logical, whether to filter by F-statistic (default: TRUE)
#' @param create_plots Logical, whether to generate plots (default: TRUE)
#'
#' @return Invisibly returns a list with MR results
#' @export
mira_uvmr_ieu_local <- function(gwas_id_exposure, outcome_gwas,
                                exposure_name = "exposure",
                                exposure_sample_size = 100000,
                                local_clump = FALSE,
                                confounding_snps = NULL,
                                clump_p1 = 5e-08,
                                clump_r2 = 0.001,
                                clump_kb = 10000,
                                pop = "EUR",
                                output_folder = "MR_results",
                                use_presso = FALSE,
                                use_steiger = TRUE,
                                use_fvalue = TRUE,
                                create_plots = TRUE) {

  require(tidyr)
  require(TwoSampleMR)

  dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

  # Extract instruments from IEU OpenGWAS
  exp_data <- extract_instruments(outcomes = gwas_id_exposure,
                                 p1 = clump_p1,
                                 clump = TRUE,
                                 r2 = clump_r2,
                                 kb = clump_kb,
                                 p2 = 5e-08)

  exp_data$id.exposure <- exposure_name
  exp_data$exposure <- exposure_name
  exp_data$samplesize.exposure <- exposure_sample_size

  if (nrow(exp_data) == 0) {
    message("No instruments found for exposure: ", gwas_id_exposure)
    return(invisible(NULL))
  }

  # Prepare outcome data
  out_data <- outcome_gwas[, c("SNP", "effect_allele.outcome", "other_allele.outcome",
                               "eaf.outcome", "beta.outcome", "se.outcome",
                               "pval.outcome", "id.outcome", "outcome",
                               "samplesize.outcome")]

  # Filter exposure instruments
  exp_iv <- subset(exp_data, pval.exposure < clump_p1)

  if (local_clump) {
    exp_iv <- .mira_local_clump(exp_iv, pop = pop, clump_kb = clump_kb, clump_r2 = clump_r2)
  }

  # Apply F-value filtering
  if (use_fvalue) {
    exp_iv <- .mira_filter_fvalue(exp_iv)
  }

  if (nrow(exp_iv) == 0) {
    message("No instrumental variables found after F-value filtering.")
    return(invisible(NULL))
  }

  # Merge with outcome data
  merged_data <- merge(out_data, exp_iv, by = "SNP", all = FALSE)
  merged_data <- subset(merged_data, pval.outcome > 5e-08)
  merged_data <- merged_data[!duplicated(merged_data$SNP), ]

  if (nrow(merged_data) == 0) {
    message("No SNPs matched in outcome data.")
    return(invisible(NULL))
  }

  # Remove confounding SNPs
  if (!is.null(confounding_snps)) {
    merged_data <- merged_data %>% dplyr::filter(!SNP %in% confounding_snps)
  }

  # Prepare for harmonization
  exp_harmonized <- merged_data[, c("SNP", "effect_allele.exposure", "other_allele.exposure",
                                   "eaf.exposure", "beta.exposure", "se.exposure",
                                   "pval.exposure", "id.exposure", "exposure",
                                   "samplesize.exposure")]

  out_harmonized <- merged_data[, c("SNP", "effect_allele.outcome", "other_allele.outcome",
                                   "eaf.outcome", "beta.outcome", "se.outcome",
                                   "pval.outcome", "id.outcome", "outcome",
                                   "samplesize.outcome")]

  # Harmonize
  harmonized_dat <- harmonise_data(exposure_dat = exp_harmonized,
                                  outcome_dat = out_harmonized,
                                  action = 2)

  # Steiger filtering
  if (use_steiger) {
    harmonized_dat <- steiger_filtering(harmonized_dat)
    harmonized_dat <- subset(harmonized_dat, steiger_dir == TRUE)
  }

  if (nrow(harmonized_dat) == 0) {
    message("No SNPs remaining after harmonization and filtering.")
    return(invisible(NULL))
  }

  # Perform MR
  mr_results <- mr(harmonized_dat)
  mr_or <- generate_odds_ratios(mr_results)
  mr_or$or <- round(mr_or$or, 3)
  mr_or$or_lci95 <- round(mr_or$or_lci95, 3)
  mr_or$or_uci95 <- round(mr_or$or_uci95, 3)
  mr_or$OR_CI <- paste0(mr_or$or, " (", mr_or$or_lci95, "-", mr_or$or_uci95, ")")

  het_results <- mr_heterogeneity(harmonized_dat)
  ple_results <- mr_pleiotropy_test(harmonized_dat)

  iv_data <- harmonized_dat
  iv_data$R2 <- iv_data$beta.exposure^2 * 2 * iv_data$eaf.exposure * (1 - iv_data$eaf.exposure)
  iv_data$Fvalue <- (iv_data$samplesize.exposure - 2) * iv_data$R2 / (1 - iv_data$R2)

  write.csv(mr_or, file.path(output_folder, "MR_results.csv"), row.names = FALSE)
  write.csv(het_results, file.path(output_folder, "heterogeneity.csv"), row.names = FALSE)
  write.csv(ple_results, file.path(output_folder, "pleiotropy.csv"), row.names = FALSE)
  write.csv(iv_data, file.path(output_folder, "instrumental_variables.csv"), row.names = FALSE)

  if (create_plots) {
    .mira_generate_plots(mr_results, harmonized_dat, output_folder)
  }

  if (use_presso) {
    .mira_run_presso(harmonized_dat, output_folder)
  }

  message("Analysis complete. Results saved to: ", output_folder)

  invisible(list(
    mr_results = mr_or,
    heterogeneity = het_results,
    pleiotropy = ple_results,
    instruments = iv_data
  ))
}


#' Univariable Mendelian Randomization with IEU Exposure and IEU Outcome Data
#'
#' @title UVMR Analysis with Both IEU OpenGWAS Datasets
#' @description Performs standard univariable Mendelian randomization analysis when both
#'   exposure and outcome data are retrieved from IEU OpenGWAS database.
#'
#' @param gwas_id_exposure Character string, IEU OpenGWAS ID for exposure trait
#' @param gwas_id_outcome Character string, IEU OpenGWAS ID for outcome trait
#' @param exposure_name Character string, descriptive name for exposure (default: "exposure")
#' @param outcome_name Character string, descriptive name for outcome (default: "outcome")
#' @param exposure_sample_size Numeric, sample size for exposure GWAS (default: 100000)
#' @param outcome_sample_size Numeric, sample size for outcome GWAS (default: 100000)
#' @param local_clump Logical, whether to use local LD clumping (default: FALSE)
#' @param confounding_snps Character vector of SNP rsIDs to exclude (default: NULL)
#' @param clump_p1 P-value threshold for instrument selection (default: 5e-08)
#' @param clump_r2 LD r-squared threshold for clumping (default: 0.001)
#' @param clump_kb Distance threshold for clumping in kilobases (default: 10000)
#' @param pop Population for LD reference panel (default: "EUR")
#' @param output_folder Path to folder for saving results (default: "MR_results")
#' @param use_presso Logical, whether to perform MR-PRESSO (default: FALSE)
#' @param use_steiger Logical, whether to perform Steiger filtering (default: TRUE)
#' @param use_fvalue Logical, whether to filter by F-statistic (default: TRUE)
#' @param create_plots Logical, whether to generate plots (default: TRUE)
#'
#' @return Invisibly returns a list with MR results
#' @export
mira_uvmr_ieu_ieu <- function(gwas_id_exposure, gwas_id_outcome,
                              exposure_name = "exposure",
                              outcome_name = "outcome",
                              exposure_sample_size = 100000,
                              outcome_sample_size = 100000,
                              local_clump = FALSE,
                              confounding_snps = NULL,
                              clump_p1 = 5e-08,
                              clump_r2 = 0.001,
                              clump_kb = 10000,
                              pop = "EUR",
                              output_folder = "MR_results",
                              use_presso = FALSE,
                              use_steiger = TRUE,
                              use_fvalue = TRUE,
                              create_plots = TRUE) {

  require(tidyr)
  require(TwoSampleMR)

  dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

  # Extract instruments from IEU OpenGWAS
  exp_data <- extract_instruments(outcomes = gwas_id_exposure,
                                 p1 = clump_p1,
                                 clump = TRUE,
                                 r2 = clump_r2,
                                 kb = clump_kb,
                                 p2 = 5e-08)

  exp_data$id.exposure <- exposure_name
  exp_data$exposure <- exposure_name
  exp_data$samplesize.exposure <- exposure_sample_size

  # Extract outcome data
  out_data <- extract_outcome_data(snps = exp_data$SNP,
                                  outcomes = gwas_id_outcome,
                                  proxies = TRUE,
                                  maf_threshold = 0.01)

  out_data$id.outcome <- outcome_name
  out_data$outcome <- outcome_name
  out_data$samplesize.outcome <- outcome_sample_size

  if (nrow(out_data) == 0) {
    message("No outcome data retrieved from IEU OpenGWAS.")
    return(invisible(NULL))
  }

  # Filter exposure
  exp_data$pval.exposure <- as.numeric(exp_data$pval.exposure)
  exp_iv <- subset(exp_data, pval.exposure < clump_p1)

  if (local_clump) {
    exp_iv <- .mira_local_clump(exp_iv, pop = pop, clump_kb = clump_kb, clump_r2 = clump_r2)
  }

  # Apply F-value filtering
  if (use_fvalue) {
    exp_iv <- .mira_filter_fvalue(exp_iv)
  }

  if (nrow(exp_iv) == 0) {
    message("No instrumental variables found after F-value filtering.")
    return(invisible(NULL))
  }

  # Merge datasets
  merged_data <- merge(out_data, exp_iv, by = "SNP", all = FALSE)
  merged_data <- subset(merged_data, pval.outcome > 5e-08)
  merged_data <- merged_data[!duplicated(merged_data$SNP), ]

  if (nrow(merged_data) == 0) {
    message("No SNPs remaining after filtering.")
    return(invisible(NULL))
  }

  # Remove confounding SNPs
  if (!is.null(confounding_snps)) {
    merged_data <- merged_data %>% dplyr::filter(!SNP %in% confounding_snps)
  }

  # Prepare for harmonization
  exp_harmonized <- merged_data[, c("SNP", "effect_allele.exposure", "other_allele.exposure",
                                   "eaf.exposure", "beta.exposure", "se.exposure",
                                   "pval.exposure", "id.exposure", "exposure",
                                   "samplesize.exposure")]

  out_harmonized <- merged_data[, c("SNP", "effect_allele.outcome", "other_allele.outcome",
                                   "eaf.outcome", "beta.outcome", "se.outcome",
                                   "pval.outcome", "id.outcome", "outcome",
                                   "samplesize.outcome")]

  # Harmonize
  harmonized_dat <- harmonise_data(exposure_dat = exp_harmonized,
                                  outcome_dat = out_harmonized,
                                  action = 2)

  # Steiger filtering
  if (use_steiger) {
    harmonized_dat <- steiger_filtering(harmonized_dat)
    harmonized_dat <- subset(harmonized_dat, steiger_dir == TRUE)
  }

  if (nrow(harmonized_dat) == 0) {
    message("No SNPs remaining after harmonization and filtering.")
    return(invisible(NULL))
  }

  # Perform MR
  mr_results <- mr(harmonized_dat)
  mr_or <- generate_odds_ratios(mr_results)
  mr_or$or <- round(mr_or$or, 3)
  mr_or$or_lci95 <- round(mr_or$or_lci95, 3)
  mr_or$or_uci95 <- round(mr_or$or_uci95, 3)
  mr_or$OR_CI <- paste0(mr_or$or, " (", mr_or$or_lci95, "-", mr_or$or_uci95, ")")

  het_results <- mr_heterogeneity(harmonized_dat)
  ple_results <- mr_pleiotropy_test(harmonized_dat)

  iv_data <- harmonized_dat
  iv_data$R2 <- iv_data$beta.exposure^2 * 2 * iv_data$eaf.exposure * (1 - iv_data$eaf.exposure)
  iv_data$Fvalue <- (iv_data$samplesize.exposure - 2) * iv_data$R2 / (1 - iv_data$R2)

  write.csv(mr_or, file.path(output_folder, "MR_results.csv"), row.names = FALSE)
  write.csv(het_results, file.path(output_folder, "heterogeneity.csv"), row.names = FALSE)
  write.csv(ple_results, file.path(output_folder, "pleiotropy.csv"), row.names = FALSE)
  write.csv(iv_data, file.path(output_folder, "instrumental_variables.csv"), row.names = FALSE)

  if (create_plots) {
    .mira_generate_plots(mr_results, harmonized_dat, output_folder)
  }

  if (use_presso) {
    .mira_run_presso(harmonized_dat, output_folder)
  }

  message("Analysis complete. Results saved to: ", output_folder)

  invisible(list(
    mr_results = mr_or,
    heterogeneity = het_results,
    pleiotropy = ple_results,
    instruments = iv_data
  ))
}


# Helper Functions ----

#' Local LD Clumping Using PLINK
#' @keywords internal
.mira_local_clump <- function(dat, pop, clump_kb, clump_r2) {

  dat$rsid <- dat$SNP
  dat$id <- dat$id.exposure
  dat$pval <- dat$pval.exposure

  # Define PLINK function
  .ld_clump_local <- function(dat, clump_kb, clump_r2, clump_p, bfile, plink_bin) {
    shell <- ifelse(Sys.info()["sysname"] == "Windows", "cmd", "sh")
    fn <- tempfile()

    write.table(data.frame(SNP = dat[["rsid"]], P = dat[["pval"]]),
                file = fn, row.names = FALSE, col.names = TRUE, quote = FALSE)

    cmd <- paste0(
      shQuote(plink_bin, type = shell), " --bfile ",
      shQuote(bfile, type = shell), " --clump ", shQuote(fn, type = shell),
      " --clump-p1 ", clump_p, " --clump-r2 ", clump_r2,
      " --clump-kb ", clump_kb, " --threads 20 --out ", shQuote(fn, type = shell)
    )

    system(cmd)
    res <- read.table(paste(fn, ".clumps", sep = ""), header = FALSE)
    unlink(paste(fn, "*", sep = ""))

    removed <- subset(dat, !dat[["rsid"]] %in% res[["V3"]])
    if (nrow(removed) > 0) {
      message("Removing ", nrow(removed), " of ", nrow(dat),
              " variants due to LD or absence from reference panel")
    }

    return(subset(dat, dat[["rsid"]] %in% res[["V3"]]))
  }

  # Wrapper function for clumping
  .ld_clump_wrapper <- function(dat, clump_kb, clump_r2, clump_p, pop, bfile, plink_bin) {

    stopifnot("rsid" %in% names(dat))
    stopifnot(is.data.frame(dat))

    if (!"pval" %in% names(dat)) {
      if ("p" %in% names(dat)) {
        warning("No 'pval' column found. Using 'p' column.")
        dat[["pval"]] <- dat[["p"]]
      } else {
        warning("No 'pval' column found. Setting all p-values to clump_p parameter.")
        dat[["pval"]] <- clump_p
      }
    }

    if (!"id" %in% names(dat)) {
      dat$id <- paste0("exp_", sample(1:1e6, 1))
    }

    ids <- unique(dat[["id"]])
    res <- list()

    for (i in seq_along(ids)) {
      x <- subset(dat, dat[["id"]] == ids[i])

      if (nrow(x) == 1) {
        message("Only one SNP for ", ids[i])
        res[[i]] <- x
      } else {
        message("Clumping ", ids[i], ", ", nrow(x), " variants, using ", pop, " population")

        if (is.null(bfile)) {
          res[[i]] <- ld_clump_api(x, clump_kb = clump_kb, clump_r2 = clump_r2,
                                  clump_p = clump_p, pop = pop)
        } else {
          res[[i]] <- .ld_clump_local(x, clump_kb = clump_kb, clump_r2 = clump_r2,
                                     clump_p = clump_p, bfile = bfile, plink_bin = plink_bin)
        }
      }
    }

    res <- dplyr::bind_rows(res)
    return(res)
  }

  # Set file paths for local reference data
  ref_path <- file.path(getwd(), "1kg.v3", pop)
  plink_win <- file.path(getwd(), "1kg.v3/plink2_win64_20231212/plink2")
  plink_mac <- file.path(getwd(), "1kg.v3/plink2_mac_20231212/plink2")

  if (Sys.info()["sysname"] == "Windows") {
    dat <- .ld_clump_wrapper(dat, plink_bin = plink_win, bfile = ref_path,
                            clump_kb = clump_kb, clump_r2 = clump_r2,
                            clump_p = 0.99, pop = pop)
  } else {
    dat <- .ld_clump_wrapper(dat, plink_bin = plink_mac, bfile = ref_path,
                            clump_kb = clump_kb, clump_r2 = clump_r2,
                            clump_p = 0.99, pop = pop)
  }

  dat$rsid <- NULL
  dat$pval <- NULL

  return(dat)
}


#' Filter Instruments by F-statistic
#' @keywords internal
.mira_filter_fvalue <- function(dat) {

  # Calculate F-value based on whether EAF is available
  if (!is.logical(dat$eaf.exposure[1]) && !all(is.na(dat$eaf.exposure))) {
    dat$R2 <- dat$beta.exposure^2 * 2 * dat$eaf.exposure * (1 - dat$eaf.exposure)
    dat$Fvalue <- (dat$samplesize.exposure - 2) * dat$R2 / (1 - dat$R2)
  } else {
    dat$R2 <- NA
    dat$Fvalue <- (dat$beta.exposure / dat$se.exposure)^2
  }

  # Filter by F > 10
  dat_filtered <- subset(dat, Fvalue > 10)

  if (nrow(dat_filtered) < nrow(dat)) {
    message("Removed ", nrow(dat) - nrow(dat_filtered), " variants with F-statistic <= 10")
  }

  return(dat_filtered)
}


#' Generate MR Diagnostic Plots
#' @keywords internal
.mira_generate_plots <- function(mr_results, harmonized_dat, output_folder) {

  # Scatter plot
  pdf(file.path(output_folder, "scatter_plot.pdf"), width = 10, height = 10)
  p1 <- mr_scatter_plot(mr_results[1:min(5, nrow(mr_results)), ], harmonized_dat)
  print(p1[[1]])
  dev.off()

  # Leave-one-out analysis
  pdf(file.path(output_folder, "leave_one_out.pdf"), width = 10, height = 10)
  loo_results <- mr_leaveoneout(harmonized_dat)
  write.csv(loo_results, file.path(output_folder, "leave_one_out.csv"), row.names = FALSE)
  p2 <- mr_leaveoneout_plot(loo_results)
  print(p2[[1]])
  dev.off()

  # Forest plot
  pdf(file.path(output_folder, "forest_plot.pdf"), width = 10, height = 10)
  single_results <- mr_singlesnp(harmonized_dat)
  write.csv(single_results, file.path(output_folder, "forest_plot.csv"), row.names = FALSE)
  p3 <- mr_forest_plot(single_results)
  print(p3[[1]])
  dev.off()

  # Funnel plot
  pdf(file.path(output_folder, "funnel_plot.pdf"), width = 10, height = 10)
  p4 <- mr_funnel_plot(single_results)
  print(p4[[1]])
  dev.off()

  message("Generated diagnostic plots: scatter, leave-one-out, forest, and funnel plots")
}


#' Run MR-PRESSO Outlier Detection
#' @keywords internal
.mira_run_presso <- function(harmonized_dat, output_folder) {

  if (!requireNamespace("MRPRESSO", quietly = TRUE)) {
    warning("MRPRESSO package not installed. Skipping MR-PRESSO analysis.")
    return(invisible(NULL))
  }

  tryCatch({
    presso_results <- MRPRESSO::mr_presso(
      BetaOutcome = "beta.outcome",
      BetaExposure = "beta.exposure",
      SdOutcome = "se.outcome",
      SdExposure = "se.exposure",
      OUTLIERtest = TRUE,
      DISTORTIONtest = TRUE,
      data = harmonized_dat
    )

    # Save main results
    main_results <- presso_results[["Main MR results"]]
    write.csv(main_results, file.path(output_folder, "presso_main_results.csv"), row.names = FALSE)

    # Save global test results
    global_test <- data.frame(
      RSSobs = presso_results[["MR-PRESSO results"]][["Global Test"]][["RSSobs"]],
      Pvalue = presso_results[["MR-PRESSO results"]][["Global Test"]][["Pvalue"]]
    )
    write.csv(global_test, file.path(output_folder, "presso_global_test.csv"), row.names = FALSE)

    message("MR-PRESSO analysis completed")
  }, error = function(e) {
    warning("MR-PRESSO analysis failed: ", e$message)
  })
}
