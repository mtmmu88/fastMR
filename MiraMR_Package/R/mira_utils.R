#' Read Instrumental Variables for Multivariable MR
#'
#' @title Read MR Instrumental Variables from Analysis Results
#' @description Reads instrumental variable data from single-variable MR analysis results
#'   for use in multivariable Mendelian Randomization analysis.
#' @param results_dir Name of the folder containing IV.csv file from single-variable analysis
#' @return Data frame containing filtered instrumental variables with mr_keep == TRUE
#' @export
mira_read_gwas <- function(results_dir) {
  path0 <- paste0(getwd(), "/", results_dir)
  path00 <- paste0(path0, "/IV.csv")
  Atemp <- read.csv(path00, header = TRUE)
  Atemp <- Atemp[, c("SNP", "effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                     "beta.exposure", "se.exposure", "pval.exposure", "id.exposure", "exposure", "mr_keep")]

  Atemp <- subset(Atemp, mr_keep == "TRUE")
  return(Atemp)
}


#' Read Reference Panel for Immune Cell Data
#'
#' @title Read 731 Immune Cell SNP Reference Panel
#' @description Reads the reference panel data file required for merging with immune cell data.
#'   The reference panel provides SNP position information for matching.
#' @param ref_dir Directory containing the reference file
#' @return Data frame containing reference panel data
#' @note The reference file should be named "ref.txt.gz"
#' @export
mira_read_ref <- function(ref_dir) {
  library(tidyr)
  path <- paste0(ref_dir, "ref.txt.gz")
  data <- data.table::fread(path) %>% data.frame()
  return(data)
}


#' Read FinnGen Database Data
#'
#' @title Read Data from FinnGen Database
#' @description Reads and formats GWAS summary statistics from the FinnGen database
#'   (https://www.finngen.fi/en/access_results) for MR analysis.
#' @param file_path Path to the downloaded FinnGen data file
#' @param trait_name Name of the phenotype
#' @param as_exposure Logical, whether to format as exposure dataset. Default is TRUE.
#' @param sample_size Sample size of the study
#' @return Data frame formatted for MR analysis (exposure or outcome format)
#' @export
mira_read_finn <- function(file_path, trait_name, as_exposure = TRUE, sample_size) {

  A <- fread(file_path) %>% data.frame()
  if(as_exposure == TRUE) {
    colnames(A)[c(4, 3, 5, 7, 9, 10, 11)] <- c("effect_allele.exposure", "other_allele.exposure", "SNP",
                                                "pval.exposure", "beta.exposure", "se.exposure",
                                                "eaf.exposure")
    A$id.exposure <- trait_name
    A$exposure <- trait_name
    A$samplesize.exposure <- sample_size
    return(A)
  } else {
    colnames(A)[c(4, 3, 5, 7, 9, 10, 11)] <- c("effect_allele.outcome", "other_allele.outcome", "SNP",
                                                "pval.outcome", "beta.outcome", "se.outcome",
                                                "eaf.outcome")
    A$id.outcome <- trait_name
    A$outcome <- trait_name
    A$samplesize.outcome <- sample_size
    return(A)
  }
}


#' Read GIANT Consortium Data
#'
#' @title Read Data from GIANT Database
#' @description Reads and formats GWAS summary statistics from the GIANT consortium
#'   (https://portals.broadinstitute.org/collaboration/giant/index.php) for MR analysis.
#' @param file_path Path to the downloaded GIANT data file
#' @param trait_name Name of the phenotype
#' @param as_exposure Logical, whether to format as exposure dataset. Default is TRUE.
#' @return Data frame formatted for MR analysis (exposure or outcome format)
#' @export
mira_read_giant <- function(file_path, trait_name, as_exposure = TRUE) {

  A <- fread(file_path) %>% data.frame()
  if(as_exposure == TRUE) {
    colnames(A)[c(3, 5, 4, 6, 7, 8, 9, 10)] <- c("SNP",
                                                  "effect_allele.exposure",
                                                  "other_allele.exposure",
                                                  "eaf.exposure",
                                                  "beta.exposure",
                                                  "se.exposure",
                                                  "pval.exposure",
                                                  "samplesize.exposure")
    A$id.exposure <- trait_name
    A$exposure <- trait_name
    return(A)
  } else {
    colnames(A)[c(3, 5, 4, 6, 7, 8, 9, 10)] <- c("SNP",
                                                  "effect_allele.outcome",
                                                  "other_allele.outcome",
                                                  "eaf.outcome",
                                                  "beta.outcome",
                                                  "se.outcome",
                                                  "pval.outcome",
                                                  "samplesize.outcome")
    A$id.outcome <- trait_name
    A$outcome <- trait_name
    return(A)
  }
}


#' Read Tobacco GWAS Data
#'
#' @title Read Data from Tobacco Database
#' @description Reads and formats GWAS summary statistics from the tobacco database
#'   (https://conservancy.umn.edu/handle/11299/201564) for MR analysis.
#' @param file_path Path to the downloaded tobacco data file
#' @param trait_name Name of the phenotype
#' @param as_exposure Logical, whether to format as exposure dataset. Default is TRUE.
#' @return Data frame formatted for MR analysis (exposure or outcome format)
#' @export
mira_read_yancao <- function(file_path, trait_name, as_exposure = TRUE) {

  A <- fread(file_path) %>% data.frame()
  if(as_exposure == TRUE) {
    colnames(A)[c(3, 5, 4, 6, 8, 9, 10, 12)] <- c("SNP",
                                                   "effect_allele.exposure",
                                                   "other_allele.exposure",
                                                   "eaf.exposure",
                                                   "pval.exposure",
                                                   "beta.exposure",
                                                   "se.exposure", "samplesize.exposure")
    A$id.exposure <- trait_name
    A$exposure <- trait_name
    return(A)
  } else {
    colnames(A)[c(3, 5, 4, 6, 8, 9, 10, 12)] <- c("SNP",
                                                   "effect_allele.outcome",
                                                   "other_allele.outcome",
                                                   "eaf.outcome",
                                                   "pval.outcome",
                                                   "beta.outcome",
                                                   "se.outcome", "samplesize.outcome")
    A$id.outcome <- trait_name
    A$outcome <- trait_name
    return(A)
  }
}


#' Find Nearest Gene for SNPs
#'
#' @title Find Nearest Gene Annotations for SNPs
#' @description Finds the nearest gene(s) for each SNP based on genomic position
#'   with specified flanking distance. Uses hg18, hg19, or hg38 reference builds.
#' @param data Data frame containing SNP information with chromosome, position columns
#' @param flanking_kb Flanking distance in kb from SNP to gene. Default is 0.
#' @param snp_col Column name for SNP rsID. Default is 'rsid'.
#' @param chr_col Column name for chromosome. Default is 'chromosome'.
#' @param bp_col Column name for base pair position. Default is 'position'.
#' @param build Genome build version: "hg18", "hg19", or "hg38". Default is "hg19".
#' @param output_dir Output directory name. Default is "Gene_Mapping_Files".
#' @return NULL (saves results to output_dir/SNP_gene.csv)
#' @export
mira_find_gene <- function(data, flanking_kb = 0, snp_col = 'rsid', chr_col = 'chromosome',
                          bp_col = 'position', build = "hg19", output_dir = "Gene_Mapping_Files") {
  library(dplyr)
  data1 <- data[, c(snp_col, chr_col, bp_col)]

  find_nearest_gene1 <- function(data, flanking = 100, build = 'hg19', collapse = TRUE,
                                 snp = 'rsid', chr = 'chromosome', bp = 'position') {

    data <- data

    if(build == 'hg18') {
      genelist <- hg18genelist
    }

    if(build == 'hg19') {
      genelist <- hg19genelist
    }

    if(build == 'hg38') {
      genelist <- hg38genelist
    }

    if(flanking != 100) {
      flanking <- as.numeric(flanking)
    }

    if(snp != 'rsid') {
      data <- data %>% rename(rsid = snp)
    }

    if(chr != 'chromosome') {
      data <- data %>% rename(chromosome = chr)
    }

    if(bp != 'position') {
      data <- data %>% rename(position = bp)
    }

    data <- sqldf::sqldf(sprintf("select A.*,B.* from
              data A left join genelist B
              ON (A.chromosome == B.CHR and
              A.position >= B.START - %1$s and
              A.position <= B.STOP + %1$s)", flanking * 1000)
    )
    if (collapse == TRUE) {
      data %>%
        dplyr::group_by(rsid, chromosome, position) %>%
        dplyr::summarise(GENES = paste(GENE, collapse = ',')) %>%
        data.frame
    } else {
      data <- data %>%
        dplyr::rename(geneSTART = START, geneSTOP = STOP) %>%
        dplyr::select(rsid, chromosome, position, geneSTART, geneSTOP, GENE)

      data$distance <- apply(data, 1, FUN = function(x) {
        ifelse(
          !is.na(x['GENE']) & x['position'] < x['geneSTART'], -(as.numeric(x['geneSTART']) - as.numeric(x['position'])),
          ifelse(!is.na(x['GENE']) & x['position'] > x['geneSTOP'], as.numeric(x['position']) - as.numeric(x['geneSTOP']),
                ifelse(!is.na(x['GENE']) & (x['position'] > x['geneSTART']) & (x['position'] < x['geneSTOP']), 'intergenic', NA))
        )
      })
      data
    }
  }

  result <- find_nearest_gene1(data1, flanking = flanking_kb, build = build,
                               collapse = TRUE, snp = snp_col, chr = chr_col,
                               bp = bp_col)
  D <- merge(data, result, by.x = "SNP", by.y = "rsid", all = FALSE)
  dir.create(output_dir, showWarnings = FALSE)
  path <- paste0(getwd(), "/", output_dir, "/SNP_gene.csv")
  write.csv(D, path, row.names = FALSE)
}


#' Transform Beta and SE to EAF
#'
#' @title Transform Effect Size and Standard Error to Effect Allele Frequency
#' @description Calculates effect allele frequency (EAF) from beta, standard error,
#'   and sample size using inverse transformation formulas.
#' @param data Data frame containing the variables to transform
#' @param n_col Column name for sample size
#' @param beta_col Column name for effect size (beta)
#' @param se_col Column name for standard error
#' @return Vector of calculated effect allele frequencies
#' @export
mira_trans_eaf <- function(data, n_col, beta_col, se_col) {
  data1 <- data[, c(beta_col, se_col, n_col)]
  data1$d2 <- ((1 / data1[, 2]) * (1 / data1[, 2])) / 2
  data1$z <- data1[, 1] / data1[, 2]
  data1$z2n <- data1$z * data1$z + data1[, 3]
  data1$zf1 <- data1$d2 / data1$z2n
  data1$eaf <- (1 + sqrt(1 - 4 * data1$zf1)) / 2
  return(data1$eaf)
}


#' Transform Z-score to Beta and SE
#'
#' @title Transform Z-score and EAF to Effect Size and Standard Error
#' @description Calculates beta and standard error from Z-score, effect allele frequency,
#'   and sample size. Can format output as exposure or outcome variables.
#' @param data Data frame containing the variables to transform
#' @param n_col Column name for sample size
#' @param eaf_col Column name for effect allele frequency
#' @param z_col Column name for Z-score
#' @param as_exposure Logical, whether to format as exposure data (TRUE) or outcome data (FALSE). Default is TRUE.
#' @return Data frame with calculated beta and se columns plus original data
#' @export
mira_trans_z <- function(data, n_col, eaf_col, z_col, as_exposure = TRUE) {
  if(as_exposure == TRUE) {
    data1 <- data[, c(n_col, eaf_col, z_col)]
    data1$beta.exposure <- 2 * (data1[, eaf_col] * (1 - data1[, eaf_col]))
    data1$beta.exposure <- data1$beta.exposure * (data1[, z_col] * data1[, z_col] + data1[, n_col])
    data1$beta.exposure <- sqrt(data1$beta.exposure)
    data1$beta.exposure <- data1[, z_col] / data1$beta.exposure
    data1$se.exposure <- data1$beta.exposure / data1[, z_col]
    data2 <- cbind(data1[, c("beta.exposure", "se.exposure")], data)
    return(data2)
  } else {
    data1 <- data[, c(n_col, eaf_col, z_col)]
    data1$beta.outcome <- 2 * (data1[, eaf_col] * (1 - data1[, eaf_col]))
    data1$beta.outcome <- data1$beta.outcome * (data1[, z_col] * data1[, z_col] + data1[, n_col])
    data1$beta.outcome <- sqrt(data1$beta.outcome)
    data1$beta.outcome <- data1[, z_col] / data1$beta.outcome
    data1$se.outcome <- data1$beta.outcome / data1[, z_col]
    data2 <- cbind(data1[, c("beta.outcome", "se.outcome")], data)
    return(data2)
  }
}


#' Format GWAS Data for SMR Analysis
#'
#' @title Format GWAS Summary Statistics for SMR Analysis
#' @description Reads GWAS summary statistics from various formats (RDS, CSV, RData) and converts
#'   them to the standard format required for SMR (Summary-based Mendelian Randomization) analysis.
#'   The function handles data cleaning, EAF calculation, duplicate removal, and column renaming.
#' @param input_file Path to the input file (RDS, CSV, RData, or txt format)
#' @param output_file Output file name. Default is "SMR_formatted.txt".
#' @param data_format Format of input data columns: "outcome" (contains .outcome suffix),
#'   "exposure" (contains .exposure suffix), or "auto" (auto-detect). Default is "auto".
#' @param calculate_eaf Logical, whether to calculate effect allele frequency if it's > 0.5.
#'   If TRUE, converts EAF to minor allele frequency. Default is TRUE.
#' @param eaf_col Column name for effect allele frequency in input data. Common names:
#'   "eaf", "effect_allele_frequency", "freq", "maf". Default is "eaf".
#' @param remove_duplicates Logical, whether to remove duplicate SNPs (keeps first occurrence).
#'   Default is TRUE.
#' @param remove_na Logical, whether to remove rows with missing values. Default is TRUE.
#' @param output_dir Output directory. If NULL, saves to current working directory. Default is NULL.
#' @return Invisibly returns the formatted data frame. Also saves to file.
#' @details
#' The output format follows SMR requirements with columns:
#' \itemize{
#'   \item SNP - SNP rsID
#'   \item A1 - Effect allele
#'   \item A2 - Other allele
#'   \item freq - Effect allele frequency
#'   \item b - Effect size (beta)
#'   \item se - Standard error
#'   \item p - P-value
#'   \item n - Sample size
#' }
#'
#' The function performs the following quality control steps:
#' \itemize{
#'   \item Removes rows with missing values (if remove_na = TRUE)
#'   \item Removes SNPs with empty rsID
#'   \item Removes SNPs containing commas in rsID
#'   \item Removes duplicate SNPs (if remove_duplicates = TRUE)
#'   \item Calculates proper EAF (if calculate_eaf = TRUE)
#' }
#' @note Make sure your input data contains the following columns (with either .exposure or .outcome suffix):
#'   SNP, effect_allele, other_allele, eaf (or effect_allele_frequency), beta, se, p (or pval), n (or samplesize)
#' @examples
#' \dontrun{
#' # Read RDS file and format for SMR
#' mira_format_smr(
#'   input_file = "MG_metafull.rds",
#'   output_file = "MG_meta_full.txt",
#'   data_format = "outcome"
#' )
#'
#' # Auto-detect format and calculate EAF
#' mira_format_smr(
#'   input_file = "exposure_data.csv",
#'   output_file = "SMR_exposure.txt",
#'   data_format = "auto",
#'   calculate_eaf = TRUE
#' )
#' }
#' @export
mira_format_smr <- function(input_file,
                            output_file = "SMR_formatted.txt",
                            data_format = c("auto", "outcome", "exposure"),
                            calculate_eaf = TRUE,
                            eaf_col = "eaf",
                            remove_duplicates = TRUE,
                            remove_na = TRUE,
                            output_dir = NULL) {

  library(dplyr)
  library(data.table)

  data_format <- match.arg(data_format)

  # Check if input file exists
  if(!file.exists(input_file)) {
    stop("Input file does not exist: ", input_file)
  }

  # Read input file based on extension
  file_ext <- tolower(tools::file_ext(input_file))

  message("Reading input file: ", input_file)

  if(file_ext == "rds") {
    g <- readRDS(input_file)
  } else if(file_ext %in% c("rda", "rdata")) {
    env <- new.env()
    load(input_file, envir = env)
    g <- get(ls(env)[1], envir = env)
  } else if(file_ext %in% c("csv", "txt")) {
    g <- fread(input_file) %>% data.frame()
  } else {
    stop("Unsupported file format. Please use RDS, RData, CSV, or TXT file.")
  }

  message("Input data dimensions: ", nrow(g), " rows x ", ncol(g), " columns")

  # Remove NA if requested
  if(remove_na) {
    before_na <- nrow(g)
    g <- na.omit(g)
    message("Removed ", before_na - nrow(g), " rows with missing values")
  }

  # Auto-detect data format if needed
  if(data_format == "auto") {
    if("effect_allele.outcome" %in% colnames(g)) {
      data_format <- "outcome"
      message("Auto-detected data format: outcome")
    } else if("effect_allele.exposure" %in% colnames(g)) {
      data_format <- "exposure"
      message("Auto-detected data format: exposure")
    } else {
      stop("Cannot auto-detect data format. Please specify data_format = 'outcome' or 'exposure'")
    }
  }

  # Convert to data frame
  g <- data.frame(g)

  # Handle sample size column (n or N)
  if("N" %in% colnames(g) && !"n" %in% colnames(g)) {
    g$n <- g$N
  } else if("samplesize.outcome" %in% colnames(g)) {
    g$n <- g$samplesize.outcome
  } else if("samplesize.exposure" %in% colnames(g)) {
    g$n <- g$samplesize.exposure
  }

  # Handle EAF column - check various common names
  eaf_candidates <- c(eaf_col, "effect_allele_frequency", "freq", "maf", "EAF")
  eaf_found <- FALSE

  for(candidate in eaf_candidates) {
    if(candidate %in% colnames(g)) {
      if(data_format == "outcome") {
        g$eaf.outcome <- g[[candidate]]
      } else {
        g$eaf.exposure <- g[[candidate]]
      }
      eaf_found <- TRUE
      message("Found EAF column: ", candidate)
      break
    }
  }

  if(!eaf_found) {
    warning("EAF column not found. Will use NA for frequency.")
  }

  # Calculate EAF (convert to minor allele frequency if > 0.5)
  if(calculate_eaf && eaf_found) {
    if(data_format == "outcome") {
      if(!all(is.na(g$eaf.outcome))) {
        g$eaf.outcome <- ifelse(g$eaf.outcome > 0.5, 1 - g$eaf.outcome, g$eaf.outcome)
        message("Calculated minor allele frequency from EAF")
      }
    } else {
      if(!all(is.na(g$eaf.exposure))) {
        g$eaf.exposure <- ifelse(g$eaf.exposure > 0.5, 1 - g$eaf.exposure, g$eaf.exposure)
        message("Calculated minor allele frequency from EAF")
      }
    }
  }

  # Select and rename columns based on data format
  if(data_format == "outcome") {
    # Check for required columns
    required_cols <- c("SNP", "effect_allele.outcome", "other_allele.outcome",
                      "beta.outcome", "se.outcome")

    missing_cols <- setdiff(required_cols, colnames(g))
    if(length(missing_cols) > 0) {
      stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
    }

    # Handle p-value column
    if("pval.outcome" %in% colnames(g)) {
      pval_col <- "pval.outcome"
    } else if("p.outcome" %in% colnames(g)) {
      pval_col <- "p.outcome"
    } else {
      stop("P-value column not found (pval.outcome or p.outcome)")
    }

    f <- dplyr::select(g, SNP, effect_allele.outcome, other_allele.outcome,
                      eaf.outcome, beta.outcome, se.outcome, !!pval_col, n)

  } else {  # exposure format
    # Check for required columns
    required_cols <- c("SNP", "effect_allele.exposure", "other_allele.exposure",
                      "beta.exposure", "se.exposure")

    missing_cols <- setdiff(required_cols, colnames(g))
    if(length(missing_cols) > 0) {
      stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
    }

    # Handle p-value column
    if("pval.exposure" %in% colnames(g)) {
      pval_col <- "pval.exposure"
    } else if("p.exposure" %in% colnames(g)) {
      pval_col <- "p.exposure"
    } else {
      stop("P-value column not found (pval.exposure or p.exposure)")
    }

    f <- dplyr::select(g, SNP, effect_allele.exposure, other_allele.exposure,
                      eaf.exposure, beta.exposure, se.exposure, !!pval_col, n)
  }

  # Rename columns to SMR format
  colnames(f) <- c("SNP", "A1", "A2", "freq", "b", "se", "p", "n")

  # Quality control
  before_qc <- nrow(f)

  # Remove empty SNPs
  f <- subset(f, SNP != "")
  message("Removed ", before_qc - nrow(f), " SNPs with empty rsID")

  # Remove SNPs with commas
  before_comma <- nrow(f)
  f <- f[!grepl(',', f$SNP), ]
  message("Removed ", before_comma - nrow(f), " SNPs containing commas")

  # Remove duplicates
  if(remove_duplicates) {
    before_dup <- nrow(f)
    f <- f %>% distinct(SNP, .keep_all = TRUE)
    message("Removed ", before_dup - nrow(f), " duplicate SNPs")
  }

  message("Final data dimensions: ", nrow(f), " rows x ", ncol(f), " columns")

  # Prepare output path
  if(!is.null(output_dir)) {
    dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
    output_path <- file.path(output_dir, output_file)
  } else {
    output_path <- output_file
  }

  # Save to file
  write.table(f, output_path, sep = "\t", row.names = FALSE, quote = FALSE)
  message("SMR-formatted data saved to: ", output_path)

  # Return data invisibly
  invisible(f)
}
