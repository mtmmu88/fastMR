#' Preprocess Inflammatory Factor Data
#'
#' @title Inflammatory Factor Data Preprocessing
#' @description Preprocesses inflammatory factor data for Mendelian Randomization analysis.
#'   Converts data to exposure or outcome format and filters based on p-value thresholds.
#' @param input_dir Directory containing inflammatory factor data files
#' @param output_dir Directory to save preprocessed data
#' @param as_exposure Logical, whether to process as exposure data (TRUE) or outcome data (FALSE). Default is TRUE.
#' @param p_exposure P-value threshold for selecting potential instrumental variables when processing as exposure. Default is 1e-05.
#' @param p_outcome P-value threshold for filtering variants when processing as outcome. Default is 5e-08.
#' @return NULL (saves processed files to output_dir)
#' @export
mira_prep_inflammatory <- function(input_dir, output_dir, as_exposure = TRUE,
                                   p_exposure = 1e-05, p_outcome = 5e-08) {
  library(tidyr)
  file <- dir(input_dir) %>% data.frame()
  for(i in 1:nrow(file)) {
    dir.create(output_dir, showWarnings = FALSE)
    path <- paste0(input_dir, "/", file[i, 1])
    data <- data.table::fread(path) %>% data.frame()
    colnames(data)[c(3, 4, 11, 5, 6, 7, 8, 10)] <- c("effect_allele.exposure", "other_allele.exposure",
                                                       "samplesize.exposure", "beta.exposure", "se.exposure",
                                                       "eaf.exposure", "pval.exposure", "SNP")
    data <- data[, c("effect_allele.exposure", "other_allele.exposure", "samplesize.exposure",
                     "beta.exposure", "se.exposure", "eaf.exposure", "pval.exposure", "SNP")]
    data$id.exposure <- file[i, ]
    data$exposure <- data$id.exposure
    if(as_exposure == TRUE) {
      data$pval.exposure <- as.numeric(data$pval.exposure)
      data <- subset(data, pval.exposure < p_exposure)
      output_path <- paste0(output_dir, "/", file[i, 1], ".csv")
      write.csv(data, output_path, row.names = FALSE, quote = FALSE)
      pct <- round(i/nrow(file), 4) * 100
      cat("Completed exposure data transformation", pct, "%\n")
    } else {
      data2 <- data[, c("effect_allele.exposure", "other_allele.exposure", "samplesize.exposure",
                        "beta.exposure", "se.exposure", "eaf.exposure", "pval.exposure", "SNP",
                        "id.exposure", "exposure")]
      colnames(data2) <- c("effect_allele.outcome", "other_allele.outcome", "samplesize.outcome",
                          "beta.outcome", "se.outcome", "eaf.outcome", "pval.outcome", "SNP",
                          "id.outcome", "outcome")
      output_path <- paste0(output_dir, "/", file[i, 1])
      data2 <- subset(data2, pval.outcome > p_outcome)
      write.table(data2, file = gzfile(output_path), row.names = FALSE)
      pct <- round(i/nrow(file), 4) * 100
      cat("Completed outcome data transformation", pct, "%\n")
    }
  }
}


