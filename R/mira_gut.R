#' Gut Microbiome MR Analysis with IEU Outcome
#'
#' @description
#' Performs Mendelian randomization analysis for gut microbiome exposures with
#' outcomes from the IEU database. Processes multiple gut microbiome files and
#' conducts comprehensive MR analysis including heterogeneity and pleiotropy tests.
#'
#' @param output_dir Character string specifying output directory name for results
#' @param gut_data_dir Character string specifying path to directory containing
#'   split gut microbiome exposure files (CSV format)
#' @param outcome_gwas_id Character string with IEU GWAS ID for the outcome
#' @param outcome_name Character string with outcome name or abbreviation
#' @param clump_kb Numeric value for clumping window in kilobases (default: 10000)
#' @param clump_r2 Numeric value for clumping R-squared threshold (default: 0.001)
#'
#' @return Creates CSV files in the output directory containing:
#'   - MR results with odds ratios and confidence intervals
#'   - Heterogeneity test results
#'   - Pleiotropy test results
#'   - SNP information including F-statistics
#'
#' @details
#' This function iterates through gut microbiome exposure files, performs LD clumping,
#' extracts outcome data from IEU, harmonizes data, and conducts MR analysis. If
#' clumping fails due to network issues (502 errors), the function continues with
#' unclumped data. Results are saved progressively as each microbiome is analyzed.
#'
#' @export
mira_gut_ieu <- function(output_dir, gut_data_dir, outcome_gwas_id, outcome_name,
                         clump_kb = 10000, clump_r2 = 0.001) {
  library(TwoSampleMR)

  dir.create(output_dir, showWarnings = FALSE)
  filename <- data.frame(dir(gut_data_dir))

  A_temp <- c()
  B_temp <- c()
  C_temp <- c()
  D_temp <- c()

  for (i in filename[, 1]) {
    ipath <- paste0(gut_data_dir, "/", i)
    exp_temp <- read.csv(ipath, header = TRUE)

    test2 <- (try(exp_temp1 <- clump_data(exp_temp, clump_kb = clump_kb, clump_r2 = clump_r2)))

    if (class(test2) != "try-error") {
      OUT <- extract_outcome_data(
        snps = exp_temp1$SNP,
        outcomes = outcome_gwas_id,
        proxies = TRUE,
        maf_threshold = 0.01,
        access_token = NULL
      )

      if (dim(OUT)[[1]] != 0) {
        OUT$id.outcome <- outcome_name
        OUT$outcome <- outcome_name
        OUT <- OUT[!duplicated(OUT$SNP), ]
        exp_temp_out <- merge(exp_temp1, OUT, by = "SNP", all = FALSE)
        exp_temp_out$eaf.exposure <- NA

        # Extract exposure and outcome data
        exp <- exp_temp_out[, c(
          "SNP", "effect_allele.exposure", "other_allele.exposure",
          "beta.exposure", "se.exposure", "pval.exposure",
          "id.exposure", "exposure", "eaf.exposure"
        )]
        out <- exp_temp_out[, c(
          "SNP", "effect_allele.outcome", "other_allele.outcome",
          "eaf.outcome", "beta.outcome", "se.outcome",
          "pval.outcome", "id.outcome", "outcome", "eaf.outcome"
        )]

        # Harmonize data
        dat <- harmonise_data(exposure_dat = exp, outcome_dat = out, action = 2)
        res <- mr(dat)

        data_h <- dat %>% subset(dat$mr_keep == TRUE)
        data_h$Fvalue <- (data_h$beta.exposure / data_h$se.exposure) *
          (data_h$beta.exposure / data_h$se.exposure)
        data_h_TableS1 <- data_h[, c(
          "exposure", "SNP", "effect_allele.exposure",
          "other_allele.exposure", "beta.exposure", "se.exposure",
          "Fvalue", "pval.exposure", "beta.outcome",
          "se.outcome", "pval.outcome"
        )]

        res$cluster <- 1  # 1 indicates successful clumping
        mr_OR <- generate_odds_ratios(res)
        mr_OR$or <- round(mr_OR$or, 3)
        mr_OR$or_lci95 <- round(mr_OR$or_lci95, 3)
        mr_OR$or_uci95 <- round(mr_OR$or_uci95, 3)
        mr_OR$OR_CI <- paste0(mr_OR$or, "(", mr_OR$or_lci95, "-", mr_OR$or_uci95, ")")

        het <- mr_heterogeneity(dat)
        ple <- mr_pleiotropy_test(dat)

        A_temp <- rbind(mr_OR, A_temp)
        B_temp <- rbind(het, B_temp)
        C_temp <- rbind(ple, C_temp)
        D_temp <- rbind(data_h_TableS1, D_temp)

        message(paste0("Currently processing file: ", i))

        Aname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_MR_results.csv")
        Bname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_heterogeneity.csv")
        Cname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_pleiotropy.csv")
        Dname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_SNPs.csv")

        write.csv(A_temp, Aname, row.names = FALSE)
        write.csv(B_temp, Bname, row.names = FALSE)
        write.csv(C_temp, Cname, row.names = FALSE)
        write.csv(D_temp, Dname, row.names = FALSE)
      } else {
        message(paste(i, "and", outcome_name, "- no instrumental variables found"))
      }
    } else {
      message(paste(i, "- clumping failed due to network error (502), using unclumped data"))

      OUT <- extract_outcome_data(
        snps = exp_temp$SNP,
        outcomes = outcome_gwas_id,
        proxies = TRUE,
        maf_threshold = 0.01,
        access_token = NULL
      )

      if (dim(OUT)[[1]] != 0) {
        OUT$id.outcome <- outcome_name
        OUT$outcome <- outcome_name
        OUT <- OUT[!duplicated(OUT$SNP), ]
        exp_temp_out <- merge(exp_temp, OUT, by = "SNP", all = FALSE)
        exp_temp_out$eaf.exposure <- exp_temp_out$eaf.outcome

        exp <- exp_temp_out[, c(
          "SNP", "effect_allele.exposure", "other_allele.exposure",
          "beta.exposure", "se.exposure", "pval.exposure",
          "id.exposure", "exposure", "eaf.exposure"
        )]
        out <- exp_temp_out[, c(
          "SNP", "effect_allele.outcome", "other_allele.outcome",
          "eaf.outcome", "beta.outcome", "se.outcome",
          "pval.outcome", "id.outcome", "outcome", "eaf.outcome"
        )]

        dat <- harmonise_data(exposure_dat = exp, outcome_dat = out, action = 2)
        res <- mr(dat)

        data_h <- dat %>% subset(dat$mr_keep == TRUE)
        data_h$Fvalue <- (data_h$beta.exposure / data_h$se.exposure) *
          (data_h$beta.exposure / data_h$se.exposure)
        data_h_TableS1 <- data_h[, c(
          "exposure", "SNP", "effect_allele.exposure",
          "other_allele.exposure", "beta.exposure", "se.exposure",
          "Fvalue", "pval.exposure", "beta.outcome",
          "se.outcome", "pval.outcome"
        )]

        res$cluster <- 0  # 0 indicates clumping was not successful
        mr_OR <- generate_odds_ratios(res)
        mr_OR$or <- round(mr_OR$or, 3)
        mr_OR$or_lci95 <- round(mr_OR$or_lci95, 3)
        mr_OR$or_uci95 <- round(mr_OR$or_uci95, 3)
        mr_OR$OR_CI <- paste0(mr_OR$or, "(", mr_OR$or_lci95, "-", mr_OR$or_uci95, ")")

        het <- mr_heterogeneity(dat)
        ple <- mr_pleiotropy_test(dat)

        A_temp <- rbind(mr_OR, A_temp)
        B_temp <- rbind(het, B_temp)
        C_temp <- rbind(ple, C_temp)
        D_temp <- rbind(data_h_TableS1, D_temp)

        message(paste0("Currently processing file: ", i))

        Aname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_MR_results.csv")
        Bname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_heterogeneity.csv")
        Cname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_pleiotropy.csv")
        Dname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_SNPs.csv")

        write.csv(A_temp, Aname, row.names = FALSE)
        write.csv(B_temp, Bname, row.names = FALSE)
        write.csv(C_temp, Cname, row.names = FALSE)
        write.csv(D_temp, Dname, row.names = FALSE)
      } else {
        message(paste(i, "and", outcome_name, "- no instrumental variables found"))
      }
    }
  }

  message(paste("Analysis completed! Please check results in the", output_dir, "directory"))
}


