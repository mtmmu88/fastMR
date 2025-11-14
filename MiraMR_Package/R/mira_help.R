#' Display MiraMR Package Information and Function Overview
#'
#' @description
#' Shows comprehensive information about the MiraMR package including version,
#' description, and all available functions organized by category.
#'
#' @return Prints formatted package information to the console
#'
#' @examples
#' mira_help()
#'
#' @export
mira_help <- function() {
  cat("\n")
  cat("================================================================================\n")
  cat("                          MiraMR Package v1.0.0\n")
  cat("          Mendelian Randomization Analysis Tools with IEU Integration\n")
  cat("================================================================================\n")
  cat("\n")
  cat("DESCRIPTION:\n")
  cat("  MiraMR provides comprehensive tools for Mendelian randomization analysis,\n")
  cat("  including multivariable MR, gut microbiome analysis, and seamless integration\n")
  cat("  with both IEU OpenGWAS database and local GWAS data.\n")
  cat("\n")
  cat("================================================================================\n")
  cat("                              MAIN FUNCTIONS\n")
  cat("================================================================================\n")
  cat("\n")
  cat("1. MULTIVARIABLE MR - IEU DATA CONVERSION\n")
  cat("   Functions for merging instrumental variables from mixed IEU/local sources:\n")
  cat("\n")
  cat("   0 IEU + Multiple Local Exposures:\n")
  cat("   - mira_ieu_to_local_0_2()  : 0 IEU + 2 local exposures\n")
  cat("   - mira_ieu_to_local_0_3()  : 0 IEU + 3 local exposures\n")
  cat("   - mira_ieu_to_local_0_4()  : 0 IEU + 4 local exposures\n")
  cat("   - mira_ieu_to_local_0_5()  : 0 IEU + 5 local exposures\n")
  cat("\n")
  cat("   1 IEU + Multiple Local Exposures:\n")
  cat("   - mira_ieu_to_local_1_1()  : 1 IEU + 1 local exposure\n")
  cat("   - mira_ieu_to_local_1_2()  : 1 IEU + 2 local exposures\n")
  cat("   - mira_ieu_to_local_1_3()  : 1 IEU + 3 local exposures\n")
  cat("   - mira_ieu_to_local_1_4()  : 1 IEU + 4 local exposures\n")
  cat("\n")
  cat("   2 IEU + Multiple Local Exposures:\n")
  cat("   - mira_ieu_to_local_2_1()  : 2 IEU + 1 local exposure\n")
  cat("   - mira_ieu_to_local_2_2()  : 2 IEU + 2 local exposures\n")
  cat("   - mira_ieu_to_local_2_3()  : 2 IEU + 3 local exposures\n")
  cat("\n")
  cat("--------------------------------------------------------------------------------\n")
  cat("\n")
  cat("2. GUT MICROBIOME ANALYSIS\n")
  cat("   Specialized functions for gut microbiome MR analysis:\n")
  cat("\n")
  cat("   Gut Microbiome as Exposure:\n")
  cat("   - mira_gut_ieu()     : Gut microbiome -> IEU outcome\n")
  cat("   - mira_gut_local()   : Gut microbiome -> Local outcome\n")
  cat("                          (supports local LD clumping)\n")
  cat("\n")
  cat("   Gut Microbiome as Outcome:\n")
  cat("   - mira_ieu_gut()     : IEU exposure -> Gut microbiome (216 traits)\n")
  cat("   - mira_local_gut()   : Local exposure -> Gut microbiome (216 traits)\n")
  cat("\n")
  cat("--------------------------------------------------------------------------------\n")
  cat("\n")
  cat("3. PACKAGE MANAGEMENT\n")
  cat("   - mira_help()        : Display this help information\n")
  cat("   - mira_update()      : Update package from GitHub\n")
  cat("\n")
  cat("================================================================================\n")
  cat("                            GETTING STARTED\n")
  cat("================================================================================\n")
  cat("\n")
  cat("For detailed documentation on any function, use:\n")
  cat("  ?function_name\n")
  cat("\n")
  cat("Example:\n")
  cat("  ?mira_ieu_to_local_1_2\n")
  cat("  ?mira_gut_ieu\n")
  cat("\n")
  cat("For package updates:\n")
  cat("  mira_update()\n")
  cat("\n")
  cat("================================================================================\n")
  cat("                            KEY FEATURES\n")
  cat("================================================================================\n")
  cat("\n")
  cat("- Seamless integration with IEU OpenGWAS database\n")
  cat("- Support for local GWAS summary data\n")
  cat("- Multivariable MR with flexible exposure combinations\n")
  cat("- Comprehensive gut microbiome analysis (216 traits)\n")
  cat("- Automated LD clumping (online and local options)\n")
  cat("- Heterogeneity and pleiotropy testing\n")
  cat("- Automatic odds ratio calculation with confidence intervals\n")
  cat("- F-statistic calculation for instrument strength\n")
  cat("\n")
  cat("================================================================================\n")
  cat("                          DEPENDENCIES\n")
  cat("================================================================================\n")
  cat("\n")
  cat("Required packages:\n")
  cat("  - TwoSampleMR\n")
  cat("  - tidyr\n")
  cat("  - dplyr\n")
  cat("\n")
  cat("For local LD clumping:\n")
  cat("  - plink2 binary\n")
  cat("  - 1000 Genomes reference panel\n")
  cat("\n")
  cat("================================================================================\n")
  cat("                        CITATION & SUPPORT\n")
  cat("================================================================================\n")
  cat("\n")
  cat("GitHub: https://github.com/yourusername/MiraMR\n")
  cat("\n")
  cat("If you use MiraMR in your research, please cite:\n")
  cat("  [Citation information to be added]\n")
  cat("\n")
  cat("For bug reports and feature requests:\n")
  cat("  https://github.com/yourusername/MiraMR/issues\n")
  cat("\n")
  cat("================================================================================\n")
  cat("\n")
}


