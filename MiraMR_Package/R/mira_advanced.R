#' SMR Analysis for QTL and GWAS
#'
#' @title Summary-based Mendelian Randomization for QTL and Phenotype
#' @description Performs SMR (Summary-based Mendelian Randomization) analysis between QTL and GWAS data
#'   using the SMR software. Supports both single-SNP and multi-SNP analysis modes.
#' @param population Reference population for LD reference panel. Default is "EUR".
#' @param gwas_file Path to GWAS summary statistics file
#' @param eqtl_file Path to eQTL/QTL summary statistics file
#' @param single_snp Logical, whether to use top SNP for SMR calculation. Default is TRUE.
#' @param window_kb Window size in kb around top SNP for multi-SNP analysis. Default is 500.
#' @param ld_r2 LD r2 threshold with top SNP for multi-SNP analysis. Default is 0.1.
#' @param output_file Output file name prefix
#' @param num_threads Maximum number of threads for computation. Default is 10.
#' @return NULL (generates SMR output files)
#' @export
mira_smr_qtl <- function(population = "EUR", gwas_file, eqtl_file, single_snp = TRUE,
                        window_kb = 500, ld_r2 = 0.1, output_file, num_threads = 10) {
  if(Sys.info()["sysname"] == "Windows") {
    if(single_snp == TRUE) {
      shell <- paste0(getwd(), "/SMR/smr_Win/", "smr-1.3.1-win.exe --bfile ", getwd(), "/1kg.v3/", population,
                     " --gwas-summary ", gwas_file, " --beqtl-summary ", eqtl_file, " --out ", output_file,
                     " --thread-num ", num_threads, " --diff-freq-prop 0.99")
      system(shell)
    } else {
      shell <- paste0(getwd(), "/SMR/smr_Win/", "smr-1.3.1-win.exe --bfile ", getwd(), "/1kg.v3/", population,
                     " --gwas-summary ", gwas_file, " --beqtl-summary ", eqtl_file, " --out ", output_file,
                     " --smr-multi", " --set-wind ", window_kb, " --ld-multi-snp ", ld_r2,
                     " --thread-num ", num_threads, " --diff-freq-prop 0.99")
      system(shell)
    }
  } else {
    if(single_snp == TRUE) {
      shell <- paste0(getwd(), "/SMR/smr_Mac/", "smr-1.3.1-macos-arm64 --bfile ", getwd(), "/1kg.v3/", population,
                     " --gwas-summary ", gwas_file, " --beqtl-summary ", eqtl_file, " --out ", output_file,
                     " --thread-num ", num_threads, " --diff-freq-prop 0.99")
      system(shell)
    } else {
      shell <- paste0(getwd(), "/SMR/smr_Mac/", "smr-1.3.1-macos-arm64 --bfile ", getwd(), "/1kg.v3/", population,
                     " --gwas-summary ", gwas_file, " --beqtl-summary ", eqtl_file, " --out ", output_file,
                     " --smr-multi", " --set-wind ", window_kb, " --ld-multi-snp ", ld_r2,
                     " --thread-num ", num_threads, " --diff-freq-prop 0.99")
      system(shell)
    }
  }
}


