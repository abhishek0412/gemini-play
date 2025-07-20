# Azure AD Conditional Access Policy for MFA
resource "azuread_conditional_access_policy" "mfa_policy" {
  display_name = "Require MFA for all users"
  state        = "enabled"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["all"]
      excluded_applications = []
    }

    users {
      included_users  = ["all"]
      excluded_users  = [] # Add service accounts or break-glass accounts here
      excluded_groups = []
    }

    platforms {
      included_platforms = ["all"]
      excluded_platforms = []
    }

    locations {
      included_locations = ["all"]
      excluded_locations = ["AllTrusted"]
    }
  }

  grant_controls {
    operator = "AND"
    built_in_controls = ["mfa"]
  }

  session_controls {
    sign_in_frequency = 24
    sign_in_frequency_period = "hours"
    persistent_browser_mode = "never"
  }
}

# Azure AD Security Defaults (as backup)
resource "azuread_directory_setting" "security_defaults" {
  display_name = "Security Defaults"
  template_id  = "00000000-0000-0000-0000-000000000000"

  values = [
    {
      name  = "enableSecurityDefaults"
      value = "true"
    }
  ]
}