#' Gut Microbiome MR Analysis with Local Outcome
#'
#' @description
#' Performs Mendelian randomization analysis for gut microbiome exposures with
#' local (non-IEU) outcome GWAS data. Supports both online and local LD clumping.
#'
#' @param output_dir Character string specifying output directory name for results
#' @param gut_data_dir Character string specifying path to directory containing
#'   split gut microbiome exposure files (CSV format)
#' @param outcome_gwas Data frame containing preprocessed local outcome GWAS summary data
#' @param outcome_name Character string with local outcome name
#' @param use_local_clump Logical indicating whether to use local clumping (default: FALSE)
#' @param clump_kb Numeric value for clumping window in kilobases (default: 10000)
#' @param clump_r2 Numeric value for clumping R-squared threshold (default: 0.001)
#'
#' @return Creates CSV files in the output directory containing:
#'   - MR results with odds ratios and confidence intervals
#'   - Heterogeneity test results
#'   - Pleiotropy test results
#'   - SNP information including F-statistics and clumping status
#'
#' @details
#' This function processes gut microbiome exposure files against local outcome data.
#' When use_local_clump=TRUE, it uses local plink reference data for LD clumping.
#' The local clumping requires 1000 Genomes reference files in the working directory
#' at "./1kg.v3/[population]" and plink2 binary at "./1kg.v3/plink2_[os]/plink2".
#'
#' @export
mira_gut_local <- function(output_dir, gut_data_dir, outcome_gwas, outcome_name,
                           use_local_clump = FALSE, clump_kb = 10000, clump_r2 = 0.001) {
  library(TwoSampleMR)

  dir.create(output_dir, showWarnings = FALSE)
  filename <- data.frame(dir(gut_data_dir))

  A_temp <- c()
  B_temp <- c()
  C_temp <- c()
  D_temp <- c()

  for (i in filename[, 1]) {
    ipath <- paste0(gut_data_dir, "/", i)
    exp_temp <- read.csv(ipath, header = TRUE)

    if (use_local_clump == FALSE) {
      test2 <- (try(exp_temp <- clump_data(exp_temp, clump_kb = clump_kb, clump_r2 = clump_r2)))
    } else {
      local_clump_data1 <- function(temp_dat, pop, clump_kb, clump_r2) {
        temp_dat$rsid <- temp_dat$SNP
        temp_dat$id <- temp_dat$id.exposure
        temp_dat$pval <- temp_dat$pval.exposure

        ld_sofm1 <- function(dat, clump_kb, clump_r2, clump_p, bfile, plink_bin) {
          shell <- ifelse(Sys.info()["sysname"] == "Windows", "cmd", "sh")
          fn <- tempfile()
          write.table(data.frame(SNP = dat[["rsid"]], P = dat[["pval"]]),
            file = fn, row.names = FALSE, col.names = TRUE, quote = FALSE
          )
          fun2 <- paste0(
            shQuote(plink_bin, type = shell), " --bfile ",
            shQuote(bfile, type = shell), " --clump ", shQuote(fn, type = shell),
            " --clump-p1 ", clump_p, " --clump-r2 ", clump_r2,
            " --clump-kb ", clump_kb, " --threads 20 --out ", shQuote(fn, type = shell)
          )
          system(fun2)
          res <- read.table(paste(fn, ".clumps", sep = ""), header = FALSE)
          unlink(paste(fn, "*", sep = ""))
          y <- subset(dat, !dat[["rsid"]] %in% res[["V3"]])
          if (nrow(y) > 0) {
            message(
              "Removing ", length(y[["rsid"]]), " of ", nrow(dat),
              " variants due to LD with other variants or absence from LD reference panel"
            )
          }
          return(subset(dat, dat[["rsid"]] %in% res[["V3"]]))
        }

        ld_sofm2 <- function(dat = NULL, clump_kb = 10000, clump_r2 = 0.001, clump_p = 0.99,
                             pop = "EUR", access_token = NULL, bfile = NULL, plink_bin = NULL) {
          stopifnot("rsid" %in% names(dat))
          stopifnot(is.data.frame(dat))
          if (is.null(bfile)) {
            message("Please look at vignettes for options on running this locally if you need to run many instances of this command.")
          }
          if (!"pval" %in% names(dat)) {
            if ("p" %in% names(dat)) {
              warning("No 'pval' column found in dat object. Using 'p' column.")
              dat[["pval"]] <- dat[["p"]]
            } else {
              warning("No 'pval' column found in dat object. Setting p-values for all SNPs to clump_p parameter.")
              dat[["pval"]] <- clump_p
            }
          }
          if (!"id" %in% names(dat)) {
            dat$id <- random_string(1)
          }
          if (is.null(bfile)) {
            access_token <- check_access_token()
          }
          ids <- unique(dat[["id"]])
          res <- list()
          for (i in 1:length(ids)) {
            x <- subset(dat, dat[["id"]] == ids[i])
            if (nrow(x) == 1) {
              message("Only one SNP for ", ids[i])
              res[[i]] <- x
            } else {
              message(
                "Clumping ", ids[i], ", ", nrow(x), " variants, using ",
                pop, " population reference"
              )
              if (is.null(bfile)) {
                res[[i]] <- ld_clump_api(x,
                  clump_kb = clump_kb,
                  clump_r2 = clump_r2, clump_p = clump_p, pop = pop,
                  access_token = access_token
                )
              } else {
                res[[i]] <- ld_sofm1(x,
                  clump_kb = clump_kb,
                  clump_r2 = clump_r2, clump_p = clump_p, bfile = bfile,
                  plink_bin = plink_bin
                )
              }
            }
          }
          res <- dplyr::bind_rows(res)
          return(res)
        }

        filepath1 <- paste0(getwd(), "/1kg.v3/", pop)
        filepath2 <- paste0(getwd(), "/1kg.v3/plink2_win64_20231212/plink2")
        filepath3 <- paste0(getwd(), "/1kg.v3/plink2_mac_20231212/plink2")

        if (Sys.info()["sysname"] == "Windows") {
          temp_dat <- ld_sofm2(temp_dat,
            plink_bin = filepath2,
            bfile = filepath1,
            clump_kb = clump_kb, clump_r2 = clump_r2, pop = pop
          )
        } else {
          temp_dat <- ld_sofm2(temp_dat,
            plink_bin = filepath3,
            bfile = filepath1,
            clump_kb = clump_kb, clump_r2 = clump_r2, pop = pop
          )
        }

        temp_dat$rsid <- NULL
        temp_dat$pval <- NULL
        return(temp_dat)
      }

      test2 <- (try(exp_temp <- local_clump_data(exp_temp, clump_kb = clump_kb, clump_r2 = clump_r2)))
    }

    if (class(test2) == "try-error") {
      message(paste(i, "- clumping failed due to network error (502)"))
      total <- merge(outcome_gwas, exp_temp, by = "SNP")
      total$eaf.exposure <- NA
      exp3 <- total[, c(
        "SNP", "effect_allele.exposure", "other_allele.exposure",
        "beta.exposure", "se.exposure", "pval.exposure",
        "id.exposure", "exposure", "eaf.exposure"
      )]
      out3 <- total[, c(
        "SNP", "effect_allele.outcome", "other_allele.outcome",
        "eaf.outcome", "beta.outcome", "se.outcome",
        "pval.outcome", "id.outcome", "outcome", "eaf.outcome"
      )]

      dat <- harmonise_data(exposure_dat = exp3, outcome_dat = out3, action = 2)
      data_h <- dat %>% subset(dat$mr_keep == TRUE)
      data_h$Fvalue <- (data_h$beta.exposure / data_h$se.exposure) *
        (data_h$beta.exposure / data_h$se.exposure)
      data_h_TableS1 <- data_h[, c(
        "exposure", "SNP", "effect_allele.exposure",
        "other_allele.exposure", "beta.exposure", "se.exposure",
        "Fvalue", "pval.exposure", "beta.outcome",
        "se.outcome", "pval.outcome"
      )]
      data_h_TableS1$cluster <- 0  # 0 indicates clumping was not successful

      res <- mr(data_h)
      res$cluster <- 0
      mr_OR <- generate_odds_ratios(res)
      mr_OR$or <- round(mr_OR$or, 3)
      mr_OR$or_lci95 <- round(mr_OR$or_lci95, 3)
      mr_OR$or_uci95 <- round(mr_OR$or_uci95, 3)
      mr_OR$OR_CI <- paste0(mr_OR$or, "(", mr_OR$or_lci95, "-", mr_OR$or_uci95, ")")
    } else {
      total <- merge(outcome_gwas, exp_temp, by = "SNP")
      total$eaf.exposure <- NA
      exp3 <- total[, c(
        "SNP", "effect_allele.exposure", "other_allele.exposure",
        "beta.exposure", "se.exposure", "pval.exposure",
        "id.exposure", "exposure", "eaf.exposure"
      )]
      out3 <- total[, c(
        "SNP", "effect_allele.outcome", "other_allele.outcome",
        "eaf.outcome", "beta.outcome", "se.outcome",
        "pval.outcome", "id.outcome", "outcome", "eaf.outcome"
      )]

      dat <- harmonise_data(exposure_dat = exp3, outcome_dat = out3, action = 2)
      data_h <- dat %>% subset(dat$mr_keep == TRUE)
      data_h$Fvalue <- (data_h$beta.exposure / data_h$se.exposure) *
        (data_h$beta.exposure / data_h$se.exposure)
      data_h_TableS1 <- data_h[, c(
        "exposure", "SNP", "effect_allele.exposure",
        "other_allele.exposure", "beta.exposure", "se.exposure",
        "Fvalue", "pval.exposure", "beta.outcome",
        "se.outcome", "pval.outcome"
      )]
      data_h_TableS1$cluster <- 1

      res <- mr(data_h)
      res$cluster <- 1
      mr_OR <- generate_odds_ratios(res)
      mr_OR$or <- round(mr_OR$or, 3)
      mr_OR$or_lci95 <- round(mr_OR$or_lci95, 3)
      mr_OR$or_uci95 <- round(mr_OR$or_uci95, 3)
      mr_OR$OR_CI <- paste0(mr_OR$or, "(", mr_OR$or_lci95, "-", mr_OR$or_uci95, ")")
    }

    if (dim(res)[[1]] != 0) {
      het <- mr_heterogeneity(dat)
      ple <- mr_pleiotropy_test(dat)

      A_temp <- rbind(mr_OR, A_temp)
      B_temp <- rbind(het, B_temp)
      C_temp <- rbind(ple, C_temp)
      D_temp <- rbind(data_h_TableS1, D_temp)

      message(paste0("Currently processing file: ", i))

      Aname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_MR_results.csv")
      Bname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_heterogeneity.csv")
      Cname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_pleiotropy.csv")
      Dname <- paste0(output_dir, "/", "gut_microbiome_", outcome_name, "_SNPs.csv")

      write.csv(A_temp, Aname, row.names = FALSE)
      write.csv(B_temp, Bname, row.names = FALSE)
      write.csv(C_temp, Cname, row.names = FALSE)
      write.csv(D_temp, Dname, row.names = FALSE)
    } else {
      message(paste("Please delete", i, "from the split gut microbiome exposure directory and re-run"))
    }
  }

  message(paste("Analysis completed! Please check results in the", output_dir, "directory"))
}