#' SMR Analysis Visualization
#'
#' @title Visualization for SMR Analysis of QTL and Phenotype
#' @description Creates visualizations for SMR analysis results, including locus plots and effect plots.
#' @param population Reference population for LD reference panel. Default is "EUR".
#' @param gwas_file Path to GWAS summary statistics file
#' @param eqtl_file Path to eQTL/QTL summary statistics file
#' @param plot_output Output file name prefix for plots
#' @param probe_id Probe ID for specific probe visualization
#' @param smr_threshold SMR p-value threshold
#' @param trait_name Name of the outcome trait
#' @param num_threads Maximum number of threads for computation. Default is 10.
#' @param locus_plot Logical, whether to generate regional GWAS plot. Default is FALSE.
#' @param effect_plot Logical, whether to generate SMR scatter plot. Default is TRUE.
#' @return NULL (generates plot files)
#' @note Requires TeachingDemos package for plotting functions
#' @export
mira_smr_plot <- function(population = "EUR", gwas_file, eqtl_file, plot_output, probe_id,
                         smr_threshold, trait_name, num_threads = 10, locus_plot = FALSE,
                         effect_plot = TRUE) {
  is.installed <- function(mypkg) {
    is.element(mypkg, installed.packages()[, 1])
  }
  # check if package "TeachingDemos" is installed
  if (!is.installed("TeachingDemos")) {
    install.packages("TeachingDemos")
  }
  library("TeachingDemos")
  if(Sys.info()["sysname"] == "Windows") {
    shell1 <- paste0(getwd(), "/SMR/smr_Win/", "smr-1.3.1-win.exe --bfile ", getwd(), "/1kg.v3/", population,
                    " --gwas-summary ", gwas_file, " --beqtl-summary ", eqtl_file, " --out ", plot_output,
                    " --plot --probe ", probe_id, " --probe-wind 500 ", "--gene-list ", getwd(),
                    "/SMR/glist-hg19", " --thread-num ", num_threads, " --diff-freq-prop 0.99")
    system(shell1)
  }
  else {
    shell1 <- paste0(getwd(), "/SMR/smr_Mac/", "smr-1.3.1-macos-arm64 --bfile ", getwd(), "/1kg.v3/", population,
                    " --gwas-summary ", gwas_file, " --beqtl-summary ", eqtl_file, " --out ", plot_output,
                    " --plot --probe ", probe_id, " --probe-wind 500 ", "--gene-list ", getwd(),
                    "/SMR/glist-hg19", " --thread-num ", num_threads, " --diff-freq-prop 0.99")
    system(shell1)
  }
  shell <- paste0(getwd(), "/plot/", plot_output, ".", probe_id, ".txt")
  SMRData <- ReadSMRData(shell)
  if(locus_plot == TRUE) {
    SMRLocusPlot(data = SMRData, smr_thresh = smr_threshold, heidi_thresh = 0.05,
                plotWindow = 1000, max_anno_probe = 16)
  }
  if(effect_plot == TRUE) {
    SMREffectPlot(data = SMRData, trait_name = trait_name)
  }
}


