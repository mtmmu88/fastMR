#' Convert Chromosome Position to rsID
#'
#' @title Convert CHR:BP to rsID using dbSNP Database
#' @description Converts chromosome and base pair position to rsID (SNP identifier)
#'   using the dbSNP database. This is useful when GWAS data contains only positional
#'   information but MR analysis requires rsIDs.
#' @param data Data frame containing chromosome and position columns
#' @param chr_col Column name for chromosome. Default is "CHR".
#' @param bp_col Column name for base pair position. Default is "BP".
#' @param build Genome build version: "GRCh37" (hg19) or "GRCh38" (hg38). Default is "GRCh37".
#' @param remove_duplicates Logical, whether to remove duplicate positions (keeps first). Default is TRUE.
#' @param remove_multi Logical, whether to remove SNPs with comma-separated rsIDs. Default is TRUE.
#' @param chunk_size Number of rows to process at once (for memory management). Default is 100000.
#' @param verbose Logical, whether to print progress messages. Default is TRUE.
#' @return Data frame with added SNP column containing rsIDs
#' @details
#' This function requires one of the following Bioconductor packages:
#' \itemize{
#'   \item SNPlocs.Hsapiens.dbSNP155.GRCh37 (for hg19/b37)
#'   \item SNPlocs.Hsapiens.dbSNP155.GRCh38 (for hg38)
#' }
#'
#' To install:
#' \preformatted{
#' if (!require("BiocManager", quietly = TRUE))
#'     install.packages("BiocManager")
#' BiocManager::install("SNPlocs.Hsapiens.dbSNP155.GRCh37")
#' BiocManager::install("SNPlocs.Hsapiens.dbSNP155.GRCh38")
#' }
#'
#' The function handles:
#' \itemize{
#'   \item X chromosome (converts "X", "x", "23" to "X")
#'   \item Missing values (removes rows with NA in CHR or BP)
#'   \item Duplicate positions (optional removal)
#'   \item Memory-efficient processing via chunking
#' }
#' @note This function requires significant memory for large datasets.
#'   Use chunk_size parameter to control memory usage.
#' @examples
#' \dontrun{
#' # Convert positions to rsIDs
#' data_with_rsid <- mira_chr_to_rsid(
#'   data = gwas_data,
#'   chr_col = "chromosome",
#'   bp_col = "position",
#'   build = "GRCh37"
#' )
#'
#' # For GRCh38 data
#' data_with_rsid <- mira_chr_to_rsid(
#'   data = gwas_data,
#'   build = "GRCh38"
#' )
#' }
#' @export
mira_chr_to_rsid <- function(data,
                             chr_col = "CHR",
                             bp_col = "BP",
                             build = c("GRCh37", "GRCh38"),
                             remove_duplicates = TRUE,
                             remove_multi = TRUE,
                             chunk_size = 100000,
                             verbose = TRUE) {

  library(data.table)
  library(dplyr)

  build <- match.arg(build)

  if(verbose) message("Starting CHR:BP to rsID conversion...")
  if(verbose) message("Genome build: ", build)

  # Check if required package is installed
  if(build == "GRCh37") {
    pkg_name <- "SNPlocs.Hsapiens.dbSNP155.GRCh37"
  } else {
    pkg_name <- "SNPlocs.Hsapiens.dbSNP155.GRCh38"
  }

  if(!requireNamespace(pkg_name, quietly = TRUE)) {
    stop("Package '", pkg_name, "' is required but not installed.\n",
         "Install it with:\n",
         "BiocManager::install('", pkg_name, "')")
  }

  # Load required packages
  if(!requireNamespace("GenomicRanges", quietly = TRUE)) {
    stop("Package 'GenomicRanges' is required. Install with: BiocManager::install('GenomicRanges')")
  }
  if(!requireNamespace("BSgenome", quietly = TRUE)) {
    stop("Package 'BSgenome' is required. Install with: BiocManager::install('BSgenome')")
  }

  # Load SNP location data
  if(verbose) message("Loading dbSNP reference data...")
  if(build == "GRCh37") {
    SNP_LOC_DATA <- SNPlocs.Hsapiens.dbSNP155.GRCh37::SNPlocs.Hsapiens.dbSNP155.GRCh37
  } else {
    SNP_LOC_DATA <- SNPlocs.Hsapiens.dbSNP155.GRCh38::SNPlocs.Hsapiens.dbSNP155.GRCh38
  }

  # Standardize column names
  if(chr_col != "CHR") {
    data$CHR <- data[[chr_col]]
  }
  if(bp_col != "BP") {
    data$BP <- data[[bp_col]]
  }

  # Convert to data.table for efficiency
  setDT(data)

  # Convert CHR and BP to character
  data$CHR <- as.character(data$CHR)
  data$BP <- as.character(data$BP)

  # Remove missing values
  original_nrow <- nrow(data)
  data <- data[complete.cases(data[, c("CHR", "BP"), with = FALSE])]
  if(verbose) message("Removed ", original_nrow - nrow(data), " rows with missing CHR or BP")

  # Handle X chromosome
  data$CHR <- ifelse(data$CHR %in% c("23", "X", "x"), "X", data$CHR)

  # Process by chromosome to save memory
  if(verbose) message("Processing ", nrow(data), " variants across chromosomes...")

  chr_list <- split(data, data$CHR)
  result_list <- list()

  for(chr in names(chr_list)) {
    chr_data <- chr_list[[chr]]
    if(verbose) message("  Processing chromosome ", chr, " (", nrow(chr_data), " variants)...")

    # Process in chunks if data is large
    if(nrow(chr_data) > chunk_size) {
      n_chunks <- ceiling(nrow(chr_data) / chunk_size)
      chr_result_list <- list()

      for(i in 1:n_chunks) {
        start_idx <- (i - 1) * chunk_size + 1
        end_idx <- min(i * chunk_size, nrow(chr_data))
        chunk <- chr_data[start_idx:end_idx, ]

        if(verbose) message("    Chunk ", i, "/", n_chunks, " (rows ", start_idx, "-", end_idx, ")")

        # Convert to GRanges
        gr <- tryCatch({
          GenomicRanges::makeGRangesFromDataFrame(
            chunk,
            keep.extra.columns = TRUE,
            seqnames.field = "CHR",
            start.field = "BP",
            end.field = "BP"
          )
        }, error = function(e) {
          warning("Error creating GRanges for chromosome ", chr, ": ", e$message)
          return(NULL)
        })

        if(!is.null(gr)) {
          # Find overlapping SNPs
          rsids <- tryCatch({
            snp_hits <- BSgenome::snpsByOverlaps(SNP_LOC_DATA, ranges = gr)
            setDT(data.frame(snp_hits))
          }, error = function(e) {
            warning("Error finding SNP overlaps for chromosome ", chr, ": ", e$message)
            return(NULL)
          })

          if(!is.null(rsids) && nrow(rsids) > 0) {
            # Remove duplicates if requested
            if(remove_duplicates) {
              rsids <- rsids %>%
                filter(!duplicated(paste0(seqnames, pos))) %>%
                select(seqnames, pos, RefSNP_id) %>%
                rename(CHR = seqnames, BP = pos, SNP = RefSNP_id)
            } else {
              rsids <- rsids %>%
                select(seqnames, pos, RefSNP_id) %>%
                rename(CHR = seqnames, BP = pos, SNP = RefSNP_id)
            }

            rsids$CHR <- as.character(rsids$CHR)
            rsids$BP <- as.character(rsids$BP)

            # Merge with original data
            chunk_result <- left_join(chunk, rsids, by = c("CHR", "BP"))
          } else {
            chunk_result <- chunk
            chunk_result$SNP <- NA_character_
          }

          chr_result_list[[i]] <- chunk_result
        } else {
          chunk$SNP <- NA_character_
          chr_result_list[[i]] <- chunk
        }

        # Garbage collection
        gc(verbose = FALSE)
      }

      result_list[[chr]] <- rbindlist(chr_result_list)

    } else {
      # Process entire chromosome at once
      gr <- tryCatch({
        GenomicRanges::makeGRangesFromDataFrame(
          chr_data,
          keep.extra.columns = TRUE,
          seqnames.field = "CHR",
          start.field = "BP",
          end.field = "BP"
        )
      }, error = function(e) {
        warning("Error creating GRanges for chromosome ", chr, ": ", e$message)
        return(NULL)
      })

      if(!is.null(gr)) {
        rsids <- tryCatch({
          snp_hits <- BSgenome::snpsByOverlaps(SNP_LOC_DATA, ranges = gr)
          setDT(data.frame(snp_hits))
        }, error = function(e) {
          warning("Error finding SNP overlaps for chromosome ", chr, ": ", e$message)
          return(NULL)
        })

        if(!is.null(rsids) && nrow(rsids) > 0) {
          if(remove_duplicates) {
            rsids <- rsids %>%
              filter(!duplicated(paste0(seqnames, pos))) %>%
              select(seqnames, pos, RefSNP_id) %>%
              rename(CHR = seqnames, BP = pos, SNP = RefSNP_id)
          } else {
            rsids <- rsids %>%
              select(seqnames, pos, RefSNP_id) %>%
              rename(CHR = seqnames, BP = pos, SNP = RefSNP_id)
          }

          rsids$CHR <- as.character(rsids$CHR)
          rsids$BP <- as.character(rsids$BP)

          chr_result <- left_join(chr_data, rsids, by = c("CHR", "BP"))
        } else {
          chr_result <- chr_data
          chr_result$SNP <- NA_character_
        }

        result_list[[chr]] <- chr_result
      } else {
        chr_data$SNP <- NA_character_
        result_list[[chr]] <- chr_data
      }

      gc(verbose = FALSE)
    }
  }

  # Combine results
  if(verbose) message("Combining results...")
  result <- rbindlist(result_list)

  # Quality control
  before_qc <- nrow(result)
  n_matched <- sum(!is.na(result$SNP))
  if(verbose) message("Matched ", n_matched, " out of ", before_qc, " variants (",
                     round(100 * n_matched / before_qc, 2), "%)")

  # Remove variants without rsID
  result <- result[!is.na(SNP) & SNP != ""]
  if(verbose) message("Removed ", before_qc - nrow(result), " variants without rsID")

  # Remove SNPs with comma-separated IDs if requested
  if(remove_multi) {
    before_multi <- nrow(result)
    result <- result[!grepl(',', SNP)]
    if(verbose) message("Removed ", before_multi - nrow(result), " variants with multiple rsIDs")
  }

  if(verbose) message("Final dataset: ", nrow(result), " variants with rsIDs")

  return(as.data.frame(result))
}