#' Update MiraMR Package from GitHub
#'
#' @description
#' Provides instructions and automated update process for installing the latest
#' version of MiraMR from GitHub.
#'
#' @param auto_install Logical indicating whether to automatically install the update
#'   (default: FALSE). If FALSE, only shows installation instructions.
#'
#' @return If auto_install=FALSE, prints installation instructions. If auto_install=TRUE,
#'   attempts to install the package from GitHub using devtools or remotes.
#'
#' @details
#' When auto_install=TRUE, this function will:
#' 1. Check if devtools or remotes is installed
#' 2. Install from GitHub repository
#' 3. Reload the package
#'
#' When auto_install=FALSE, it displays manual installation instructions.
#'
#' @examples
#' # Show installation instructions
#' mira_update()
#'
#' # Automatically install update
#' mira_update(auto_install = TRUE)
#'
#' @export
mira_update <- function(auto_install = FALSE) {
  cat("\n")
  cat("================================================================================\n")
  cat("                       MiraMR Package Update\n")
  cat("================================================================================\n")
  cat("\n")

  if (auto_install) {
    cat("Attempting to update MiraMR from GitHub...\n\n")

    # Check if devtools or remotes is available
    has_devtools <- requireNamespace("devtools", quietly = TRUE)
    has_remotes <- requireNamespace("remotes", quietly = TRUE)

    if (!has_devtools && !has_remotes) {
      cat("ERROR: Neither 'devtools' nor 'remotes' package is installed.\n")
      cat("\nPlease install one of them first:\n")
      cat("  install.packages('devtools')\n")
      cat("  # OR\n")
      cat("  install.packages('remotes')\n\n")
      cat("Then run mira_update(auto_install = TRUE) again.\n")
      cat("================================================================================\n\n")
      return(invisible(NULL))
    }

    # Attempt installation
    tryCatch(
      {
        if (has_devtools) {
          cat("Using devtools to install...\n")
          devtools::install_github("yourusername/MiraMR", upgrade = "never")
        } else {
          cat("Using remotes to install...\n")
          remotes::install_github("yourusername/MiraMR", upgrade = "never")
        }
        cat("\n")
        cat("================================================================================\n")
        cat("                    Installation Successful!\n")
        cat("================================================================================\n")
        cat("\n")
        cat("Please restart your R session and reload the package:\n")
        cat("  library(MiraMR)\n")
        cat("\n")
        cat("To verify the installation:\n")
        cat("  packageVersion('MiraMR')\n")
        cat("  mira_help()\n")
        cat("\n")
        cat("================================================================================\n\n")
      },
      error = function(e) {
        cat("\n")
        cat("ERROR: Installation failed.\n")
        cat("Error message:", conditionMessage(e), "\n\n")
        cat("Please try manual installation (see instructions below).\n")
        cat("================================================================================\n\n")
        mira_update(auto_install = FALSE)
      }
    )
  } else {
    cat("To update MiraMR to the latest version, use one of these methods:\n\n")
    cat("--------------------------------------------------------------------------------\n")
    cat("METHOD 1: Using devtools (Recommended)\n")
    cat("--------------------------------------------------------------------------------\n")
    cat("\n")
    cat("1. Install devtools if you haven't already:\n")
    cat("   install.packages('devtools')\n\n")
    cat("2. Install/Update MiraMR from GitHub:\n")
    cat("   devtools::install_github('yourusername/MiraMR')\n\n")
    cat("3. Restart R and load the package:\n")
    cat("   library(MiraMR)\n\n")
    cat("\n")
    cat("--------------------------------------------------------------------------------\n")
    cat("METHOD 2: Using remotes\n")
    cat("--------------------------------------------------------------------------------\n")
    cat("\n")
    cat("1. Install remotes if you haven't already:\n")
    cat("   install.packages('remotes')\n\n")
    cat("2. Install/Update MiraMR from GitHub:\n")
    cat("   remotes::install_github('yourusername/MiraMR')\n\n")
    cat("3. Restart R and load the package:\n")
    cat("   library(MiraMR)\n\n")
    cat("\n")
    cat("--------------------------------------------------------------------------------\n")
    cat("METHOD 3: Automatic Update (from within MiraMR)\n")
    cat("--------------------------------------------------------------------------------\n")
    cat("\n")
    cat("Run the following command:\n")
    cat("   mira_update(auto_install = TRUE)\n\n")
    cat("\n")
    cat("================================================================================\n")
    cat("                         VERIFY INSTALLATION\n")
    cat("================================================================================\n")
    cat("\n")
    cat("After updating, verify the installation:\n\n")
    cat("1. Check package version:\n")
    cat("   packageVersion('MiraMR')\n\n")
    cat("2. View package information:\n")
    cat("   mira_help()\n\n")
    cat("3. Check available functions:\n")
    cat("   ls('package:MiraMR')\n\n")
    cat("\n")
    cat("================================================================================\n")
    cat("                        TROUBLESHOOTING\n")
    cat("================================================================================\n")
    cat("\n")
    cat("If you encounter issues:\n\n")
    cat("1. Make sure you have the latest version of R (>= 4.0.0)\n\n")
    cat("2. Update your packages:\n")
    cat("   update.packages(ask = FALSE)\n\n")
    cat("3. Install dependencies manually:\n")
    cat("   install.packages(c('TwoSampleMR', 'tidyr', 'dplyr'))\n\n")
    cat("4. Clear package cache and reinstall:\n")
    cat("   remove.packages('MiraMR')\n")
    cat("   devtools::install_github('yourusername/MiraMR', force = TRUE)\n\n")
    cat("5. For additional help, visit:\n")
    cat("   https://github.com/yourusername/MiraMR/issues\n\n")
    cat("\n")
    cat("================================================================================\n")
    cat("                        RELEASE NOTES\n")
    cat("================================================================================\n")
    cat("\n")
    cat("To view the latest changes and release notes:\n")
    cat("   https://github.com/yourusername/MiraMR/releases\n\n")
    cat("\n")
    cat("================================================================================\n\n")
  }

  return(invisible(NULL))
}
