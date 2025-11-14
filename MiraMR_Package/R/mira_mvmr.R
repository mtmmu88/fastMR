#' Multivariable Mendelian Randomization with Local Exposure and Local Outcome Data
#'
#' @title MVMR Analysis with Both Local GWAS Datasets
#' @description Performs multivariable Mendelian randomization analysis when both exposure
#'   and outcome data are available locally as GWAS summary statistics. Supports multiple
#'   MR methods including IVW, LASSO, Egger, and median-based approaches.
#'
#' @param exposure_iv_data Data frame containing merged instrumental variables for multiple
#'   exposures. Must include columns: SNP, effect_allele.exposure, other_allele.exposure,
#'   eaf.exposure, beta.exposure, se.exposure, pval.exposure, id.exposure, exposure
#' @param outcome_gwas Data frame containing outcome GWAS summary statistics with columns:
#'   SNP, effect_allele.outcome, other_allele.outcome, eaf.outcome, beta.outcome,
#'   se.outcome, pval.outcome, id.outcome, outcome
#' @param use_ivw Logical, whether to perform IVW method estimation (default: TRUE)
#' @param use_lasso Logical, whether to perform LASSO method estimation (default: FALSE)
#' @param use_egger Logical, whether to perform Egger method estimation (default: FALSE)
#' @param use_median Logical, whether to perform weighted median method estimation (default: FALSE)
#'
#' @return Results from the selected MR method(s), with odds ratios if IVW is selected
#' @export
#'
#' @examples
#' \dontrun{
#' results <- mira_mvmr_local_local(
#'   exposure_iv_data = merged_exposures,
#'   outcome_gwas = outcome_data,
#'   use_ivw = TRUE
#' )
#' }
mira_mvmr_local_local <- function(exposure_iv_data, outcome_gwas,
                                  use_ivw = TRUE,
                                  use_lasso = FALSE,
                                  use_egger = FALSE,
                                  use_median = FALSE) {

  require(tidyr)
  require(TwoSampleMR)
  require(MendelianRandomization)

  # Merge exposure IVs with outcome data
  merged_data <- merge(exposure_iv_data, outcome_gwas, by = "SNP", all = FALSE)

  # Remove duplicate SNPs
  merged_data <- merged_data[!duplicated(merged_data$SNP), ]

  # Extract outcome data for harmonization
  outcome_temp <- merged_data[, c("SNP", "beta.outcome")]
  exposure_temp <- merge(exposure_iv_data, outcome_temp, by = "SNP", all = FALSE)

  # Prepare outcome data in standard format
  outcome_harmonized <- merged_data[, c("SNP", "effect_allele.outcome", "other_allele.outcome",
                                       "eaf.outcome", "beta.outcome", "se.outcome",
                                       "pval.outcome", "id.outcome", "outcome")]

  # Prepare exposure data in standard format
  exposure_harmonized <- exposure_temp[, c("SNP", "effect_allele.exposure", "other_allele.exposure",
                                          "eaf.exposure", "beta.exposure", "se.exposure",
                                          "pval.exposure", "id.exposure", "exposure")]

  # Harmonize multivariable data
  mvmr_data <- mv_harmonise_data(exposure_harmonized, outcome_harmonized)

  # Convert to MendelianRandomization package format (S4)
  mvmr_input <- mr_mvinput(
    bx = mvmr_data$exposure_beta,
    bxse = mvmr_data$exposure_se,
    by = mvmr_data$outcome_beta,
    byse = mvmr_data$outcome_se,
    correlation = matrix()
  )

  # Perform requested MR methods
  if (use_ivw) {
    ivw_results <- mv_multiple(mvmr_data)
    ivw_or <- generate_odds_ratios(ivw_results$result)
    return(ivw_or)
  }

  if (use_lasso) {
    lasso_results <- mr_mvlasso(mvmr_input)
    return(lasso_results)
  }

  if (use_egger) {
    egger_results <- mr_mvegger(mvmr_input)
    return(egger_results)
  }

  if (use_median) {
    median_results <- mr_mvmedian(mvmr_input)
    return(median_results)
  }
}


