#' MiraMR License Management System
#'
#' @description Internal functions for managing MiraMR licenses.
#'   Supports license generation, activation, and validation with
#'   machine binding and expiration dates.
#'
#' @name mira_license
#' @keywords internal
NULL


# Get machine fingerprint (unique identifier for this computer)
.get_machine_id <- function() {
  # Combine multiple system identifiers to create unique machine fingerprint
  sys_info <- Sys.info()

  # Get machine identifiable information
  machine_data <- paste0(
    sys_info["nodename"],
    sys_info["machine"],
    sys_info["sysname"],
    sys_info["user"]
  )

  # Create hash
  machine_id <- digest::digest(machine_data, algo = "sha256")

  return(machine_id)
}


# Get license file path
.get_license_path <- function() {
  config_dir <- tools::R_user_dir("MiraMR", "config")
  dir.create(config_dir, showWarnings = FALSE, recursive = TRUE)
  file.path(config_dir, "license.rds")
}


#' Generate MiraMR License Key (Admin Only)
#'
#' @title Generate License Key for MiraMR
#' @description This function is for administrators only. Generates a license key
#'   for a user that is bound to their specific machine and has an expiration date.
#' @param user_name User's name
#' @param user_email User's email address
#' @param machine_id Machine fingerprint (obtained from user via mira_get_machine_id())
#' @param expiry_days Number of days until license expires. Default is 365 (1 year).
#' @param notes Optional notes about this license
#' @return Character string containing the encrypted license key
#' @details
#' This function should only be used by package administrators to generate
#' license keys for authorized users. The license key is bound to a specific
#' machine and will not work on other computers.
#'
#' Workflow:
#' 1. User runs mira_get_machine_id() and sends you their machine ID
#' 2. You run this function to generate a license key
#' 3. You send the license key to the user
#' 4. User runs mira_activate(license_key) to activate
#' @examples
#' \dontrun{
#' # Administrator generates a license
#' license <- mira_generate_license(
#'   user_name = "Dr. Smith",
#'   user_email = "smith@university.edu",
#'   machine_id = "abc123def456...",  # from user
#'   expiry_days = 365,
#'   notes = "Annual license for 2024"
#' )
#'
#' # Send the license key to the user
#' cat(license)
#' }
#' @export
mira_generate_license <- function(user_name,
                                   user_email,
                                   machine_id,
                                   expiry_days = 365,
                                   notes = NULL) {

  if(!requireNamespace("digest", quietly = TRUE)) {
    stop("Package 'digest' is required. Install with: install.packages('digest')")
  }
  if(!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required. Install with: install.packages('jsonlite')")
  }
  if(!requireNamespace("openssl", quietly = TRUE)) {
    stop("Package 'openssl' is required. Install with: install.packages('openssl')")
  }

  # Create license data
  license_data <- list(
    user_name = user_name,
    user_email = user_email,
    machine_id = machine_id,
    issue_date = as.character(Sys.Date()),
    expiry_date = as.character(Sys.Date() + expiry_days),
    notes = notes,
    version = "1.0.0"
  )

  # Secret key for signing (KEEP THIS SECRET!)
  secret_key <- "MiraMR_2024_Candice_Mira_Secret_Key_Do_Not_Share"

  # Create signature
  data_string <- paste0(
    license_data$user_name,
    license_data$user_email,
    license_data$machine_id,
    license_data$issue_date,
    license_data$expiry_date
  )

  signature <- digest::digest(paste0(data_string, secret_key), algo = "sha256")
  license_data$signature <- signature

  # Convert to JSON and encrypt
  license_json <- jsonlite::toJSON(license_data, auto_unbox = TRUE)
  license_encoded <- openssl::base64_encode(charToRaw(license_json))

  # Print summary
  message("\n=== License Generated Successfully ===")
  message("User: ", user_name, " (", user_email, ")")
  message("Machine ID: ", substr(machine_id, 1, 16), "...")
  message("Issue Date: ", license_data$issue_date)
  message("Expiry Date: ", license_data$expiry_date)
  message("Valid for: ", expiry_days, " days")
  if(!is.null(notes)) message("Notes: ", notes)
  message("\nLicense Key (send this to user):")
  message("=====================================")

  return(license_encoded)
}