#' GWAS Meta-Analysis for Two Traits
#'
#' @title Meta-Analysis of GWAS Summary Statistics for Two Traits
#' @description Performs meta-analysis combining GWAS summary statistics from two traits using PLINK.
#'   Splits data by chromosome, runs meta-analysis, and combines results.
#' @param data1 First GWAS dataset in standard MR format with columns: chr.exposure, pos.exposure
#' @param data2 Second GWAS dataset with columns: SNP, BETA, SE
#' @param snp_col Column name for SNP in data2. Default is "SNP".
#' @param beta_col Column name for effect size in data2. Default is "BETA".
#' @param se_col Column name for standard error in data2. Default is "SE".
#' @param a1_col Column name for effect allele in data2. Default is "effect_allele".
#' @param a2_col Column name for other allele in data2. Default is "other_allele".
#' @param temp_dir1 Temporary directory name for dataset 1. Default is "Finnish_Lung_GWAS".
#' @param temp_dir2 Temporary directory name for dataset 2. Default is "Catalog_Lung_GWAS".
#' @param total_sample_size Total combined sample size
#' @param trait_name Name of the combined trait
#' @return NULL (saves meta-analysis results to "Final_GWAS_Meta_Files" directory)
#' @note Requires PLINK software in plink/ directory
#' @export
mira_gwas_meta <- function(data1, data2, snp_col = "SNP", beta_col = "BETA", se_col = "SE",
                          a1_col = "effect_allele", a2_col = "other_allele",
                          temp_dir1 = "Finnish_Lung_GWAS", temp_dir2 = "Catalog_Lung_GWAS",
                          total_sample_size = 1000000, trait_name = "trait_name") {
  if (!requireNamespace("progress", quietly = TRUE))
    install.packages("progress")
  library(tidyr)
  library(data.table)
  library(progress)

  # Merge intersection
  message("Obtaining valid SNPs...")
  d1_d2 <- merge(data1,
                data2[, c(snp_col, beta_col, se_col, a1_col, a2_col)],
                by.x = "SNP",
                by.y = snp_col,
                all = FALSE)

  # Check valid SNP count
  message(paste0("Completed, obtained ", dim(d1_d2)[1], " SNPs for meta-analysis"))
  message("Starting data splitting...")

  # Write backup file
  d11 <- d1_d2[, c("SNP", "beta.exposure", "se.exposure", "chr.exposure", "pos.exposure",
                   "effect_allele.exposure", "other_allele.exposure", "pval.exposure")]
  colnames(d11) <- c("SNP", "OR", "SE", "CHR", "BP", "A1", "A2", "P")
  d11$OR <- exp(d11$OR)
  N <- 22
  pb <- progress_bar$new(total = N)
  for(i in 1:N) {
    d_chr <- subset(d11, CHR == i)
    dir.create(temp_dir1, showWarnings = FALSE)
    write.table(d_chr, paste0(getwd(), "/", temp_dir1, "/Finnish_Lung_GWAS", i, ".txt"),
               quote = FALSE, row.names = FALSE)
    pb$tick()
  }

  message("Dataset 1 split completed, preparing to split dataset 2...")
  d22 <- d1_d2[, c("SNP", beta_col, se_col, "chr.exposure", "pos.exposure", a1_col, a2_col, "pval.exposure")]
  colnames(d22) <- c("SNP", "OR", "SE", "CHR", "BP", "A1", "A2", "P")
  d22$OR <- exp(d22$OR)
  N <- 22
  pb <- progress_bar$new(total = N)
  for(i in 1:N) {
    d_chr <- subset(d22, CHR == i)
    dir.create(temp_dir2, showWarnings = FALSE)
    write.table(d_chr, paste0(getwd(), "/", temp_dir2, "/Catalog_Lung_GWAS", i, ".txt"),
               quote = FALSE, row.names = FALSE)
    pb$tick()
  }
  message("Dataset 2 split completed, preparing for GWAS meta-analysis...")

  # GWAS meta-analysis
  N <- 22
  pb <- progress_bar$new(total = N)
  for (i in 1:N) {
    dir.create("GWAS_meta", showWarnings = FALSE)
    pl <- paste0("plink/plink --meta-analysis ",
                paste0(getwd(), "/", temp_dir1, "/Finnish_Lung_GWAS", i, ".txt "),
                paste0(getwd(), "/", temp_dir2, "/Catalog_Lung_GWAS", i, ".txt"),
                paste0(" --out GWAS_meta/gwas_meta", i))
    system(pl)
    pb$tick()
  }

  message("GWAS meta-analysis completed, detailed files saved to GWAS_meta folder, starting to combine sub-files...")
  file <- dir(paste0(getwd(), "/GWAS_meta")) %>% data.frame()

  # Output GWAS meta
  N <- 22
  pb <- progress_bar$new(total = N)
  ET <- c()
  for (i in 1:N) {
    ET0 <- fread(paste0(getwd(), "/GWAS_meta/gwas_meta", i, ".meta")) %>% data.frame()
    ET <- rbind(ET, ET0)
    pb$tick()
  }

  message("Sub-file combination completed, outputting results...")
  ET$P.fin <- ifelse(ET$I > 0.5, ET$P.R., ET$P)
  ET$OR.fin <- ifelse(ET$I > 0.5, ET$OR.R., ET$OR)
  ET$EFFECT.fin <- log(ET$OR.fin)
  ET$SE.fin <- sqrt(((ET$EFFECT.fin)^2) / qchisq(ET$P.fin, 1, lower.tail = FALSE))
  ET_finn <- ET[, c("CHR", "BP", "SNP", "A1", "A2", "P.fin", "EFFECT.fin", "SE.fin")]
  head(ET_finn)

  ET_finn2 <- merge(ET_finn, data1[, c("SNP", "eaf.exposure")])
  colnames(ET_finn2)[9] <- "EAF.fin"
  ET_finn2$N.fin <- total_sample_size
  ET_finn2$id.fin <- trait_name
  dir.create("Final_GWAS_Meta_Files", showWarnings = FALSE)
  write.table(ET_finn2, "Final_GWAS_Meta_Files/GWAS_META.txt", quote = FALSE, row.names = FALSE)
  message("Results have been output to Final_GWAS_Meta_Files folder")
}