#' IEU Exposure to Gut Microbiome MR Analysis
#'
#' @description
#' Performs Mendelian randomization analysis with an IEU exposure and gut microbiome
#' as outcomes. Analyzes the causal effect of an exposure on 216 gut microbiome traits.
#'
#' @param output_dir Character string specifying output directory name for results
#' @param gut_outcome_path Character string specifying path to GUT_outcome.csv file
#'   containing gut microbiome GWAS IDs and names
#' @param exposure_gwas_id Character string with IEU GWAS ID for the exposure
#' @param exposure_name Character string with exposure name
#' @param p_threshold Numeric p-value threshold for instrument selection (default: 5e-8)
#' @param clump_r2 Numeric value for clumping R-squared threshold (default: 0.001)
#' @param clump_kb Numeric value for clumping window in kilobases (default: 10000)
#'
#' @return Creates CSV files in the output directory containing:
#'   - MR results
#'   - Heterogeneity test results
#'   - Pleiotropy test results
#'
#' @details
#' This function extracts instruments for the exposure from IEU database, then
#' iterates through 216 gut microbiome outcomes. For each outcome, it extracts
#' SNP associations, filters out SNPs with genome-wide significant associations
#' with the outcome (p < 5e-8), and performs MR analysis.
#'
#' @export
mira_ieu_gut <- function(output_dir, gut_outcome_path, exposure_gwas_id, exposure_name,
                         p_threshold = 5e-8, clump_r2 = 0.001, clump_kb = 10000) {
  library(TwoSampleMR)

  A_temp <- c()
  B_temp <- c()
  C_temp <- c()

  dir.create(output_dir, showWarnings = FALSE)

  # Extract exposure instruments from IEU
  exp <- extract_instruments(
    outcomes = exposure_gwas_id,
    p1 = p_threshold,
    clump = TRUE,
    r2 = clump_r2,
    kb = clump_kb,
    p2 = 5e-08,
    access_token = NULL
  )
  exp$id.exposure <- exposure_name
  exp$exposure <- exposure_name

  for (i in 1:216) {
    # Extract outcome data for gut microbiome
    ipath <- paste0(gut_outcome_path, "/GUT_outcome.csv")
    OUT_temp <- read.csv(ipath, header = TRUE)
    test <- try(OUT1 <- extract_outcome_data(
      snps = exp$SNP,
      outcomes = OUT_temp[i, 1],
      proxies = TRUE,
      maf_threshold = 0.01,
      access_token = NULL
    ))

    # Remove SNPs with genome-wide significant associations with outcome
    if (class(test) != "NULL") {
      OUT1 <- subset(OUT1, pval.outcome > 5e-08)
      OUT1 <- OUT1[!duplicated(OUT1$SNP), ]

      # Harmonize and perform MR
      dat <- harmonise_data(exposure_dat = exp, outcome_dat = OUT1, action = 2)
      res <- mr(dat)
      het <- mr_heterogeneity(dat)
      ple <- mr_pleiotropy_test(dat)

      A_temp <- rbind(res, A_temp)
      B_temp <- rbind(het, B_temp)
      C_temp <- rbind(ple, C_temp)

      message(paste0("Currently processing: ", OUT_temp[i, 3]))

      Aname <- paste0(output_dir, "/", exposure_name, "_gut_microbiome_MR_results.csv")
      Bname <- paste0(output_dir, "/", exposure_name, "_gut_microbiome_heterogeneity.csv")
      Cname <- paste0(output_dir, "/", exposure_name, "_gut_microbiome_pleiotropy.csv")

      write.csv(A_temp, Aname, row.names = FALSE)
      write.csv(B_temp, Bname, row.names = FALSE)
      write.csv(C_temp, Cname, row.names = FALSE)
    } else {
      message(paste(i, "and", exposure_name, "- no suitable IVs matched"))
    }
  }

  message(paste("Analysis completed! Please check results in the", output_dir, "directory"))
}