#' Preprocess Immune Cell Data
#'
#' @title Immune Cell Data Preprocessing
#' @description Preprocesses immune cell data for Mendelian Randomization analysis.
#'   Merges with reference panel and converts data to exposure or outcome format.
#' @param input_dir Directory containing immune cell data files
#' @param output_dir Directory to save preprocessed data
#' @param as_exposure Logical, whether to process as exposure data (TRUE) or outcome data (FALSE). Default is TRUE.
#' @param p_exposure P-value threshold for selecting potential instrumental variables when processing as exposure. Default is 1e-05.
#' @param p_outcome P-value threshold for filtering variants when processing as outcome. Default is 5e-08.
#' @return NULL (saves processed files to output_dir)
#' @note Requires ref_data object in the global environment for merging
#' @export
mira_prep_immune <- function(input_dir, output_dir, as_exposure = TRUE,
                             p_exposure = 1e-05, p_outcome = 5e-08) {
  library(tidyr)
  file <- dir(input_dir) %>% data.frame()

  for(i in 1:nrow(file)) {
    dir.create(output_dir, showWarnings = FALSE)
    path <- paste0(input_dir, "/", file[i, 1])
    data <- data.table::fread(path) %>% data.frame()
    data$mer <- paste0(data$chromosome, ":", data$base_pair_location)
    colnames(data)[c(3, 4, 5, 7, 8, 9, 10)] <- c("effect_allele.exposure", "other_allele.exposure",
                                                  "samplesize.exposure", "eaf.exposure", "beta.exposure",
                                                  "se.exposure", "pval.exposure")
    data$id.exposure <- file[i, ]
    data$exposure <- data$id.exposure
    data <- data[, c("effect_allele.exposure", "other_allele.exposure", "samplesize.exposure",
                     "beta.exposure", "se.exposure", "eaf.exposure", "pval.exposure", "mer",
                     "id.exposure", "exposure")]
    if(as_exposure == TRUE) {
      data$pval.exposure <- as.numeric(data$pval.exposure)
      data <- subset(data, pval.exposure < p_exposure)
      data1 <- merge(ref_data, data, by = "mer", all = FALSE)
      output_path <- paste0(output_dir, "/", file[i, 1], ".csv")
      write.csv(data1, output_path, row.names = FALSE, quote = FALSE)
      pct <- round(i/nrow(file), 4) * 100
      cat("Completed exposure data transformation", pct, "%\n")
    } else {
      data2 <- data[, c("effect_allele.exposure", "other_allele.exposure", "samplesize.exposure",
                        "beta.exposure", "se.exposure", "eaf.exposure", "pval.exposure", "mer",
                        "id.exposure", "exposure")]
      colnames(data2) <- c("effect_allele.outcome", "other_allele.outcome", "samplesize.outcome",
                          "beta.outcome", "se.outcome", "eaf.outcome", "pval.outcome", "mer",
                          "id.outcome", "outcome")
      data2 <- merge(ref_data, data2, by = "mer", all = FALSE)
      output_path <- paste0(output_dir, "/", file[i, 1])
      data2 <- subset(data2, pval.outcome > p_outcome)
      write.table(data2, file = gzfile(output_path), row.names = FALSE)
      pct <- round(i/nrow(file), 4) * 100
      cat("Completed outcome data transformation", pct, "%\n")
    }
  }
}


#' Preprocess Metabolite Data
#'
#' @title Metabolite Data Preprocessing
#' @description Preprocesses metabolite data for Mendelian Randomization analysis.
#'   Converts data to exposure or outcome format and filters based on p-value thresholds.
#' @param input_dir Directory containing metabolite data files
#' @param output_dir Directory to save preprocessed data
#' @param as_exposure Logical, whether to process as exposure data (TRUE) or outcome data (FALSE). Default is TRUE.
#' @param p_exposure P-value threshold for selecting potential instrumental variables when processing as exposure. Default is 1e-05.
#' @param p_outcome P-value threshold for filtering variants when processing as outcome. Default is 5e-08.
#' @return NULL (saves processed files to output_dir)
#' @export
mira_prep_metabolite <- function(input_dir, output_dir, as_exposure = TRUE,
                                 p_exposure = 1e-05, p_outcome = 5e-08) {
  library(tidyr)
  file <- dir(input_dir) %>% data.frame()
  for(i in 1:nrow(file)) {
    dir.create(output_dir, showWarnings = FALSE)
    path <- paste0(input_dir, "/", file[i, 1])
    data <- data.table::fread(path) %>% data.frame()

    head(data)

    colnames(data)[c(3:9)] <- c("effect_allele.exposure", "other_allele.exposure", "eaf.exposure",
                                "beta.exposure", "se.exposure", "pval.exposure", "SNP")
    data <- data[, c("effect_allele.exposure", "other_allele.exposure",
                     "beta.exposure", "se.exposure", "eaf.exposure", "pval.exposure", "SNP")]

    data$samplesize.exposure <- 8264
    data$id.exposure <- file[i, ]
    data$exposure <- data$id.exposure

    if(as_exposure == TRUE) {
      data$pval.exposure <- as.numeric(data$pval.exposure)
      data <- subset(data, pval.exposure < p_exposure)
      data[data == ""] <- NA
      data <- na.omit(data)
      output_path <- paste0(output_dir, "/", file[i, 1], ".csv")
      write.csv(data, output_path, row.names = FALSE, quote = FALSE)
      pct <- round(i/nrow(file), 4) * 100
      cat("Completed exposure data transformation", pct, "%\n")
    } else {
      data2 <- data[, c("effect_allele.exposure", "other_allele.exposure", "samplesize.exposure",
                        "beta.exposure", "se.exposure", "eaf.exposure", "pval.exposure", "SNP",
                        "id.exposure", "exposure")]
      colnames(data2) <- c("effect_allele.outcome", "other_allele.outcome", "samplesize.outcome",
                          "beta.outcome", "se.outcome", "eaf.outcome", "pval.outcome", "SNP",
                          "id.outcome", "outcome")
      output_path <- paste0(output_dir, "/", file[i, 1])
      data2 <- subset(data2, pval.outcome > p_outcome)
      data2[data2 == ""] <- NA
      data2 <- na.omit(data2)
      write.table(data2, file = gzfile(output_path), row.names = FALSE)
      pct <- round(i/nrow(file), 4) * 100
      cat("Completed outcome data transformation", pct, "%\n")
    }
  }
}