#' Batch Convert Multiple Files from CHR:BP to rsID
#'
#' @title Batch Convert Multiple GWAS Files from Positions to rsIDs
#' @description Reads multiple GWAS files, converts CHR:BP to rsID for each,
#'   and optionally merges them into a single dataset.
#' @param file_dir Directory containing input files
#' @param file_pattern Pattern to match files (e.g., "*.txt", "*.csv"). Default is "*".
#' @param chr_col Column name for chromosome. Default is "CHR".
#' @param bp_col Column name for base pair position. Default is "BP".
#' @param build Genome build: "GRCh37" or "GRCh38". Default is "GRCh37".
#' @param merge Logical, whether to merge all files into one dataset. Default is TRUE.
#' @param output_file Output file name (if merge = TRUE). Default is "merged_with_rsid.txt".
#' @param output_dir Output directory. Default is current directory.
#' @param save_individual Logical, whether to save individual converted files. Default is FALSE.
#' @param remove_duplicates Logical, whether to remove duplicate positions. Default is TRUE.
#' @param verbose Logical, whether to print progress. Default is TRUE.
#' @return If merge = TRUE, returns merged data frame. Otherwise, returns list of data frames.
#' @examples
#' \dontrun{
#' # Convert all CSV files in directory
#' result <- mira_chr_to_rsid_batch(
#'   file_dir = "gwas_data/",
#'   file_pattern = "*.csv",
#'   build = "GRCh37",
#'   merge = TRUE
#' )
#' }
#' @export
mira_chr_to_rsid_batch <- function(file_dir,
                                   file_pattern = "*",
                                   chr_col = "CHR",
                                   bp_col = "BP",
                                   build = c("GRCh37", "GRCh38"),
                                   merge = TRUE,
                                   output_file = "merged_with_rsid.txt",
                                   output_dir = ".",
                                   save_individual = FALSE,
                                   remove_duplicates = TRUE,
                                   verbose = TRUE) {

  library(data.table)

  build <- match.arg(build)

  # Get list of files
  files <- list.files(file_dir, pattern = glob2rx(file_pattern), full.names = TRUE)

  if(length(files) == 0) {
    stop("No files found matching pattern '", file_pattern, "' in directory '", file_dir, "'")
  }

  if(verbose) message("Found ", length(files), " files to process")

  result_list <- list()

  for(i in 1:length(files)) {
    file <- files[i]
    if(verbose) message("\n[", i, "/", length(files), "] Processing: ", basename(file))

    # Read file
    data <- tryCatch({
      fread(file, data.table = FALSE)
    }, error = function(e) {
      warning("Failed to read file ", file, ": ", e$message)
      return(NULL)
    })

    if(!is.null(data)) {
      # Convert CHR:BP to rsID
      converted <- tryCatch({
        mira_chr_to_rsid(
          data = data,
          chr_col = chr_col,
          bp_col = bp_col,
          build = build,
          remove_duplicates = remove_duplicates,
          verbose = verbose
        )
      }, error = function(e) {
        warning("Failed to convert file ", file, ": ", e$message)
        return(NULL)
      })

      if(!is.null(converted)) {
        result_list[[basename(file)]] <- converted

        # Save individual file if requested
        if(save_individual) {
          dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
          output_path <- file.path(output_dir, paste0(tools::file_path_sans_ext(basename(file)), "_rsid.txt"))
          fwrite(converted, output_path, sep = "\t", row.names = FALSE, quote = FALSE)
          if(verbose) message("Saved to: ", output_path)
        }
      }
    }

    gc(verbose = FALSE)
  }

  # Merge if requested
  if(merge && length(result_list) > 0) {
    if(verbose) message("\nMerging all datasets...")
    merged <- rbindlist(result_list, fill = TRUE)

    # Save merged file
    dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
    output_path <- file.path(output_dir, output_file)
    fwrite(merged, output_path, sep = "\t", row.names = FALSE, quote = FALSE)
    if(verbose) message("Merged data saved to: ", output_path)
    if(verbose) message("Total variants: ", nrow(merged))

    return(as.data.frame(merged))
  } else {
    return(result_list)
  }
}
