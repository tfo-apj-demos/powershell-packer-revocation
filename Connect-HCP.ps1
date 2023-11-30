function Connect-HCP {
  <#
      .SYNOPSIS
      Authenticate to HashiCorp Cloud Platform (HCP).
  
      .DESCRIPTION
      Connect to HCP and generate a connection object with Token, Organisation, and Project details.
  
      .PARAMETER ClientId
      Service Principal Client ID to connect with.
  
      .PARAMETER ClientSecret
      Service Principal Client Secret to connect with.

      .PARAMETER OrgId
      HCP Organisation ID to work with.

      .PARAMETER ProjectId
      HCP Project ID to work with.
  
      .INPUTS
      System.String
      System.SecureString
      Switch
  
      .OUTPUTS
      System.Management.Automation.PSObject.
  
      .EXAMPLE
      $SecureClientSecret = ConvertTo-SecureString "_VAJ1XO3j4e53jeyycSida5_gXpys18t3w510F" -AsPlainText -Force
      Connect-HCP -ClientID "zmNZCMIe5nQF2k2KtZJlgmWpIsSQNSGSQ" -ClientSecret $SecureClientSecret
  #>
  [CmdletBinding(DefaultParametersetName="ServiceAccount")][OutputType('System.Management.Automation.PSObject')]
  
    Param (

        [parameter(Mandatory=$true,ParameterSetName="ServiceAccount")]
        [ValidateNotNullOrEmpty()]
        [String]$ClientId,

        [parameter(Mandatory=$true,ParameterSetName="ServiceAccount")]
        [ValidateNotNullOrEmpty()]
        [SecureString]$ClientSecret,

        [parameter(Mandatory=$false,ParameterSetName="ServiceAccount")]
        [ValidateNotNullOrEmpty()]
        [String]$OrgId,

        [parameter(Mandatory=$false,ParameterSetName="ServiceAccount")]
        [ValidateNotNullOrEmpty()]
        [String]$ProjectId

    )

    # --- Convert Secure Credentials to a format for sending in the JSON payload
    $JSONClientSecret = (New-Object System.Management.Automation.PSCredential("username", $ClientSecret)).GetNetworkCredential().Password

    try {

        # --- Create Invoke-RestMethod Parameters
        $Params = @{

            Method = "POST"
            URI = "https://auth.idp.hashicorp.com/oauth2/token"
            Headers = @{
            "Content-Type" = "application/x-www-form-urlencoded";
            }
            Body = @{
            "client_id"=$ClientID;
            "client_secret"=$JSONClientSecret;
            "grant_type"="client_credentials";
            "audience"="https://api.hashicorp.cloud"
            }

        }

        $Response = Invoke-RestMethod @Params

        # --- Create Output Object
        $Global:HCPConnection = [PSCustomObject] @{

            Token = $Response.access_token
            OrgId = $OrgId
            ProjectId = $ProjectId
            ApiPrefix = "https://api.cloud.hashicorp.com"
        }

    }
    catch [Exception]{

        throw

    }

    Write-Output $HCPConnection
  
  }
  