#' PLACO Analysis for Pleiotropy
#'
#' @title Pleiotropic Analysis under Composite Null Hypothesis
#' @description Performs PLACO analysis to identify pleiotropic variants affecting two traits.
#'   Tests for shared genetic effects between exposure and outcome.
#' @param exposure_gwas Exposure GWAS summary data with columns: SNP, beta.exposure, se.exposure, pval.exposure
#' @param outcome_gwas Outcome GWAS summary data with columns: SNP, beta.outcome, se.outcome, pval.outcome
#' @param p_threshold P-value threshold for filtering. Default is 5e-08.
#' @param output_prefix Output file prefix. Default is "PLACO".
#' @return NULL (saves PLACO results to file)
#' @export
mira_placo <- function(exposure_gwas, outcome_gwas, p_threshold = 5e-08, output_prefix = "PLACO") {
  ############################################
  # Function for normal product based tail probability calculation
  # (Using modified Bessel function of the 2nd kind with order 0)
  .pdfx <- function(x) besselK(x = abs(x), nu = 0) / pi
  .p.bessel <- function(z, varz, AbsTol = 1e-13) {
    p1 <- 2 * as.double(integrate(Vectorize(.pdfx), abs(z[1] * z[2] / sqrt(varz[1])), Inf,
                                  abs.tol = AbsTol)$value)
    p2 <- 2 * as.double(integrate(Vectorize(.pdfx), abs(z[1] * z[2] / sqrt(varz[2])), Inf,
                                  abs.tol = AbsTol)$value)
    p0 <- 2 * as.double(integrate(Vectorize(.pdfx), abs(z[1] * z[2]), Inf,
                                  abs.tol = AbsTol)$value)
    pval.compnull <- p1 + p2 - p0
    return(pval.compnull)
  }

  # Function for estimating the variances for PLACO
  var.placo <- function(Z.matrix, P.matrix, p.threshold = 1e-4) {
    k <- ncol(Z.matrix)
    if(k != 2) stop("This method is meant for 2 traits only. Columns correspond to traits.")
    ZP <- cbind(Z.matrix, P.matrix)
    ZP <- na.omit(ZP)

    rows.alt <- which(ZP[, 3] < p.threshold & ZP[, 4] < p.threshold)
    if(length(rows.alt) > 0) {
      ZP <- ZP[-rows.alt, ]
      if(nrow(ZP) == 0) stop(paste("No 'null' variant left at p-value threshold", p.threshold))
      if(nrow(ZP) < 30) warning(paste("Too few 'null' variants at p-value threshold", p.threshold))
    }
    varz <- diag(var(ZP[, c(1, 2)]))
    return(varz)
  }

  # Function for estimating correlation matrix of the Z's
  cor.pearson <- function(Z.matrix, P.matrix, p.threshold = 1e-4) {
    k <- ncol(Z.matrix)
    if(k != 2) stop("This method is meant for 2 traits only.")
    row.exclude <- which(apply(P.matrix, MARGIN = 1, function(x) any(x < p.threshold)) == TRUE)
    if(length(row.exclude) > 0) Z.matrix <- Z.matrix[-row.exclude, ]
    R <- cor(Z.matrix)
    return(R)
  }

  ############################################
  placo <- function(Z, VarZ, AbsTol = .Machine$double.eps^0.8) {
    k <- length(Z)
    if(k != 2) stop("This method is meant for 2 traits only.")
    if(length(VarZ) != k) stop("Provide variance estimates for 2 traits as obtained using var.placo() function.")

    # test of pleiotropy: PLACO
    pvalue.b <- .p.bessel(z = Z, varz = VarZ, AbsTol = AbsTol)
    return(list(T.placo = prod(Z), p.placo = pvalue.b))
  }

  message("Configuration complete, starting PLACO analysis, this may take a while...")
  combin_dat <- merge(exposure_gwas, outcome_gwas, by = "SNP", all = FALSE)
  combin_dat$Zexp <- combin_dat$beta.exposure / combin_dat$se.exposure
  combin_dat$Zout <- combin_dat$beta.outcome / combin_dat$se.outcome
  Z.matrix <- combin_dat[, c("SNP", "Zexp", "Zout")]
  rownames(Z.matrix) <- Z.matrix$SNP
  Z.matrix <- Z.matrix[, -1]
  Z.matrix <- as.matrix(Z.matrix)
  P.matrix <- combin_dat[, c("SNP", "pval.exposure", "pval.outcome")]
  rownames(P.matrix) <- P.matrix$SNP
  P.matrix <- P.matrix[, -1]
  P.matrix <- as.matrix(P.matrix)

  # Step 1: Obtain the variance parameter estimates (only once)
  VarZ <- var.placo(Z.matrix, P.matrix, p.threshold = p.threshold)
  # Step 2: Apply test of pleiotropy for each variant
  out <- sapply(1:nrow(Z.matrix), function(i) placo(Z = Z.matrix[i, ], VarZ = VarZ))
  # Check the output
  out1 <- c()
  for (i in nrow(Z.matrix):1) {
    out0 <- cbind(out[, i]$T.placo, out[, i]$p.placo)
    out1 <- rbind(out0, out1)
  }
  out1 <- data.frame(out1)
  colnames(out1) <- c("T.placo", "p.placo")
  out1$SNP <- rownames(Z.matrix)
  out1$FDR_placo <- p.adjust(out1$p.placo)
  write.table(out1, paste0(getwd(), "/", output_prefix, "PLACO.txt"), row.names = FALSE)
}