#' Local Exposure to Gut Microbiome MR Analysis
#'
#' @description
#' Performs Mendelian randomization analysis with a local (non-IEU) exposure and
#' gut microbiome as outcomes. Analyzes the causal effect of an exposure on 216
#' gut microbiome traits.
#'
#' @param output_dir Character string specifying output directory name for results
#' @param gut_outcome_path Character string specifying path to GUT_outcome.csv file
#'   containing gut microbiome GWAS IDs and names
#' @param exposure_iv Data frame containing preprocessed local exposure instrumental variables
#' @param exposure_name Character string with exposure name
#'
#' @return Creates CSV files in the output directory containing:
#'   - MR results
#'   - Heterogeneity test results
#'   - Pleiotropy test results
#'
#' @details
#' This function uses pre-selected instruments for the local exposure and iterates
#' through 216 gut microbiome outcomes. For each outcome, it extracts SNP associations
#' from IEU database, filters out SNPs with genome-wide significant associations
#' with the outcome (p < 5e-8), and performs MR analysis.
#'
#' @export
mira_local_gut <- function(output_dir, gut_outcome_path, exposure_iv, exposure_name) {
  library(TwoSampleMR)

  A_temp <- c()
  B_temp <- c()
  C_temp <- c()

  dir.create(output_dir, showWarnings = FALSE)

  for (i in 1:216) {
    # Extract outcome data for gut microbiome
    ipath <- paste0(gut_outcome_path, "/GUT_outcome.csv")
    OUT_temp <- read.csv(ipath, header = TRUE)
    test <- try(OUT1 <- extract_outcome_data(
      snps = exposure_iv$SNP,
      outcomes = OUT_temp[i, 1],
      proxies = TRUE,
      maf_threshold = 0.01,
      access_token = NULL
    ))

    # Remove SNPs with genome-wide significant associations with outcome
    if (class(test) != "NULL") {
      OUT1 <- subset(OUT1, pval.outcome > 5e-08)
      OUT1 <- OUT1[!duplicated(OUT1$SNP), ]

      # Harmonize and perform MR
      dat <- harmonise_data(exposure_dat = exposure_iv, outcome_dat = OUT1, action = 2)
      res <- mr(dat)
      het <- mr_heterogeneity(dat)
      ple <- mr_pleiotropy_test(dat)

      A_temp <- rbind(res, A_temp)
      B_temp <- rbind(het, B_temp)
      C_temp <- rbind(ple, C_temp)

      message(paste0("Currently processing: ", OUT_temp[i, 3]))

      Aname <- paste0(output_dir, "/", exposure_name, "_gut_microbiome_MR_results.csv")
      Bname <- paste0(output_dir, "/", exposure_name, "_gut_microbiome_heterogeneity.csv")
      Cname <- paste0(output_dir, "/", exposure_name, "_gut_microbiome_pleiotropy.csv")

      write.csv(A_temp, Aname, row.names = FALSE)
      write.csv(B_temp, Bname, row.names = FALSE)
      write.csv(C_temp, Cname, row.names = FALSE)
    } else {
      message(paste(i, "and", exposure_name, "- no suitable IVs matched"))
    }
  }

  message(paste("Analysis completed! Please check results in the", output_dir, "directory"))
}