#' Multivariable Mendelian Randomization with Local Exposure and IEU Outcome Data
#'
#' @title MVMR Analysis with Local Exposures and IEU OpenGWAS Outcome
#' @description Performs multivariable Mendelian randomization analysis when exposure
#'   data is available locally and outcome data is retrieved from IEU OpenGWAS database.
#'
#' @param exposure_iv_data Data frame containing merged instrumental variables for multiple exposures
#' @param gwas_id_outcome Character string, IEU OpenGWAS ID for outcome trait (e.g., "ieu-a-2")
#' @param use_ivw Logical, whether to perform IVW method (default: TRUE)
#' @param use_lasso Logical, whether to perform LASSO method (default: FALSE)
#' @param use_egger Logical, whether to perform Egger method (default: FALSE)
#' @param use_median Logical, whether to perform weighted median method (default: FALSE)
#'
#' @return Results from the selected MR method(s)
#' @export
#'
#' @examples
#' \dontrun{
#' results <- mira_mvmr_local_ieu(
#'   exposure_iv_data = merged_exposures,
#'   gwas_id_outcome = "ieu-a-7",
#'   use_ivw = TRUE
#' )
#' }
mira_mvmr_local_ieu <- function(exposure_iv_data, gwas_id_outcome,
                                use_ivw = TRUE,
                                use_lasso = FALSE,
                                use_egger = FALSE,
                                use_median = FALSE) {

  require(tidyr)
  require(TwoSampleMR)
  require(MendelianRandomization)

  # Extract outcome data from IEU OpenGWAS
  outcome_data <- extract_outcome_data(
    snps = exposure_iv_data$SNP,
    outcomes = gwas_id_outcome,
    proxies = TRUE,
    rsq = 0.8,
    maf_threshold = 0.1
  )

  # Remove duplicate SNPs
  outcome_data <- outcome_data[!duplicated(outcome_data$SNP), ]

  # Harmonize multivariable data
  mvmr_data <- mv_harmonise_data(exposure_iv_data, outcome_data)

  # Convert to MendelianRandomization package format
  mvmr_input <- mr_mvinput(
    bx = mvmr_data$exposure_beta,
    bxse = mvmr_data$exposure_se,
    by = mvmr_data$outcome_beta,
    byse = mvmr_data$outcome_se,
    correlation = matrix()
  )

  # Perform requested MR methods
  if (use_ivw) {
    ivw_results <- mv_multiple(mvmr_data)
    ivw_or <- generate_odds_ratios(ivw_results$result)
    return(ivw_or)
  }

  if (use_lasso) {
    lasso_results <- mr_mvlasso(mvmr_input)
    return(lasso_results)
  }

  if (use_egger) {
    egger_results <- mr_mvegger(mvmr_input)
    return(egger_results)
  }

  if (use_median) {
    median_results <- mr_mvmedian(mvmr_input)
    return(median_results)
  }
}


#' Multivariable Mendelian Randomization with IEU Exposure and Local Outcome Data
#'
#' @title MVMR Analysis with IEU OpenGWAS Exposures and Local Outcome
#' @description Performs multivariable Mendelian randomization analysis when exposure
#'   data is retrieved from IEU OpenGWAS and outcome data is available locally.
#'
#' @param gwas_id_exposures Character vector of IEU OpenGWAS IDs for exposure traits
#' @param outcome_gwas Data frame containing outcome GWAS summary statistics
#' @param clump_r2 LD r-squared threshold for clumping (default: 0.001)
#' @param clump_kb Distance threshold for clumping in kilobases (default: 10000)
#' @param find_proxies Logical, whether to search for proxy SNPs (default: TRUE)
#' @param pval_threshold P-value threshold for instrument selection (default: 5e-08)
#' @param pop Population for LD reference panel (default: "EUR")
#' @param use_ivw Logical, whether to perform IVW method (default: TRUE)
#' @param use_lasso Logical, whether to perform LASSO method (default: FALSE)
#' @param use_egger Logical, whether to perform Egger method (default: FALSE)
#' @param use_median Logical, whether to perform weighted median method (default: FALSE)
#'
#' @return Results from the selected MR method(s)
#' @export
#'
#' @examples
#' \dontrun{
#' results <- mira_mvmr_ieu_local(
#'   gwas_id_exposures = c("ieu-a-2", "ieu-a-300"),
#'   outcome_gwas = outcome_data,
#'   use_ivw = TRUE
#' )
#' }
mira_mvmr_ieu_local <- function(gwas_id_exposures = NULL,
                                outcome_gwas,
                                clump_r2 = 0.001,
                                clump_kb = 10000,
                                find_proxies = TRUE,
                                pval_threshold = 5e-08,
                                pop = "EUR",
                                use_ivw = TRUE,
                                use_lasso = FALSE,
                                use_egger = FALSE,
                                use_median = FALSE) {

  require(tidyr)
  require(TwoSampleMR)
  require(MendelianRandomization)

  # Extract exposure instruments from IEU OpenGWAS
  exposure_data <- mv_extract_exposures(
    id_exposure = gwas_id_exposures,
    clump_r2 = clump_r2,
    clump_kb = clump_kb,
    find_proxies = find_proxies,
    force_server = FALSE,
    pval_threshold = pval_threshold,
    pop = pop
  )

  # Merge exposure data with outcome GWAS
  merged_data <- merge(exposure_data, outcome_gwas, by = "SNP", all = FALSE)

  # Remove duplicate SNPs
  merged_data <- merged_data[!duplicated(merged_data$SNP), ]

  # Extract outcome data for harmonization
  outcome_temp <- merged_data[, c("SNP", "beta.outcome")]
  exposure_temp <- merge(exposure_data, outcome_temp, by = "SNP", all = FALSE)

  # Prepare data in standard format
  outcome_harmonized <- merged_data[, c("SNP", "effect_allele.outcome", "other_allele.outcome",
                                       "eaf.outcome", "beta.outcome", "se.outcome",
                                       "pval.outcome", "id.outcome", "outcome")]

  exposure_harmonized <- exposure_temp[, c("SNP", "effect_allele.exposure", "other_allele.exposure",
                                          "eaf.exposure", "beta.exposure", "se.exposure",
                                          "pval.exposure", "id.exposure", "exposure")]

  # Harmonize multivariable data
  mvmr_data <- mv_harmonise_data(exposure_harmonized, outcome_harmonized)

  # Convert to MendelianRandomization package format
  mvmr_input <- mr_mvinput(
    bx = mvmr_data$exposure_beta,
    bxse = mvmr_data$exposure_se,
    by = mvmr_data$outcome_beta,
    byse = mvmr_data$outcome_se,
    correlation = matrix()
  )

  # Perform requested MR methods
  if (use_ivw) {
    ivw_results <- mv_multiple(mvmr_data)
    ivw_or <- generate_odds_ratios(ivw_results$result)
    return(ivw_or)
  }

  if (use_lasso) {
    lasso_results <- mr_mvlasso(mvmr_input)
    return(lasso_results)
  }

  if (use_egger) {
    egger_results <- mr_mvegger(mvmr_input)
    return(egger_results)
  }

  if (use_median) {
    median_results <- mr_mvmedian(mvmr_input)
    return(median_results)
  }
}