#' Preprocess Gut Microbiome Data
#'
#' @title Gut Microbiome Data Preprocessing
#' @description Preprocesses gut microbiome data for Mendelian Randomization analysis.
#'   Converts data to exposure or outcome format and filters based on p-value thresholds.
#' @param input_dir Directory containing gut microbiome data files
#' @param output_dir Directory to save preprocessed data
#' @param as_exposure Logical, whether to process as exposure data (TRUE) or outcome data (FALSE). Default is TRUE.
#' @param p_exposure P-value threshold for selecting potential instrumental variables when processing as exposure. Default is 1e-05.
#' @param p_outcome P-value threshold for filtering variants when processing as outcome. Default is 5e-08.
#' @return NULL (saves processed files to output_dir)
#' @export
mira_prep_gut <- function(input_dir, output_dir, as_exposure = TRUE,
                          p_exposure = 1e-05, p_outcome = 5e-08) {
  library(tidyr)
  file <- dir(input_dir) %>% data.frame()
  for (i in 1:nrow(file)) {
    dir.create(output_dir, showWarnings = FALSE)
    path <- paste0(input_dir, "/", file[i, 1])
    data <- data.table::fread(path) %>% data.frame()
    colnames(data)[c(4, 6, 5, 11, 7, 8, 10)] <- c("SNP", "effect_allele.exposure",
                                                   "other_allele.exposure", "samplesize.exposure",
                                                   "beta.exposure", "se.exposure", "pval.exposure")
    data$eaf.exposure <- NA
    data$id.exposure <- data$bac
    data$exposure <- data$id.exposure
    data <- data[, c("effect_allele.exposure", "other_allele.exposure",
                     "samplesize.exposure", "beta.exposure", "se.exposure",
                     "eaf.exposure", "pval.exposure", "SNP", "id.exposure",
                     "exposure")]
    if (as_exposure == TRUE) {
      data <- subset(data, pval.exposure < p_exposure)
      output_path <- paste0(output_dir, "/", file[i, 1], ".csv")
      write.csv(data, output_path, row.names = FALSE, quote = FALSE)
      pct <- round(i/nrow(file), 4) * 100
      message("Completed exposure data transformation ", pct, "%")
    }
    else {
      data2 <- data[, c("effect_allele.exposure", "other_allele.exposure",
                        "samplesize.exposure", "beta.exposure", "se.exposure",
                        "eaf.exposure", "pval.exposure", "SNP", "id.exposure",
                        "exposure")]
      colnames(data2) <- c("effect_allele.outcome", "other_allele.outcome",
                          "samplesize.outcome", "beta.outcome", "se.outcome",
                          "eaf.outcome", "pval.outcome", "SNP", "id.outcome",
                          "outcome")

      output_path <- paste0(output_dir, "/", file[i, 1])
      data2 <- subset(data2, pval.outcome > p_outcome)
      write.table(data2, file = gzfile(output_path), row.names = FALSE)
      pct <- round(i/nrow(file), 4) * 100
      cat("Completed outcome data transformation ", pct, "%\n")
    }
  }
}


#' Split Gut Microbiome Exposure Data
#'
#' @title Gut Microbiome MR Data Splitting Tool
#' @description Splits gut microbiome exposure data by bacteria ID for separate MR analyses.
#'   Reads a combined SNP data file and splits it into individual files by bacteria.
#' @param exposure_file Path to the gut microbiome exposure SNP data file
#' @param output_dir Directory name for saving split files. Default is "Split_Gut_Exposure_Files".
#' @return NULL (saves split files to output_dir)
#' @export
mira_split_gut <- function(exposure_file, output_dir = "Split_Gut_Exposure_Files") {
  exp <- read.csv(exposure_file)
  head(exp)
  colnames(exp) <- c("id.exposure", "chr", "pos", "SNP", "other_allele.exposure",
                     "effect_allele.exposure", "beta.exposure", "se.exposure", "meta",
                     "pval.exposure", "N", "nn")
  exp$exposure <- exp$id.exposure
  data_class <- unique(exp$id.exposure)
  dir.create(output_dir, showWarnings = FALSE)
  for (i in data_class) {
    A <- subset(exp, id.exposure == i)
    output_file <- paste0(output_dir, "/", i, ".csv")
    write.csv(A, output_file, row.names = FALSE)
  }
  cat("Gut microbiome exposure data has been successfully split\n")
}