#' Get Machine ID for License Request
#'
#' @title Get Machine Fingerprint for License Activation
#' @description Gets the unique machine fingerprint for this computer.
#'   Users should run this function and send the machine ID to the
#'   package administrator to request a license.
#' @return Character string containing the machine ID
#' @details
#' The machine ID is a unique identifier for your computer based on
#' system information. This ID must be provided to the administrator
#' when requesting a MiraMR license.
#'
#' Steps to obtain a license:
#' 1. Run this function to get your machine ID
#' 2. Send your name, email, and machine ID to mtmmu88@gmail.com
#' 3. Administrator will generate a license key for you
#' 4. Use mira_activate() to activate your license
#' @examples
#' \dontrun{
#' # Get your machine ID
#' my_machine_id <- mira_get_machine_id()
#'
#' # Send this information to mtmmu88@gmail.com:
#' # - Your name
#' # - Your email
#' # - Machine ID: [paste the ID here]
#' }
#' @export
mira_get_machine_id <- function() {

  if(!requireNamespace("digest", quietly = TRUE)) {
    stop("Package 'digest' is required. Install with: install.packages('digest')")
  }

  machine_id <- .get_machine_id()

  message("\n=== MiraMR License Request ===")
  message("\nYour Machine ID:")
  message("=====================================")
  message(machine_id)
  message("=====================================")
  message("\nTo request a MiraMR license:")
  message("1. Copy the Machine ID above")
  message("2. Email mtmmu88@gmail.com with:")
  message("   - Your name")
  message("   - Your email address")
  message("   - Your machine ID")
  message("   - Purpose of use (optional)")
  message("\nYou will receive a license key via email.")
  message("Use mira_activate(license_key) to activate.\n")

  invisible(machine_id)
}


#' Activate MiraMR License
#'
#' @title Activate MiraMR License Key
#' @description Activates a MiraMR license key on this computer.
#'   The license key must be obtained from the package administrator.
#' @param license_key Character string containing the license key
#' @return Invisible TRUE if activation successful
#' @details
#' This function validates and activates a license key received from
#' the package administrator. The license is bound to your machine
#' and has an expiration date.
#'
#' If the license key is invalid, expired, or not for this machine,
#' activation will fail with an error message.
#' @examples
#' \dontrun{
#' # Activate license received from administrator
#' mira_activate("your_license_key_here")
#'
#' # Now you can use MiraMR
#' library(MiraMR)
#' }
#' @export
mira_activate <- function(license_key) {

  if(!requireNamespace("digest", quietly = TRUE)) {
    stop("Package 'digest' is required. Install with: install.packages('digest')")
  }
  if(!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required. Install with: install.packages('jsonlite')")
  }
  if(!requireNamespace("openssl", quietly = TRUE)) {
    stop("Package 'openssl' is required. Install with: install.packages('openssl')")
  }

  tryCatch({
    # Decode license
    license_json <- rawToChar(openssl::base64_decode(license_key))
    license_data <- jsonlite::fromJSON(license_json)

    # Verify signature
    secret_key <- "MiraMR_2024_Candice_Mira_Secret_Key_Do_Not_Share"
    data_string <- paste0(
      license_data$user_name,
      license_data$user_email,
      license_data$machine_id,
      license_data$issue_date,
      license_data$expiry_date
    )

    expected_signature <- digest::digest(paste0(data_string, secret_key), algo = "sha256")

    if(license_data$signature != expected_signature) {
      stop("Invalid license key: Signature verification failed.\n",
           "This license key may have been tampered with or is corrupted.\n",
           "Please contact mtmmu88@gmail.com for a new license.")
    }

    # Check machine ID
    current_machine_id <- .get_machine_id()
    if(license_data$machine_id != current_machine_id) {
      stop("License key is not valid for this machine.\n",
           "This license is bound to a different computer.\n",
           "Your machine ID: ", substr(current_machine_id, 1, 16), "...\n",
           "License machine ID: ", substr(license_data$machine_id, 1, 16), "...\n",
           "Please run mira_get_machine_id() and request a new license for this machine.")
    }

    # Check expiration
    expiry_date <- as.Date(license_data$expiry_date)
    if(expiry_date < Sys.Date()) {
      stop("License has expired on ", license_data$expiry_date, "\n",
           "Please contact mtmmu88@gmail.com for license renewal.")
    }

    # Save license
    license_path <- .get_license_path()
    saveRDS(license_data, license_path)

    # Success message
    days_remaining <- as.numeric(expiry_date - Sys.Date())

    message("\n=== MiraMR License Activated Successfully ===")
    message("User: ", license_data$user_name)
    message("Email: ", license_data$user_email)
    message("Issue Date: ", license_data$issue_date)
    message("Expiry Date: ", license_data$expiry_date)
    message("Days Remaining: ", days_remaining, " days")
    if(!is.null(license_data$notes)) {
      message("Notes: ", license_data$notes)
    }
    message("\nThank you for using MiraMR!")
    message("For support, contact: mtmmu88@gmail.com\n")

    invisible(TRUE)

  }, error = function(e) {
    stop("License activation failed: ", e$message, call. = FALSE)
  })
}