#' Local Omics Mendelian Randomization
#'
#' @title Omics-wide Mendelian Randomization Analysis
#' @description Performs comprehensive Mendelian Randomization analysis for omics data
#'   (inflammatory factors, immune cells, metabolites, or gut microbiome).
#' @param omic_type Type of omics data: 1=inflammatory factors, 2=immune cells, 3=metabolites, 4=gut microbiome
#' @param output_dir Output directory for results. Default is "MR_Results".
#' @param omic_dir Directory containing omics data files
#' @param outcome_data Outcome GWAS summary statistics
#' @param local_clump Logical, whether to use local clumping. Default is FALSE.
#' @param clump_p1 P-value threshold for selecting instrumental variables. Default is 1e-05.
#' @param clump_r2 LD r2 threshold for clumping. Default is 0.001.
#' @param clump_kb Distance in kb for clumping. Default is 10000.
#' @param population Population for LD reference. Default is "EUR".
#' @param run_presso Logical, whether to run MR-PRESSO analysis. Default is FALSE.
#' @return NULL (saves MR analysis results to output_dir)
#' @note Requires TwoSampleMR package and optionally MRPRESSO package
#' @export
mira_omic_local <- function(omic_type = 1, output_dir = "MR_Results", omic_dir, outcome_data,
                           local_clump = FALSE, clump_p1 = 1e-05, clump_r2 = 0.001,
                           clump_kb = 10000, population = "EUR", run_presso = FALSE) {

  A_temp <- c()
  B_temp <- c()
  C_temp <- c()
  D_temp <- c()
  E_temp <- c()
  F_temp <- c()
  G_temp <- c()
  G_temp1 <- c()
  H_temp1 <- c()
  H_temp2 <- c()
  H_temp3 <- c()
  H_temp4 <- c()

  if(omic_type == 1) {
    N <- 91
    nm <- "Inflammatory_Factors"
  }
  if(omic_type == 2) {
    N <- 731
    nm <- "Immune_Cells"
  }
  if(omic_type == 3) {
    N <- 1400
    nm <- "Plasma_Metabolites"
  }
  if(omic_type == 4) {
    N <- 211
    nm <- "Gut_Microbiome"
  }

  if(run_presso == FALSE) {
    library(tidyr)
    dir.create(output_dir, showWarnings = FALSE)
    file <- dir(omic_dir)
    file <- data.frame(file)
    file <- data.frame(file)

    for (id in file[, 1]) {
      exppath <- paste0(omic_dir, "/", id)
      exp <- fread(exppath, header = TRUE) %>% data.frame()
      expiv <- subset(exp, pval.exposure < clump_p1)

      if(local_clump == FALSE) {
        expiv <- clump_data(expiv, clump_kb = clump_kb, clump_r2 = clump_r2,
                           clump_p1 = 1, clump_p2 = 1, pop = population)
      } else {
        local_clump_data1 <- function(temp_dat, pop, clump_kb, clump_r2) {
          temp_dat$rsid <- temp_dat$SNP
          temp_dat$id <- temp_dat$id.exposure
          temp_dat$pval <- temp_dat$pval.exposure

          ld_sofm1 <- function(dat, clump_kb, clump_r2, clump_p, bfile, plink_bin) {
            shell <- ifelse(Sys.info()["sysname"] == "Windows", "cmd", "sh")
            fn <- tempfile()
            write.table(data.frame(SNP = dat[["rsid"]], P = dat[["pval"]]),
                       file = fn, row.names = FALSE, col.names = TRUE, quote = FALSE)
            fun2 <- paste0(shQuote(plink_bin, type = shell), " --bfile ",
                          shQuote(bfile, type = shell), " --clump ", shQuote(fn, type = shell),
                          " --clump-p1 ", clump_p, " --clump-r2 ", clump_r2, " --clump-kb ",
                          clump_kb, " --threads 20 --out ", shQuote(fn, type = shell))
            system(fun2)
            res <- read.table(paste(fn, ".clumps", sep = ""), header = FALSE)
            unlink(paste(fn, "*", sep = ""))
            y <- subset(dat, !dat[["rsid"]] %in% res[["V3"]])
            if (nrow(y) > 0) {
              message("Removing ", length(y[["rsid"]]), " of ", nrow(dat),
                     " variants due to LD with other variants or absence from LD reference panel")
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
              }
              else {
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
              }
              else {
                message("Clumping ", ids[i], ", ", nrow(x), " variants, using ",
                       pop, " population reference")
                if (is.null(bfile)) {
                  res[[i]] <- ld_clump_api(x, clump_kb = clump_kb,
                                          clump_r2 = clump_r2, clump_p = clump_p, pop = pop,
                                          access_token = access_token)
                }
                else {
                  res[[i]] <- ld_sofm1(x, clump_kb = clump_kb,
                                      clump_r2 = clump_r2, clump_p = clump_p, bfile = bfile,
                                      plink_bin = plink_bin)
                }
              }
            }
            res <- dplyr::bind_rows(res)
            return(res)
          }

          filepath1 <- paste0(getwd(), "/1kg.v3/", pop)
          filepath2 <- paste0(getwd(), "/1kg.v3/plink2_win64_20231212/plink2")
          filepath3 <- paste0(getwd(), "/1kg.v3/plink2_mac_20231212/plink2")
          if(Sys.info()["sysname"] == "Windows") {
            temp_dat <- ld_sofm2(temp_dat,
                                plink_bin = filepath2,
                                bfile = filepath1,
                                clump_kb = clump_kb, clump_r2 = clump_r2, pop = pop)
          } else {
            temp_dat <- ld_sofm2(temp_dat,
                                plink_bin = filepath3,
                                bfile = filepath1,
                                clump_kb = clump_kb, clump_r2 = clump_r2, pop = pop)
          }

          temp_dat$rsid <- NULL
          temp_dat$pval <- NULL
          return(temp_dat)
        }
        expiv <- local_clump_data1(expiv, clump_kb = clump_kb, clump_r2 = clump_r2, pop = population)
      }

      if(class(expiv$eaf.exposure[1]) != "logical") {
        expiv$R2 <- expiv$beta.exposure * expiv$beta.exposure * 2 * (expiv$eaf.exposure) * (1 - expiv$eaf.exposure)
        expiv$Fvalue <- (expiv$samplesize.exposure - 2) * expiv$R2 / (1 - expiv$R2)
        expiv <- subset(expiv, Fvalue > 10)
      } else {
        expiv$R2 <- NA
        expiv$Fvalue <- (expiv$beta.exposure / expiv$se.exposure) * (expiv$beta.exposure / expiv$se.exposure)
        expiv <- subset(expiv, Fvalue > 10)
      }

      if(dim(expiv)[[1]] != 0) {
        total1 <- merge(outcome_data, expiv, by.x = "SNP", by.y = "SNP", all = FALSE)
        total1 <- subset(total1, pval.outcome > 5e-08)
        total1 <- total1[!duplicated(total1$SNP), ]

        if(dim(total1)[[1]] != 0) {
          EXP1 <- total1[, c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                            "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure",
                            "samplesize.exposure")]
          OUT1 <- total1[, c("SNP", "effect_allele.outcome", "other_allele.outcome", "eaf.outcome",
                            "beta.outcome", "se.outcome", "pval.outcome", "id.outcome", "outcome",
                            "samplesize.outcome")]
          dat1 <- harmonise_data(exposure_dat = EXP1, outcome_dat = OUT1, action = 2)
          test1 <- try(data_h_F10 <- dat1 %>% subset(dat1$mr_keep == TRUE))

          if(class(test1) != "try-error" & dim(data_h_F10)[[1]] != 0) {
            data_h_F10_steiger <- steiger_filtering(data_h_F10)
            data_h_F10_steiger <- subset(data_h_F10_steiger, steiger_dir == TRUE)
            data_h_F10_steiger <- steiger_filtering(data_h_F10)
            data_h_F10_steiger <- subset(data_h_F10_steiger, steiger_dir == TRUE)

            if(dim(data_h_F10_steiger)[[1]] != 0) {
              res <- mr(data_h_F10_steiger)
              res$steiger <- "yes"
              res$F10 <- "yes"
              res$id <- id
              res$IV <- paste0("threshold value <", clump_p1)
              mr_OR <- generate_odds_ratios(res)
              mr_OR$or <- round(mr_OR$or, 3)
              mr_OR$or_lci95 <- round(mr_OR$or_lci95, 3)
              mr_OR$or_uci95 <- round(mr_OR$or_uci95, 3)
              mr_OR$OR_CI <- paste0(mr_OR$or, "(", mr_OR$or_lci95, "-", mr_OR$or_uci95, ")")
              het <- mr_heterogeneity(data_h_F10_steiger)
              ple <- mr_pleiotropy_test(data_h_F10_steiger)
              data_h_TableS1 <- data_h_F10_steiger
              data_h_TableS1$R2 <- data_h_TableS1$beta.exposure * data_h_TableS1$beta.exposure * 2 *
                                  (data_h_TableS1$eaf.exposure) * (1 - data_h_TableS1$eaf.exposure)
              data_h_TableS1$Fvalue <- (data_h_TableS1$samplesize.exposure - 2) * data_h_TableS1$R2 /
                                       (1 - data_h_TableS1$R2)
              data_h_TableS1$steiger <- "yes"
              data_h_TableS1$F10 <- "yes"
              data_h_TableS1$file <- id
              A_temp <- rbind(mr_OR, A_temp)
              B_temp <- rbind(het, B_temp)
              C_temp <- rbind(ple, C_temp)
              D_temp <- rbind(data_h_TableS1, D_temp)

              pt1 <- paste0(getwd(), "/", output_dir, "/MR.csv")
              pt2 <- paste0(getwd(), "/", output_dir, "/het.csv")
              pt3 <- paste0(getwd(), "/", output_dir, "/ple.csv")
              pt4 <- paste0(getwd(), "/", output_dir, "/IV.csv")
              write.csv(A_temp, pt1, row.names = FALSE)
              write.csv(B_temp, pt2, row.names = FALSE)
              write.csv(C_temp, pt3, row.names = FALSE)
              write.csv(D_temp, pt4, row.names = FALSE)
            } else {
              H_temp1 <- rbind(H_temp1, id) %>% data.frame()
              H_temp1$reason <- paste0("Excluded ", nm, " due to failing Steiger filtering")
              pt5 <- paste0(getwd(), "/", output_dir, "/NOsteigerid.csv")
              write.csv(H_temp1, pt5, row.names = FALSE)
            }
          } else {
            H_temp2 <- rbind(H_temp2, id) %>% data.frame()
            H_temp2$reason <- paste0("Excluded ", nm, " due to palindromic SNPs or harmonization issues")
            pt6 <- paste0(getwd(), "/", output_dir, "/NOclumpid.csv")
            write.csv(H_temp2, pt6, row.names = FALSE)
          }
        } else {
          H_temp3 <- rbind(H_temp3, id) %>% data.frame()
          H_temp3$reason <- paste0("Excluded ", nm, " due to no matching instrumental variables")
          pt7 <- paste0(getwd(), "/", output_dir, "/NOmergeid.csv")
          write.csv(H_temp3, pt7, row.names = FALSE)
        }
      } else {
        H_temp4 <- rbind(H_temp4, id) %>% data.frame()
        H_temp4$reason <- paste0("Excluded ", nm, " due to F-value < 10")
        pt8 <- paste0(getwd(), "/", output_dir, "/NOF10id.csv")
        write.csv(H_temp4, pt8, row.names = FALSE)
      }

      print(id)
      row_numbers <- which(file$file == id)
      pv <- round((row_numbers / N) * 100, 4)
      cat("Completed", pv, "%\n")
    }
  }

  else {
    library(MRPRESSO)
    pt4 <- paste0(getwd(), "/", output_dir, "/IV.csv")
    exp <- read.csv(pt4)
    data_class <- unique(exp$id.exposure)
    PPT <- paste0("Split_", nm, "_Exposure_Files")
    dir.create(PPT, showWarnings = FALSE)
    for (i in data_class) {
      A <- subset(exp, id.exposure == i)
      cfilename <- paste0(getwd(), "/Split_", nm, "_Exposure_Files/", i, ".csv")
      write.csv(A, cfilename, row.names = FALSE)
    }
    message("Exposure files split complete, preparing MR-PRESSO...")
    pt4 <- paste0(getwd(), "/Split_", nm, "_Exposure_Files/")

    file <- dir(pt4)
    file <- data.frame(file)
    file <- data.frame(file)
    for(ic in file[, 1]) {
      presso_path <- paste0(getwd(), "/Split_", nm, "_Exposure_Files/", ic)
      data_h_F10_steiger <- read.csv(presso_path, header = TRUE)
      if (dim(data_h_F10_steiger)[[1]] > 3) {
        mrpresso_data <- mr_presso(BetaOutcome = "beta.outcome", BetaExposure = "beta.exposure",
                                   SdOutcome = "se.outcome", SdExposure = "se.exposure",
                                   data = data_h_F10_steiger,
                                   OUTLIERtest = TRUE, DISTORTIONtest = FALSE, SignifThreshold = 1)
        res_presso_main <- mrpresso_data[["Main MR results"]]
        res_presso_main$id <- ic
        E_temp <- rbind(res_presso_main, E_temp)
        pt9 <- paste0(getwd(), "/", output_dir, "/result_presso.csv")
        write.csv(E_temp, pt9, row.names = FALSE)

        res_mrpresso <- data.frame(RSSobs = mrpresso_data[["MR-PRESSO results"]][["Global Test"]][["RSSobs"]],
                                   Pvalue = mrpresso_data[["MR-PRESSO results"]][["Global Test"]][["Pvalue"]])
        res_mrpresso$id <- ic
        F_temp <- rbind(res_mrpresso, F_temp)

        pt10 <- paste0(getwd(), "/", output_dir, "/Global_Test_RSSobs.csv")
        write.csv(F_temp, pt10, row.names = FALSE)
        Outliersnp <- mrpresso_data$`MR-PRESSO results`$`Outlier Test`
        data_h_F10_steiger_snp <- data_h_F10_steiger[, c("SNP", "id.exposure")]
        Outliersnp <- cbind(Outliersnp, data_h_F10_steiger_snp)
        G_temp1 <- rbind(Outliersnp, G_temp1)
        pt11 <- paste0(getwd(), "/", output_dir, "/single_Test_RSSobs.csv")
        write.csv(G_temp1, pt11, row.names = FALSE)
        row_numbers <- which(file$file == ic)
        pv <- round((row_numbers / nrow(file)) * 100, 4)
        cat("Completed", pv, "%\n")
      } else {
        G_temp <- rbind(G_temp, id) %>% data.frame()
        G_temp$reason <- "Fewer than 4 instrumental variables"
        write.csv(G_temp, "NOpressoid.csv", row.names = FALSE)
      }
    }
  }
}


