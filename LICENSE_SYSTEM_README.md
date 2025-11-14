# MiraMR License System Documentation

## Overview

MiraMR uses a machine-bound license system with expiration dates to control access. Each license is:

- **Machine-specific**: Bound to a unique computer fingerprint
- **Time-limited**: Has an expiration date (default 1 year)
- **Secure**: Uses SHA-256 cryptographic signatures
- **Offline**: No internet connection required after activation

---

## For Users

### Step 1: Get Your Machine ID

```r
# Install MiraMR (without loading)
devtools::install_github("mtmmu88/MiraMR")

# Get your machine ID
MiraMR::mira_get_machine_id()
```

This will display your unique machine ID like:
```
=== MiraMR License Request ===

Your Machine ID:
=====================================
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2
=====================================
```

### Step 2: Request a License

Email the following to **mtmmu88@gmail.com**:

```
Subject: MiraMR License Request

Name: [Your Full Name]
Email: [Your Email]
Affiliation: [Your Institution]
Machine ID: [paste the ID from Step 1]
Purpose: [Brief description of your research]
```

### Step 3: Activate Your License

You will receive a license key via email. Activate it with:

```r
MiraMR::mira_activate("your_license_key_here")
```

### Step 4: Use MiraMR

```r
library(MiraMR)

# The package is now ready to use!
mira_help()
```

### Check License Status

```r
MiraMR::mira_license_status()
```

### Deactivate License

If you need to transfer your license to another computer:

```r
MiraMR::mira_deactivate()
```

Then request a new license for the new machine.

---

## For Administrators (mtmmu88)

### Quick Start

1. Receive license request from user with their machine ID
2. Run the admin tool:

```r
source("admin_license_generator.R")
```

3. Select option 1 for single license
4. Enter user details
5. Copy the generated license key
6. Email it to the user

### Manual License Generation

```r
library(MiraMR)

# Generate a 1-year license
license_key <- mira_generate_license(
  user_name = "Dr. Zhang Wei",
  user_email = "zhangwei@university.edu",
  machine_id = "a1b2c3d4...",  # from user
  expiry_days = 365,
  notes = "Research license 2024"
)

# Copy and send to user
cat(license_key)
```

### Batch License Generation

Create a CSV file with columns: `name`, `email`, `machine_id`, `notes`

Example `users.csv`:
```csv
name,email,machine_id,notes
Dr. Wang,wang@edu.cn,abc123...,Lab Member 1
Dr. Li,li@edu.cn,def456...,Lab Member 2
Dr. Chen,chen@edu.cn,ghi789...,Lab Member 3
```

Then:

```r
source("admin_license_generator.R")
# Select option 2 and provide the CSV file path
```

### License Duration Presets

```r
# 1 year (default)
expiry_days = 365

# 6 months
expiry_days = 180

# 2 years
expiry_days = 730

# Permanent (100 years)
expiry_days = 36500
```

### Custom License Parameters

```r
# Short-term trial license (30 days)
trial_license <- mira_generate_license(
  user_name = "Trial User",
  user_email = "trial@email.com",
  machine_id = "xyz789...",
  expiry_days = 30,
  notes = "Trial license - expires in 30 days"
)

# Long-term collaborator (5 years)
longterm_license <- mira_generate_license(
  user_name = "Collaborator",
  user_email = "collab@institute.edu",
  machine_id = "lmn456...",
  expiry_days = 1825,
  notes = "Long-term collaboration license"
)
```

---

## Technical Details

### Machine Fingerprint

The machine ID is generated from:
- Computer hostname
- Machine architecture
- Operating system
- Username

Combined and hashed with SHA-256.

### License Key Format

License keys are Base64-encoded JSON containing:
```json
{
  "user_name": "User Name",
  "user_email": "email@domain.com",
  "machine_id": "machine_fingerprint_hash",
  "issue_date": "2024-01-01",
  "expiry_date": "2025-01-01",
  "notes": "Optional notes",
  "version": "1.0.0",
  "signature": "cryptographic_signature"
}
```

### Security Features

1. **Cryptographic Signature**: Each license is signed with a secret key
2. **Machine Binding**: License only works on the authorized machine
3. **Expiration Check**: Validated on every package load
4. **Tamper Detection**: Any modification invalidates the license

### Secret Key

