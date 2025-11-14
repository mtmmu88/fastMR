#' Merge Instrumental Variables for Multivariable MR (0 IEU + 2 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when all exposures come from local (non-IEU) GWAS data. This function combines
#' IVs from 2 local exposure sources.
#'
#' @param data1_iv Data frame containing instrumental variables for exposure 1
#' @param data1_gwas Data frame containing GWAS summary data for exposure 1
#' @param data2_iv Data frame containing instrumental variables for exposure 2
#' @param data2_gwas Data frame containing GWAS summary data for exposure 2
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=2). Only SNPs that appear exactly twice are retained.
#'
#' @details
#' This function performs cross-mapping of instrumental variables between exposures:
#' - For each exposure, it extracts its own IVs
#' - For each exposure, it finds the effect of other exposures' IVs in its GWAS data
#' - Combines all IVs and filters to keep only SNPs present in all exposures
#'
#' @export
mira_ieu_to_local_0_2 <- function(data1_iv, data1_gwas, data2_iv, data2_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Find exposure 1's IVs in exposure 2's GWAS data
  data_h_SNP_steiger_mv1_2 <- merge(data1_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)

  # Find exposure 2's IVs in exposure 1's GWAS data
  data_h_SNP_steiger_mv2_1 <- merge(data2_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables for exposure 1
  MVIV1_1 <- data1_iv[, exp_name]  # Own IVs
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]  # Exposure 2's IVs in exposure 1's GWAS

  # Combine instrumental variables for exposure 2
  MVIV2_2 <- data2_iv[, exp_name]  # Own IVs
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]  # Exposure 1's IVs in exposure 2's GWAS

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(MVIV1_1, MVIV1_2, MVIV2_2, MVIV2_1)

  # Keep only SNPs that appear exactly twice (once in each exposure)
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 2) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (0 IEU + 3 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when all exposures come from local (non-IEU) GWAS data. This function combines
#' IVs from 3 local exposure sources.
#'
#' @param data1_iv Data frame containing instrumental variables for exposure 1
#' @param data1_gwas Data frame containing GWAS summary data for exposure 1
#' @param data2_iv Data frame containing instrumental variables for exposure 2
#' @param data2_gwas Data frame containing GWAS summary data for exposure 2
#' @param data3_iv Data frame containing instrumental variables for exposure 3
#' @param data3_gwas Data frame containing GWAS summary data for exposure 3
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=3). Only SNPs that appear exactly three times are retained.
#'
#' @export
mira_ieu_to_local_0_3 <- function(data1_iv, data1_gwas, data2_iv, data2_gwas, data3_iv, data3_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Find exposure 1's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv1_2 <- merge(data1_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Find exposure 2's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv2_1 <- merge(data2_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Find exposure 3's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv3_1 <- merge(data3_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_2 <- merge(data3_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables for each exposure
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3,
    MVIV2_2, MVIV2_1, MVIV2_3,
    MVIV3_3, MVIV3_1, MVIV3_2
  )

  # Keep only SNPs that appear exactly three times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 3) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (0 IEU + 4 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when all exposures come from local (non-IEU) GWAS data. This function combines
#' IVs from 4 local exposure sources.
#'
#' @param data1_iv Data frame containing instrumental variables for exposure 1
#' @param data1_gwas Data frame containing GWAS summary data for exposure 1
#' @param data2_iv Data frame containing instrumental variables for exposure 2
#' @param data2_gwas Data frame containing GWAS summary data for exposure 2
#' @param data3_iv Data frame containing instrumental variables for exposure 3
#' @param data3_gwas Data frame containing GWAS summary data for exposure 3
#' @param data4_iv Data frame containing instrumental variables for exposure 4
#' @param data4_gwas Data frame containing GWAS summary data for exposure 4
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=4). Only SNPs that appear exactly four times are retained.
#'
#' @export
mira_ieu_to_local_0_4 <- function(data1_iv, data1_gwas, data2_iv, data2_gwas,
                                   data3_iv, data3_gwas, data4_iv, data4_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Find exposure 1's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv1_2 <- merge(data1_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_4 <- merge(data1_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Find exposure 2's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv2_1 <- merge(data2_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_4 <- merge(data2_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Find exposure 3's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv3_1 <- merge(data3_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_2 <- merge(data3_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_4 <- merge(data3_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Find exposure 4's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv4_1 <- merge(data4_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_2 <- merge(data4_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_3 <- merge(data4_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables for each exposure
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]
  MVIV1_4 <- data_h_SNP_steiger_mv4_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]
  MVIV2_4 <- data_h_SNP_steiger_mv4_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]
  MVIV3_4 <- data_h_SNP_steiger_mv4_3[, exp_name]

  MVIV4_4 <- data4_iv[, exp_name]
  MVIV4_1 <- data_h_SNP_steiger_mv1_4[, exp_name]
  MVIV4_2 <- data_h_SNP_steiger_mv2_4[, exp_name]
  MVIV4_3 <- data_h_SNP_steiger_mv3_4[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3, MVIV1_4,
    MVIV2_2, MVIV2_1, MVIV2_3, MVIV2_4,
    MVIV3_3, MVIV3_1, MVIV3_2, MVIV3_4,
    MVIV4_4, MVIV4_1, MVIV4_2, MVIV4_3
  )

  # Keep only SNPs that appear exactly four times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 4) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (0 IEU + 5 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when all exposures come from local (non-IEU) GWAS data. This function combines
#' IVs from 5 local exposure sources.
#'
#' @param data1_iv Data frame containing instrumental variables for exposure 1
#' @param data1_gwas Data frame containing GWAS summary data for exposure 1
#' @param data2_iv Data frame containing instrumental variables for exposure 2
#' @param data2_gwas Data frame containing GWAS summary data for exposure 2
#' @param data3_iv Data frame containing instrumental variables for exposure 3
#' @param data3_gwas Data frame containing GWAS summary data for exposure 3
#' @param data4_iv Data frame containing instrumental variables for exposure 4
#' @param data4_gwas Data frame containing GWAS summary data for exposure 4
#' @param data5_iv Data frame containing instrumental variables for exposure 5
#' @param data5_gwas Data frame containing GWAS summary data for exposure 5
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=5). Only SNPs that appear exactly five times are retained.
#'
#' @export
mira_ieu_to_local_0_5 <- function(data1_iv, data1_gwas, data2_iv, data2_gwas, data3_iv, data3_gwas,
                                   data4_iv, data4_gwas, data5_iv, data5_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Find exposure 1's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv1_2 <- merge(data1_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_4 <- merge(data1_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_5 <- merge(data1_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Find exposure 2's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv2_1 <- merge(data2_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_4 <- merge(data2_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_5 <- merge(data2_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Find exposure 3's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv3_1 <- merge(data3_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_2 <- merge(data3_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_4 <- merge(data3_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_5 <- merge(data3_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Find exposure 4's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv4_1 <- merge(data4_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_2 <- merge(data4_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_3 <- merge(data4_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_5 <- merge(data4_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Find exposure 5's IVs in other exposures' GWAS data
  data_h_SNP_steiger_mv5_1 <- merge(data5_iv[, c("SNP", "outcome")], data1_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv5_2 <- merge(data5_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv5_3 <- merge(data5_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv5_4 <- merge(data5_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables for each exposure
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]
  MVIV1_4 <- data_h_SNP_steiger_mv4_1[, exp_name]
  MVIV1_5 <- data_h_SNP_steiger_mv5_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]
  MVIV2_4 <- data_h_SNP_steiger_mv4_2[, exp_name]
  MVIV2_5 <- data_h_SNP_steiger_mv5_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]
  MVIV3_4 <- data_h_SNP_steiger_mv4_3[, exp_name]
  MVIV3_5 <- data_h_SNP_steiger_mv5_3[, exp_name]

  MVIV4_4 <- data4_iv[, exp_name]
  MVIV4_1 <- data_h_SNP_steiger_mv1_4[, exp_name]
  MVIV4_2 <- data_h_SNP_steiger_mv2_4[, exp_name]
  MVIV4_3 <- data_h_SNP_steiger_mv3_4[, exp_name]
  MVIV4_5 <- data_h_SNP_steiger_mv5_4[, exp_name]

  MVIV5_5 <- data5_iv[, exp_name]
  MVIV5_1 <- data_h_SNP_steiger_mv1_5[, exp_name]
  MVIV5_2 <- data_h_SNP_steiger_mv2_5[, exp_name]
  MVIV5_3 <- data_h_SNP_steiger_mv3_5[, exp_name]
  MVIV5_4 <- data_h_SNP_steiger_mv4_5[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3, MVIV1_4, MVIV1_5,
    MVIV2_2, MVIV2_1, MVIV2_3, MVIV2_4, MVIV2_5,
    MVIV3_3, MVIV3_1, MVIV3_2, MVIV3_4, MVIV3_5,
    MVIV4_4, MVIV4_1, MVIV4_2, MVIV4_3, MVIV4_5,
    MVIV5_5, MVIV5_1, MVIV5_2, MVIV5_3, MVIV5_4
  )

  # Keep only SNPs that appear exactly five times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 5) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (1 IEU + 1 Local Exposure)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when combining 1 IEU exposure with 1 local (non-IEU) exposure.
#'
#' @param data1_iv Data frame containing instrumental variables for IEU exposure
#' @param gwas_id Character string with IEU GWAS ID for exposure 1
#' @param data2_iv Data frame containing instrumental variables for local exposure
#' @param data2_gwas Data frame containing GWAS summary data for local exposure
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in both exposures (n=2). Only SNPs that appear exactly twice are retained.
#'
#' @export
mira_ieu_to_local_1_1 <- function(data1_iv, gwas_id, data2_iv, data2_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Extract local exposure's IVs from IEU database
  data_h_SNP_steiger_mv2_1 <- extract_outcome_data(
    snps = data2_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv2_1 <- data_h_SNP_steiger_mv2_1[, out_name]
  colnames(data_h_SNP_steiger_mv2_1) <- exp_name

  # Find IEU exposure's IVs in local GWAS data
  data_h_SNP_steiger_mv1_2 <- merge(data1_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(MVIV1_1, MVIV1_2, MVIV2_2, MVIV2_1)

  # Keep only SNPs that appear exactly twice
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 2) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (1 IEU + 2 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when combining 1 IEU exposure with 2 local (non-IEU) exposures.
#'
#' @param data1_iv Data frame containing instrumental variables for IEU exposure
#' @param gwas_id Character string with IEU GWAS ID for exposure 1
#' @param data2_iv Data frame containing instrumental variables for local exposure 2
#' @param data2_gwas Data frame containing GWAS summary data for local exposure 2
#' @param data3_iv Data frame containing instrumental variables for local exposure 3
#' @param data3_gwas Data frame containing GWAS summary data for local exposure 3
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=3). Only SNPs that appear exactly three times are retained.
#'
#' @export
mira_ieu_to_local_1_2 <- function(data1_iv, gwas_id, data2_iv, data2_gwas, data3_iv, data3_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Find IEU exposure's IVs in local GWAS data
  data_h_SNP_steiger_mv1_2 <- merge(data1_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 2's IVs from IEU database
  data_h_SNP_steiger_mv2_1 <- extract_outcome_data(
    snps = data2_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv2_1 <- data_h_SNP_steiger_mv2_1[, out_name]
  colnames(data_h_SNP_steiger_mv2_1) <- exp_name
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 3's IVs from IEU database
  data_h_SNP_steiger_mv3_1 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_1 <- data_h_SNP_steiger_mv3_1[, out_name]
  colnames(data_h_SNP_steiger_mv3_1) <- exp_name
  data_h_SNP_steiger_mv3_2 <- merge(data3_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3,
    MVIV2_2, MVIV2_1, MVIV2_3,
    MVIV3_3, MVIV3_1, MVIV3_2
  )

  # Keep only SNPs that appear exactly three times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 3) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (1 IEU + 3 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when combining 1 IEU exposure with 3 local (non-IEU) exposures.
#'
#' @param data1_iv Data frame containing instrumental variables for IEU exposure
#' @param gwas_id Character string with IEU GWAS ID for exposure 1
#' @param data2_iv Data frame containing instrumental variables for local exposure 2
#' @param data2_gwas Data frame containing GWAS summary data for local exposure 2
#' @param data3_iv Data frame containing instrumental variables for local exposure 3
#' @param data3_gwas Data frame containing GWAS summary data for local exposure 3
#' @param data4_iv Data frame containing instrumental variables for local exposure 4
#' @param data4_gwas Data frame containing GWAS summary data for local exposure 4
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=4). Only SNPs that appear exactly four times are retained.
#'
#' @export
mira_ieu_to_local_1_3 <- function(data1_iv, gwas_id, data2_iv, data2_gwas,
                                   data3_iv, data3_gwas, data4_iv, data4_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Find IEU exposure's IVs in local GWAS data
  data_h_SNP_steiger_mv1_2 <- merge(data1_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_4 <- merge(data1_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 2's IVs from IEU database
  data_h_SNP_steiger_mv2_1 <- extract_outcome_data(
    snps = data2_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv2_1 <- data_h_SNP_steiger_mv2_1[, out_name]
  colnames(data_h_SNP_steiger_mv2_1) <- exp_name
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_4 <- merge(data2_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 3's IVs from IEU database
  data_h_SNP_steiger_mv3_1 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_1 <- data_h_SNP_steiger_mv3_1[, out_name]
  colnames(data_h_SNP_steiger_mv3_1) <- exp_name
  data_h_SNP_steiger_mv3_2 <- merge(data3_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_4 <- merge(data3_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 4's IVs from IEU database
  data_h_SNP_steiger_mv4_1 <- extract_outcome_data(
    snps = data4_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv4_1 <- data_h_SNP_steiger_mv4_1[, out_name]
  colnames(data_h_SNP_steiger_mv4_1) <- exp_name
  data_h_SNP_steiger_mv4_2 <- merge(data4_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_3 <- merge(data4_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]
  MVIV1_4 <- data_h_SNP_steiger_mv4_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]
  MVIV2_4 <- data_h_SNP_steiger_mv4_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]
  MVIV3_4 <- data_h_SNP_steiger_mv4_3[, exp_name]

  MVIV4_4 <- data4_iv[, exp_name]
  MVIV4_1 <- data_h_SNP_steiger_mv1_4[, exp_name]
  MVIV4_2 <- data_h_SNP_steiger_mv2_4[, exp_name]
  MVIV4_3 <- data_h_SNP_steiger_mv3_4[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3, MVIV1_4,
    MVIV2_2, MVIV2_1, MVIV2_3, MVIV2_4,
    MVIV3_3, MVIV3_1, MVIV3_2, MVIV3_4,
    MVIV4_4, MVIV4_1, MVIV4_2, MVIV4_3
  )

  # Keep only SNPs that appear exactly four times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 4) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (1 IEU + 4 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when combining 1 IEU exposure with 4 local (non-IEU) exposures.
#'
#' @param data1_iv Data frame containing instrumental variables for IEU exposure
#' @param gwas_id Character string with IEU GWAS ID for exposure 1
#' @param data2_iv Data frame containing instrumental variables for local exposure 2
#' @param data2_gwas Data frame containing GWAS summary data for local exposure 2
#' @param data3_iv Data frame containing instrumental variables for local exposure 3
#' @param data3_gwas Data frame containing GWAS summary data for local exposure 3
#' @param data4_iv Data frame containing instrumental variables for local exposure 4
#' @param data4_gwas Data frame containing GWAS summary data for local exposure 4
#' @param data5_iv Data frame containing instrumental variables for local exposure 5
#' @param data5_gwas Data frame containing GWAS summary data for local exposure 5
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=5). Only SNPs that appear exactly five times are retained.
#'
#' @export
mira_ieu_to_local_1_4 <- function(data1_iv, gwas_id, data2_iv, data2_gwas, data3_iv, data3_gwas,
                                   data4_iv, data4_gwas, data5_iv, data5_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Find IEU exposure's IVs in local GWAS data
  data_h_SNP_steiger_mv1_2 <- merge(data1_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_4 <- merge(data1_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_5 <- merge(data1_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Extract local exposures' IVs from IEU database
  data_h_SNP_steiger_mv2_1 <- extract_outcome_data(
    snps = data2_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv2_1 <- data_h_SNP_steiger_mv2_1[, out_name]
  colnames(data_h_SNP_steiger_mv2_1) <- exp_name
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_4 <- merge(data2_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_5 <- merge(data2_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  data_h_SNP_steiger_mv3_1 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_1 <- data_h_SNP_steiger_mv3_1[, out_name]
  colnames(data_h_SNP_steiger_mv3_1) <- exp_name
  data_h_SNP_steiger_mv3_2 <- merge(data3_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_4 <- merge(data3_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_5 <- merge(data3_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  data_h_SNP_steiger_mv4_1 <- extract_outcome_data(
    snps = data4_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv4_1 <- data_h_SNP_steiger_mv4_1[, out_name]
  colnames(data_h_SNP_steiger_mv4_1) <- exp_name
  data_h_SNP_steiger_mv4_2 <- merge(data4_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_3 <- merge(data4_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_5 <- merge(data4_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  data_h_SNP_steiger_mv5_1 <- extract_outcome_data(
    snps = data5_iv$SNP,
    outcomes = gwas_id,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv5_1 <- data_h_SNP_steiger_mv5_1[, out_name]
  colnames(data_h_SNP_steiger_mv5_1) <- exp_name
  data_h_SNP_steiger_mv5_2 <- merge(data5_iv[, c("SNP", "outcome")], data2_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv5_3 <- merge(data5_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv5_4 <- merge(data5_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]
  MVIV1_4 <- data_h_SNP_steiger_mv4_1[, exp_name]
  MVIV1_5 <- data_h_SNP_steiger_mv5_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]
  MVIV2_4 <- data_h_SNP_steiger_mv4_2[, exp_name]
  MVIV2_5 <- data_h_SNP_steiger_mv5_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]
  MVIV3_4 <- data_h_SNP_steiger_mv4_3[, exp_name]
  MVIV3_5 <- data_h_SNP_steiger_mv5_3[, exp_name]

  MVIV4_4 <- data4_iv[, exp_name]
  MVIV4_1 <- data_h_SNP_steiger_mv1_4[, exp_name]
  MVIV4_2 <- data_h_SNP_steiger_mv2_4[, exp_name]
  MVIV4_3 <- data_h_SNP_steiger_mv3_4[, exp_name]
  MVIV4_5 <- data_h_SNP_steiger_mv5_4[, exp_name]

  MVIV5_5 <- data5_iv[, exp_name]
  MVIV5_1 <- data_h_SNP_steiger_mv1_5[, exp_name]
  MVIV5_2 <- data_h_SNP_steiger_mv2_5[, exp_name]
  MVIV5_3 <- data_h_SNP_steiger_mv3_5[, exp_name]
  MVIV5_4 <- data_h_SNP_steiger_mv4_5[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3, MVIV1_4, MVIV1_5,
    MVIV2_2, MVIV2_1, MVIV2_3, MVIV2_4, MVIV2_5,
    MVIV3_3, MVIV3_1, MVIV3_2, MVIV3_4, MVIV3_5,
    MVIV4_4, MVIV4_1, MVIV4_2, MVIV4_3, MVIV4_5,
    MVIV5_5, MVIV5_1, MVIV5_2, MVIV5_3, MVIV5_4
  )

  # Keep only SNPs that appear exactly five times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 5) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (2 IEU + 1 Local Exposure)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when combining 2 IEU exposures with 1 local (non-IEU) exposure.
#'
#' @param data1_iv Data frame containing instrumental variables for IEU exposure 1
#' @param gwas_id1 Character string with IEU GWAS ID for exposure 1
#' @param data2_iv Data frame containing instrumental variables for IEU exposure 2
#' @param gwas_id2 Character string with IEU GWAS ID for exposure 2
#' @param data3_iv Data frame containing instrumental variables for local exposure
#' @param data3_gwas Data frame containing GWAS summary data for local exposure
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=3). Only SNPs that appear exactly three times are retained.
#'
#' @export
mira_ieu_to_local_2_1 <- function(data1_iv, gwas_id1, data2_iv, gwas_id2, data3_iv, data3_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Extract IEU exposure 1's IVs from IEU exposure 2's database
  data_h_SNP_steiger_mv1_2 <- extract_outcome_data(
    snps = data1_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv1_2 <- data_h_SNP_steiger_mv1_2[, out_name]
  colnames(data_h_SNP_steiger_mv1_2) <- exp_name
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Extract IEU exposure 2's IVs from IEU exposure 1's database
  data_h_SNP_steiger_mv2_1 <- extract_outcome_data(
    snps = data2_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv2_1 <- data_h_SNP_steiger_mv2_1[, out_name]
  colnames(data_h_SNP_steiger_mv2_1) <- exp_name
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Extract local exposure's IVs from both IEU databases
  data_h_SNP_steiger_mv3_1 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_1 <- data_h_SNP_steiger_mv3_1[, out_name]
  colnames(data_h_SNP_steiger_mv3_1) <- exp_name

  data_h_SNP_steiger_mv3_2 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_2 <- data_h_SNP_steiger_mv3_2[, out_name]
  colnames(data_h_SNP_steiger_mv3_2) <- exp_name

  # Combine instrumental variables
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3,
    MVIV2_2, MVIV2_1, MVIV2_3,
    MVIV3_3, MVIV3_1, MVIV3_2
  )

  # Keep only SNPs that appear exactly three times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 3) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (2 IEU + 2 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when combining 2 IEU exposures with 2 local (non-IEU) exposures.
#'
#' @param data1_iv Data frame containing instrumental variables for IEU exposure 1
#' @param gwas_id1 Character string with IEU GWAS ID for exposure 1
#' @param data2_iv Data frame containing instrumental variables for IEU exposure 2
#' @param gwas_id2 Character string with IEU GWAS ID for exposure 2
#' @param data3_iv Data frame containing instrumental variables for local exposure 3
#' @param data3_gwas Data frame containing GWAS summary data for local exposure 3
#' @param data4_iv Data frame containing instrumental variables for local exposure 4
#' @param data4_gwas Data frame containing GWAS summary data for local exposure 4
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=4). Only SNPs that appear exactly four times are retained.
#'
#' @export
mira_ieu_to_local_2_2 <- function(data1_iv, gwas_id1, data2_iv, gwas_id2,
                                   data3_iv, data3_gwas, data4_iv, data4_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Extract IEU exposure 1's IVs from other databases
  data_h_SNP_steiger_mv1_2 <- extract_outcome_data(
    snps = data1_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv1_2 <- data_h_SNP_steiger_mv1_2[, out_name]
  colnames(data_h_SNP_steiger_mv1_2) <- exp_name
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_4 <- merge(data1_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Extract IEU exposure 2's IVs from other databases
  data_h_SNP_steiger_mv2_1 <- extract_outcome_data(
    snps = data2_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv2_1 <- data_h_SNP_steiger_mv2_1[, out_name]
  colnames(data_h_SNP_steiger_mv2_1) <- exp_name
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_4 <- merge(data2_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 3's IVs from IEU databases
  data_h_SNP_steiger_mv3_1 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_1 <- data_h_SNP_steiger_mv3_1[, out_name]
  colnames(data_h_SNP_steiger_mv3_1) <- exp_name

  data_h_SNP_steiger_mv3_2 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_2 <- data_h_SNP_steiger_mv3_2[, out_name]
  colnames(data_h_SNP_steiger_mv3_2) <- exp_name
  data_h_SNP_steiger_mv3_4 <- merge(data3_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 4's IVs from IEU databases
  data_h_SNP_steiger_mv4_1 <- extract_outcome_data(
    snps = data4_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv4_1 <- data_h_SNP_steiger_mv4_1[, out_name]
  colnames(data_h_SNP_steiger_mv4_1) <- exp_name

  data_h_SNP_steiger_mv4_2 <- extract_outcome_data(
    snps = data4_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv4_2 <- data_h_SNP_steiger_mv4_2[, out_name]
  colnames(data_h_SNP_steiger_mv4_2) <- exp_name
  data_h_SNP_steiger_mv4_3 <- merge(data4_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]
  MVIV1_4 <- data_h_SNP_steiger_mv4_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]
  MVIV2_4 <- data_h_SNP_steiger_mv4_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]
  MVIV3_4 <- data_h_SNP_steiger_mv4_3[, exp_name]

  MVIV4_4 <- data4_iv[, exp_name]
  MVIV4_1 <- data_h_SNP_steiger_mv1_4[, exp_name]
  MVIV4_2 <- data_h_SNP_steiger_mv2_4[, exp_name]
  MVIV4_3 <- data_h_SNP_steiger_mv3_4[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3, MVIV1_4,
    MVIV2_2, MVIV2_1, MVIV2_3, MVIV2_4,
    MVIV3_3, MVIV3_1, MVIV3_2, MVIV3_4,
    MVIV4_4, MVIV4_1, MVIV4_2, MVIV4_3
  )

  # Keep only SNPs that appear exactly four times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 4) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}


#' Merge Instrumental Variables for Multivariable MR (2 IEU + 3 Local Exposures)
#'
#' @description
#' Merges instrumental variables for multivariable Mendelian randomization analysis
#' when combining 2 IEU exposures with 3 local (non-IEU) exposures.
#'
#' @param data1_iv Data frame containing instrumental variables for IEU exposure 1
#' @param gwas_id1 Character string with IEU GWAS ID for exposure 1
#' @param data2_iv Data frame containing instrumental variables for IEU exposure 2
#' @param gwas_id2 Character string with IEU GWAS ID for exposure 2
#' @param data3_iv Data frame containing instrumental variables for local exposure 3
#' @param data3_gwas Data frame containing GWAS summary data for local exposure 3
#' @param data4_iv Data frame containing instrumental variables for local exposure 4
#' @param data4_gwas Data frame containing GWAS summary data for local exposure 4
#' @param data5_iv Data frame containing instrumental variables for local exposure 5
#' @param data5_gwas Data frame containing GWAS summary data for local exposure 5
#'
#' @return A data frame containing merged instrumental variables with SNPs present
#'   in all exposures (n=5). Only SNPs that appear exactly five times are retained.
#'
#' @export
mira_ieu_to_local_2_3 <- function(data1_iv, gwas_id1, data2_iv, gwas_id2, data3_iv, data3_gwas,
                                   data4_iv, data4_gwas, data5_iv, data5_gwas) {
  library(tidyr)

  exp_name <- c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure")
  out_name <- c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome")

  # Extract IEU exposure 1's IVs from other databases
  data_h_SNP_steiger_mv1_2 <- extract_outcome_data(
    snps = data1_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv1_2 <- data_h_SNP_steiger_mv1_2[, out_name]
  colnames(data_h_SNP_steiger_mv1_2) <- exp_name
  data_h_SNP_steiger_mv1_3 <- merge(data1_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_4 <- merge(data1_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv1_5 <- merge(data1_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Extract IEU exposure 2's IVs from other databases
  data_h_SNP_steiger_mv2_1 <- extract_outcome_data(
    snps = data2_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv2_1 <- data_h_SNP_steiger_mv2_1[, out_name]
  colnames(data_h_SNP_steiger_mv2_1) <- exp_name
  data_h_SNP_steiger_mv2_3 <- merge(data2_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_4 <- merge(data2_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv2_5 <- merge(data2_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 3's IVs from IEU databases
  data_h_SNP_steiger_mv3_1 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_1 <- data_h_SNP_steiger_mv3_1[, out_name]
  colnames(data_h_SNP_steiger_mv3_1) <- exp_name

  data_h_SNP_steiger_mv3_2 <- extract_outcome_data(
    snps = data3_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv3_2 <- data_h_SNP_steiger_mv3_2[, out_name]
  colnames(data_h_SNP_steiger_mv3_2) <- exp_name
  data_h_SNP_steiger_mv3_4 <- merge(data3_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv3_5 <- merge(data3_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 4's IVs from IEU databases
  data_h_SNP_steiger_mv4_1 <- extract_outcome_data(
    snps = data4_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv4_1 <- data_h_SNP_steiger_mv4_1[, out_name]
  colnames(data_h_SNP_steiger_mv4_1) <- exp_name

  data_h_SNP_steiger_mv4_2 <- extract_outcome_data(
    snps = data4_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv4_2 <- data_h_SNP_steiger_mv4_2[, out_name]
  colnames(data_h_SNP_steiger_mv4_2) <- exp_name
  data_h_SNP_steiger_mv4_3 <- merge(data4_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv4_5 <- merge(data4_iv[, c("SNP", "outcome")], data5_gwas, by = "SNP", all = FALSE)

  # Extract local exposure 5's IVs from IEU databases
  data_h_SNP_steiger_mv5_1 <- extract_outcome_data(
    snps = data5_iv$SNP,
    outcomes = gwas_id1,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv5_1 <- data_h_SNP_steiger_mv5_1[, out_name]
  colnames(data_h_SNP_steiger_mv5_1) <- exp_name

  data_h_SNP_steiger_mv5_2 <- extract_outcome_data(
    snps = data5_iv$SNP,
    outcomes = gwas_id2,
    proxies = TRUE,
    maf_threshold = 0.01
  )
  data_h_SNP_steiger_mv5_2 <- data_h_SNP_steiger_mv5_2[, out_name]
  colnames(data_h_SNP_steiger_mv5_2) <- exp_name
  data_h_SNP_steiger_mv5_3 <- merge(data5_iv[, c("SNP", "outcome")], data3_gwas, by = "SNP", all = FALSE)
  data_h_SNP_steiger_mv5_4 <- merge(data5_iv[, c("SNP", "outcome")], data4_gwas, by = "SNP", all = FALSE)

  # Combine instrumental variables
  MVIV1_1 <- data1_iv[, exp_name]
  MVIV1_2 <- data_h_SNP_steiger_mv2_1[, exp_name]
  MVIV1_3 <- data_h_SNP_steiger_mv3_1[, exp_name]
  MVIV1_4 <- data_h_SNP_steiger_mv4_1[, exp_name]
  MVIV1_5 <- data_h_SNP_steiger_mv5_1[, exp_name]

  MVIV2_2 <- data2_iv[, exp_name]
  MVIV2_1 <- data_h_SNP_steiger_mv1_2[, exp_name]
  MVIV2_3 <- data_h_SNP_steiger_mv3_2[, exp_name]
  MVIV2_4 <- data_h_SNP_steiger_mv4_2[, exp_name]
  MVIV2_5 <- data_h_SNP_steiger_mv5_2[, exp_name]

  MVIV3_3 <- data3_iv[, exp_name]
  MVIV3_1 <- data_h_SNP_steiger_mv1_3[, exp_name]
  MVIV3_2 <- data_h_SNP_steiger_mv2_3[, exp_name]
  MVIV3_4 <- data_h_SNP_steiger_mv4_3[, exp_name]
  MVIV3_5 <- data_h_SNP_steiger_mv5_3[, exp_name]

  MVIV4_4 <- data4_iv[, exp_name]
  MVIV4_1 <- data_h_SNP_steiger_mv1_4[, exp_name]
  MVIV4_2 <- data_h_SNP_steiger_mv2_4[, exp_name]
  MVIV4_3 <- data_h_SNP_steiger_mv3_4[, exp_name]
  MVIV4_5 <- data_h_SNP_steiger_mv5_4[, exp_name]

  MVIV5_5 <- data5_iv[, exp_name]
  MVIV5_1 <- data_h_SNP_steiger_mv1_5[, exp_name]
  MVIV5_2 <- data_h_SNP_steiger_mv2_5[, exp_name]
  MVIV5_3 <- data_h_SNP_steiger_mv3_5[, exp_name]
  MVIV5_4 <- data_h_SNP_steiger_mv4_5[, exp_name]

  # Merge all instrumental variables
  exposure_dat_temp <- rbind(
    MVIV1_1, MVIV1_2, MVIV1_3, MVIV1_4, MVIV1_5,
    MVIV2_2, MVIV2_1, MVIV2_3, MVIV2_4, MVIV2_5,
    MVIV3_3, MVIV3_1, MVIV3_2, MVIV3_4, MVIV3_5,
    MVIV4_4, MVIV4_1, MVIV4_2, MVIV4_3, MVIV4_5,
    MVIV5_5, MVIV5_1, MVIV5_2, MVIV5_3, MVIV5_4
  )

  # Keep only SNPs that appear exactly five times
  exposure_dat_temp <- exposure_dat_temp %>%
    group_by(SNP) %>%
    filter(n() == 5) %>%
    ungroup()

  message("Multivariable exposure instrumental variable merging completed")
  return(exposure_dat_temp)
}
