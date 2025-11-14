#' @keywords internal
.onAttach <- function(libname, pkgname) {

  # Check license status (non-blocking)
  license_path <- .get_license_path()
  license_valid <- FALSE
  license_msg <- ""

  if(file.exists(license_path)) {
    tryCatch({
      license_data <- readRDS(license_path)
      current_machine_id <- .get_machine_id()
      expiry_date <- as.Date(license_data$expiry_date)

      if(license_data$machine_id == current_machine_id && expiry_date >= Sys.Date()) {
        license_valid <- TRUE
        days_left <- as.numeric(expiry_date - Sys.Date())
        license_msg <- paste0(
          "  License: Active (expires in ", days_left, " days)\n",
          "  User: ", license_data$user_name, "\n"
        )
      } else if(license_data$machine_id != current_machine_id) {
        license_msg <- "  \033[33mWARNING: License is for a different machine\033[0m\n"
      } else {
        license_msg <- "  \033[33mWARNING: License expired on ", license_data$expiry_date, "\033[0m\n"
      }
    }, error = function(e) {
      license_msg <<- "  \033[33mWARNING: License file is corrupted\033[0m\n"
    })
  } else {
    license_msg <- paste0(
      "  \033[33mNOTE: MiraMR is not activated\033[0m\n",
      "  Run mira_get_machine_id() to request a license\n"
    )
  }

  # Show welcome message
  packageStartupMessage(
    "\n",
    "===============================================\n",
    "  MiraMR - Mira's Mendelian Randomization Toolkit\n",
    "  Version 1.0.0\n",
    "===============================================\n",
    "\n",
    "  Dedicated to Mira, with gratitude to Candice\n",
    "\n",
    license_msg,
    "\n",
    "  Type mira_help() for package help\n",
    "  Type mira_license_status() to check your license\n",
    "\n",
    "  For support: mtmmu88@gmail.com\n",
    "  GitHub: https://github.com/mtmmu88/MiraMR\n",
    "\n",
    "===============================================\n"
  )
}