The secret key is hardcoded in `R/mira_license.R`:
```r
secret_key <- "MiraMR_2024_Candice_Mira_Secret_Key_Do_Not_Share"
```

**⚠️ IMPORTANT**: Never share or commit this key publicly!

---

## Troubleshooting

### User Cannot Activate License

**Problem**: "License key is not valid for this machine"

**Solution**:
- User may have sent wrong machine ID
- Ask user to run `mira_get_machine_id()` again
- Generate new license with correct machine ID

### License Expired

**Problem**: "License has expired"

**Solution**:
- Generate new license with extended expiry
- User activates new license (overwrites old one)

### Lost License Key

**Solution**:
- Regenerate license using same parameters
- Machine ID should be the same
- Send new key to user

### Multiple Machines

**Solution**:
- Each machine needs its own license
- User runs `mira_get_machine_id()` on each machine
- Generate separate license for each machine ID

---

## Best Practices

### For Users

1. **Save your license key** in a safe place
2. **Check license status** before starting important work
3. **Request renewal** before expiration
4. **One license per machine** - cannot share between computers

### For Administrators

1. **Keep records** of issued licenses (use tracking CSV)
2. **Set reasonable expiry** dates (1 year recommended)
3. **Backup the secret key** securely
4. **Document special cases** in the notes field
5. **Response time**: Aim to issue licenses within 24-48 hours

---

## Email Templates

### For Users - License Request Email

```
Subject: MiraMR License Request

Dear mtmmu88,

I would like to request a license for MiraMR.

Name: Zhang Wei
Email: zhangwei@university.edu
Affiliation: Department of Epidemiology, XX University
Machine ID: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2

Research Purpose:
I am conducting Mendelian Randomization analysis for my research on
cardiovascular disease genetics. I plan to use MiraMR for...

Thank you for your consideration.

Best regards,
Zhang Wei
```

### For Administrators - License Response Email

```
Subject: Re: MiraMR License Request

Dear Dr. Zhang,

Thank you for your interest in MiraMR!

Your license has been approved. Please find your license key below:

LICENSE KEY:
=====================================
[paste the generated license key here]
=====================================

ACTIVATION INSTRUCTIONS:

1. Open R/RStudio
2. Run the following command:
   MiraMR::mira_activate("paste_your_license_key_here")

3. Load the package:
   library(MiraMR)

LICENSE DETAILS:
- Valid until: [expiry date]
- Bound to machine ID: [first 16 chars]...

If you encounter any issues during activation, please let me know.

For technical support or questions:
Email: mtmmu88@gmail.com
GitHub: https://github.com/mtmmu88/MiraMR

Best regards,
mtmmu88
```

---

## File Structure

```
MiraMR/
├── R/
│   ├── mira_license.R          # License system functions
│   └── zzz.R                    # Package load hooks
├── admin_license_generator.R   # Admin tool (DO NOT distribute)
├── LICENSE_SYSTEM_README.md    # This file
└── .gitignore                   # Ensure admin_license_generator.R is ignored
```

---

## Security Considerations

1. **Never commit** `admin_license_generator.R` to public repository
2. **Keep secret key** confidential
3. **Use HTTPS** when emailing license keys
4. **Validate** user affiliations for academic use
5. **Monitor** for license key sharing (users shouldn't share keys)

---

## Future Enhancements

Potential improvements:

- [ ] Online license validation system
- [ ] Automatic renewal notifications
- [ ] Usage analytics (ethical, privacy-preserving)
- [ ] Multi-machine licenses for lab groups
- [ ] Enterprise/commercial licensing tier

---

## License Tracking Template

Create `license_tracking.csv` to keep records:

```csv
GeneratedDate,UserName,UserEmail,MachineID,ExpiryDate,Notes,Status
2024-01-15,Dr. Wang,wang@edu.cn,a1b2c3d4...,2025-01-15,Research license,Active
2024-01-20,Dr. Li,li@edu.cn,d4e5f6g7...,2025-01-20,Postdoc license,Active
2024-02-01,Dr. Chen,chen@edu.cn,g7h8i9j0...,2024-08-01,Trial license,Expired
```

---

## Support

For questions about the license system:
- **Email**: mtmmu88@gmail.com
- **GitHub Issues**: https://github.com/mtmmu88/MiraMR/issues

---

*Last updated: 2024*
*MiraMR License System v1.0*
