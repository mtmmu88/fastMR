#' @keywords internal
.onAttach <- function(libname, pkgname) {

  # Validate license first
  .validate_license()

  # If validation passes, show welcome message
  packageStartupMessage(
    "\n",
    "===============================================\n",
    "  MiraMR - Mira's Mendelian Randomization Toolkit\n",
    "  Version 1.0.0\n",
    "===============================================\n",
    "\n",
    "  Dedicated to Mira, with gratitude to Candice\n",
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
