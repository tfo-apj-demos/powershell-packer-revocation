function Get-HCPPackerIterations {
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
[CmdletBinding()][OutputType('System.Management.Automation.PSObject')]

Param (

  [parameter(Mandatory=$false)]
  [ValidateNotNullOrEmpty()]
  [String]$OrgId = $Global:HCPConnection.OrgId,

  [parameter(Mandatory=$false)]
  [ValidateNotNullOrEmpty()]
  [String]$ProjectId = $Global:HCPConnection.ProjectId,

  [parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [String]$BucketSlug
)

try {
  $URI="/packer/2021-04-30/organizations/$OrgId/projects/$ProjectId/images/$BucketSlug/iterations"
  $Response = Invoke-HCPRestMethod -URI $URI -Method GET

  foreach ($Iteration in $Response.iterations) {
    [PSCustomObject] @{
      Id = $Iteration.id 
      BucketSlug = $Iteration.bucket_slug
      IterationAncestorId = $Iteration.iteration_ancestor_id
      IncrementalVersion = $Iteration.incremental_version
      Complete = $Iteration.complete
      AuthorId = $Iteration.author_id
      CreatedAt = $Iteration.created_at
      UpdatedAt = $Iteration.updated_at
      Fingerprint = $Iteration.fingerprint
      BuildStatuses = $Iteration.build_statuses
      RevokeAt = $Iteration.revoke_at
      RevocationMessage = $Iteration.revocation_message
      RevocationAuthor = $Iteration.revocation_author
      RevocationType = $Iteration.revocation_type
      RevocationInheritedFrom = $Iteration.revocation_inherited_from
      HasDescendants = $Iteration.has_descendants
    }
  }

}
catch [Exception]{

    throw
}
}