#' Leave-One-Out Analysis for Omics MR
#'
#' @title Omics Leave-One-Out Sensitivity Analysis
#' @description Performs leave-one-out sensitivity analysis for omics MR results
#'   by iteratively removing each SNP and re-running the analysis.
#' @param input_path Absolute file path to IV.csv file (e.g., /path/to/MR_Results)
#' @param output_path Absolute file path to save leave-one-out results. Default is same as input_path.
#' @return NULL (saves LOO results to output_path)
#' @export
mira_omic_loo <- function(input_path, output_path = input_path) {
  F_temp <- c()
  G_temp <- c()
  library(TwoSampleMR)
  pt4 <- paste0(input_path, "/IV.csv")
  exp <- read.csv(pt4)
  data_class <- unique(exp$id.exposure)
  PPT <- paste0(input_path, "/Temp_Split_Files")
  dir.create(PPT, showWarnings = FALSE)
  for (i in data_class) {
    A <- subset(exp, id.exposure == i)
    cfilename <- paste0(input_path, "/Temp_Split_Files/", i, ".csv")
    write.csv(A, cfilename, row.names = FALSE)
  }
  message("Exposure files split complete, preparing leave-one-out analysis...")
  pt4 <- paste0(getwd(), "/Temp_Split_Files/")
  file <- dir(pt4)
  file <- data.frame(file)
  file <- data.frame(file)
  for(ic in file[, 1]) {
    presso_path <- paste0(getwd(), "/Temp_Split_Files/", ic)
    data_h_F10_steiger <- read.csv(presso_path, header = TRUE)
    if (dim(data_h_F10_steiger)[[1]] > 2) {
      Fout <- mr_leaveoneout(data_h_F10_steiger)
      F_temp <- rbind(Fout, F_temp)
      pt9 <- paste0(output_path, "/LOO.csv")
      write.csv(F_temp, pt9, row.names = FALSE)
      row_numbers <- which(file$file == ic)
      pv <- round((row_numbers / nrow(file)) * 100, 4)
      cat("Completed", pv, "%\n")
    } else {
      G_temp <- rbind(G_temp, id) %>% data.frame()
      G_temp$reason <- "Num_iv<3"
      write.csv(G_temp, "NOLOO.csv", row.names = FALSE)
    }
  }
}