#' Multivariable Mendelian Randomization with IEU Exposure and IEU Outcome Data
#'
#' @title MVMR Analysis with Both IEU OpenGWAS Datasets
#' @description Performs multivariable Mendelian randomization analysis when both exposure
#'   and outcome data are retrieved from IEU OpenGWAS database.
#'
#' @param gwas_id_exposures Character vector of IEU OpenGWAS IDs for exposure traits
#' @param gwas_id_outcome Character string, IEU OpenGWAS ID for outcome trait
#' @param clump_r2 LD r-squared threshold for clumping (default: 0.001)
#' @param clump_kb Distance threshold for clumping in kilobases (default: 10000)
#' @param find_proxies Logical, whether to search for proxy SNPs (default: TRUE)
#' @param pval_threshold P-value threshold for instrument selection (default: 5e-08)
#' @param pop Population for LD reference panel (default: "EUR")
#' @param use_ivw Logical, whether to perform IVW method (default: TRUE)
#' @param use_lasso Logical, whether to perform LASSO method (default: FALSE)
#' @param use_egger Logical, whether to perform Egger method (default: FALSE)
#' @param use_median Logical, whether to perform weighted median method (default: FALSE)
#'
#' @return Results from the selected MR method(s)
#' @export
#'
#' @examples
#' \dontrun{
#' results <- mira_mvmr_ieu_ieu(
#'   gwas_id_exposures = c("ieu-a-2", "ieu-a-300"),
#'   gwas_id_outcome = "ieu-a-7",
#'   use_ivw = TRUE
#' )
#' }
mira_mvmr_ieu_ieu <- function(gwas_id_exposures = NULL,
                              gwas_id_outcome = NULL,
                              clump_r2 = 0.001,
                              clump_kb = 10000,
                              find_proxies = TRUE,
                              pval_threshold = 5e-08,
                              pop = "EUR",
                              use_ivw = TRUE,
                              use_lasso = FALSE,
                              use_egger = FALSE,
                              use_median = FALSE) {

  require(tidyr)
  require(TwoSampleMR)
  require(MendelianRandomization)

  # Extract exposure instruments from IEU OpenGWAS
  exposure_data <- mv_extract_exposures(
    id_exposure = gwas_id_exposures,
    clump_r2 = clump_r2,
    clump_kb = clump_kb,
    find_proxies = find_proxies,
    force_server = FALSE,
    pval_threshold = pval_threshold,
    pop = pop
  )

  # Extract outcome data from IEU OpenGWAS
  outcome_data <- extract_outcome_data(
    snps = exposure_data$SNP,
    outcomes = gwas_id_outcome,
    proxies = TRUE,
    rsq = 0.8,
    maf_threshold = 0.1
  )

  # Remove duplicate SNPs
  outcome_data <- outcome_data[!duplicated(outcome_data$SNP), ]

  # Harmonize multivariable data
  mvmr_data <- mv_harmonise_data(exposure_data, outcome_data)

  # Convert to MendelianRandomization package format
  mvmr_input <- mr_mvinput(
    bx = mvmr_data$exposure_beta,
    bxse = mvmr_data$exposure_se,
    by = mvmr_data$outcome_beta,
    byse = mvmr_data$outcome_se,
    correlation = matrix()
  )

  # Perform requested MR methods
  if (use_ivw) {
    ivw_results <- mv_multiple(mvmr_data)
    ivw_or <- generate_odds_ratios(ivw_results$result)
    return(ivw_or)
  }

  if (use_lasso) {
    lasso_results <- mr_mvlasso(mvmr_input)
    return(lasso_results)
  }

  if (use_egger) {
    egger_results <- mr_mvegger(mvmr_input)
    return(egger_results)
  }

  if (use_median) {
    median_results <- mr_mvmedian(mvmr_input)
    return(median_results)
  }
}