#' Check MiraMR License Status
#'
#' @title Check Current License Status
#' @description Displays information about the currently activated license.
#' @return Invisible list containing license information
#' @examples
#' \dontrun{
#' # Check your current license
#' mira_license_status()
#' }
#' @export
mira_license_status <- function() {

  license_path <- .get_license_path()

  if(!file.exists(license_path)) {
    message("\n=== No License Found ===")
    message("\nMiraMR is not activated on this computer.")
    message("\nTo activate:")
    message("1. Run: mira_get_machine_id()")
    message("2. Send machine ID to: mtmmu88@gmail.com")
    message("3. Receive license key via email")
    message("4. Run: mira_activate(license_key)\n")
    return(invisible(NULL))
  }

  license_data <- readRDS(license_path)

  expiry_date <- as.Date(license_data$expiry_date)
  days_remaining <- as.numeric(expiry_date - Sys.Date())
  is_expired <- expiry_date < Sys.Date()

  message("\n=== MiraMR License Status ===")
  message("User: ", license_data$user_name)
  message("Email: ", license_data$user_email)
  message("Issue Date: ", license_data$issue_date)
  message("Expiry Date: ", license_data$expiry_date)

  if(is_expired) {
    message("Status: EXPIRED")
    message("Expired ", abs(days_remaining), " days ago")
    message("\nPlease contact mtmmu88@gmail.com for renewal.")
  } else {
    message("Status: ACTIVE")
    message("Days Remaining: ", days_remaining, " days")

    if(days_remaining < 30) {
      message("\nWARNING: License expires soon!")
      message("Contact mtmmu88@gmail.com for renewal.")
    }
  }

  if(!is.null(license_data$notes)) {
    message("Notes: ", license_data$notes)
  }

  message("\nSupport: mtmmu88@gmail.com\n")

  invisible(license_data)
}


#' Deactivate MiraMR License
#'
#' @title Remove License from This Computer
#' @description Removes the activated license from this computer.
#'   Use this before uninstalling MiraMR or transferring to another machine.
#' @return Invisible TRUE if deactivation successful
#' @examples
#' \dontrun{
#' # Remove license from this computer
#' mira_deactivate()
#' }
#' @export
mira_deactivate <- function() {
  license_path <- .get_license_path()

  if(!file.exists(license_path)) {
    message("No active license found on this computer.")
    return(invisible(FALSE))
  }

  license_data <- readRDS(license_path)

  # Remove license file
  file.remove(license_path)

  message("\n=== License Deactivated ===")
  message("User: ", license_data$user_name)
  message("Email: ", license_data$user_email)
  message("\nLicense has been removed from this computer.")
  message("To reactivate, use mira_activate() with your license key.\n")

  invisible(TRUE)
}


# Internal function: Validate license on package load
.validate_license <- function() {

  license_path <- .get_license_path()

  # Check if license exists
  if(!file.exists(license_path)) {
    stop("\n===============================================\n",
         "MiraMR License Required\n",
         "===============================================\n\n",
         "MiraMR is not activated on this computer.\n\n",
         "To obtain a license:\n",
         "1. Run: MiraMR::mira_get_machine_id()\n",
         "2. Email your machine ID to: mtmmu88@gmail.com\n",
         "   Include: your name, email, and purpose of use\n",
         "3. You will receive a license key via email\n",
         "4. Run: MiraMR::mira_activate('your_license_key')\n\n",
         "For questions: mtmmu88@gmail.com\n",
         "===============================================\n",
         call. = FALSE)
  }

  # Load license
  license_data <- readRDS(license_path)

  # Validate machine ID
  current_machine_id <- .get_machine_id()
  if(license_data$machine_id != current_machine_id) {
    stop("\n===============================================\n",
         "License Machine Mismatch\n",
         "===============================================\n\n",
         "This license is not valid for this computer.\n",
         "It is bound to a different machine.\n\n",
         "To use MiraMR on this computer:\n",
         "1. Run: MiraMR::mira_get_machine_id()\n",
         "2. Request a new license for this machine\n",
         "   Email: mtmmu88@gmail.com\n\n",
         "===============================================\n",
         call. = FALSE)
  }

  # Check expiration
  expiry_date <- as.Date(license_data$expiry_date)
  if(expiry_date < Sys.Date()) {
    stop("\n===============================================\n",
         "License Expired\n",
         "===============================================\n\n",
         "Your MiraMR license expired on: ", license_data$expiry_date, "\n\n",
         "User: ", license_data$user_name, "\n",
         "Email: ", license_data$user_email, "\n\n",
         "To renew your license:\n",
         "Contact: mtmmu88@gmail.com\n\n",
         "===============================================\n",
         call. = FALSE)
  }

  # Check if expiring soon (within 7 days)
  days_remaining <- as.numeric(expiry_date - Sys.Date())
  if(days_remaining <= 7) {
    warning("\n*** LICENSE EXPIRING SOON ***\n",
            "Your MiraMR license expires in ", days_remaining, " day(s)\n",
            "Expiry date: ", license_data$expiry_date, "\n",
            "Contact mtmmu88@gmail.com for renewal\n",
            call. = FALSE, immediate. = TRUE)
  }

  # License is valid
  return(TRUE)
}
