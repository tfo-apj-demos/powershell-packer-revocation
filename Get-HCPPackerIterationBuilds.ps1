function Get-HCPPackerIterationBuilds {
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
    [String]$BucketSlug,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$IterationId
  )

  # class Build {
  #   [string] $Id 
  #   [string] $IterationId
  #   [string] $ComponentType
  #   [string] $PackerRunUUID
  #   []Images
  #}

  try {
    $URI="/packer/2021-04-30/organizations/$OrgId/projects/$ProjectId/images/$BucketSlug/iterations/$IterationId/builds"
    $Response = Invoke-HCPRestMethod -URI $URI -Method GET

    Write-Host "Number of builds retrieved: $($Response.builds.Count)" # Logging `$Response.builds` Information

    foreach ($Build in $Response.builds) {
      Write-Host "Build ID: $($Build.id), Status: $($Build.status), Created At: $($Build.created_at)" # Logging `$Build` Information
      [PSCustomObject] @{
        Id = $Build.id 
        IterationId = $Build.iteration_id
        ComponentType = $Build.component_type
        PackerRunUUID = $Build.packer_run_uuid
        Images = foreach ($Image in $Build.images) {
          [PSCustomObject]@{
            Id = $Image.id 
            ImageId = $Image.image_id 
            Region = $Image.region 
            CreatedAt = $Image.created_at 
          }
        }
        CloudProvider = $Build.cloud_provider
        Status = $Build.status
        CreatedAt = $Build.created_at
        UpdatedAt = $Build.updated_at
        SourceImageId = $Build.source_image_id
      }
    }
  }
  catch [Exception]{
      Write-Host "Error occurred while retrieving builds: $_"
      throw
  }
}