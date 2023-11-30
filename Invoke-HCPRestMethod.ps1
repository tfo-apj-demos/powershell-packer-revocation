function Invoke-HCPRestMethod {
  <#
      .SYNOPSIS
      Wrapper for Invoke-RestMethod/Invoke-WebRequest with HCP specifics
  
      .DESCRIPTION
      Wrapper for Invoke-RestMethod/Invoke-WebRequest with HCP specifics
  
      .PARAMETER Method
      REST Method:
      Supported Methods: GET, POST, PUT,DELETE
  
      .PARAMETER URI
      API URI, e.g. /packer/2021-04-30/organizations/$OrgId/projects/$ProjectId/images/$BucketSlug/iterations
  
      .PARAMETER Headers
      Optionally supply custom headers
  
      .PARAMETER Body
      REST Body in JSON format
  
      .PARAMETER OutFile
      Save the results to a file
  
      .PARAMETER WebRequest
      Use Invoke-WebRequest rather than the default Invoke-RestMethod
  
      .INPUTS
      System.String
      Switch
  
      .OUTPUTS
      System.Management.Automation.PSObject
  
      .EXAMPLE
      Invoke-HCP RestMethod -Method GET -URI '"/packer/2021-04-30/organizations/12345/projects/6789/images/$BucketSlug/iterations"'

  #>
  [CmdletBinding(DefaultParameterSetName="Standard")][OutputType('System.Management.Automation.PSObject')]
  
      Param (
  
          [Parameter(Mandatory=$true, ParameterSetName="Standard")]
          [Parameter(Mandatory=$true, ParameterSetName="Body")]
          [Parameter(Mandatory=$true, ParameterSetName="OutFile")]
          [ValidateSet("GET","POST","PUT","DELETE")]
          [String]$Method,
  
          [Parameter(Mandatory=$true, ParameterSetName="Standard")]
          [Parameter(Mandatory=$true, ParameterSetName="Body")]
          [Parameter(Mandatory=$true, ParameterSetName="OutFile")]
          [ValidateNotNullOrEmpty()]
          [String]$URI,
  
          [Parameter(Mandatory=$false, ParameterSetName="Standard")]
          [Parameter(Mandatory=$false, ParameterSetName="Body")]
          [Parameter(Mandatory=$false, ParameterSetName="OutFile")]
          [ValidateNotNullOrEmpty()]
          [System.Collections.IDictionary]$Headers,
  
          [Parameter(Mandatory=$false, ParameterSetName="Body")]
          [ValidateNotNullOrEmpty()]
          [String]$Body,
  
          [Parameter(Mandatory=$false, ParameterSetName="OutFile")]
          [ValidateNotNullOrEmpty()]
          [String]$OutFile,
  
          [Parameter(Mandatory=$false, ParameterSetName="Standard")]
          [Parameter(Mandatory=$false, ParameterSetName="Body")]
          [Parameter(Mandatory=$false, ParameterSetName="OutFile")]
          [Switch]$WebRequest
      )
  
      # --- Test for existing connection to HCP
      if (-not $Global:HCPConnection){
  
          throw "HCP Connection variable does not exist. Please run Connect-HCP"
      }
  
      # --- Create Invoke-RestMethod Parameters
      $FullURI = "$($Global:HCPConnection.ApiPrefix)$($URI)"
  
      # --- Add default headers if not passed
      if (!$PSBoundParameters.ContainsKey("Headers")){
  
          $Headers = @{
              "Accept"="application/json";
              "Content-Type" = "application/json";
              "Authorization" = "Bearer $($Global:HCPConnection.Token)";
          }
      }
  
      # --- Set up default parmaeters
      $Params = @{
  
          Method = $Method
          Headers = $Headers
          Uri = $FullURI
      }
  
      if ($PSBoundParameters.ContainsKey("Body")) {
  
          $Params.Add("Body", $Body)
  
          # --- Log the payload being sent to the server
          Write-Debug -Message $Body
  
      } elseif ($PSBoundParameters.ContainsKey("OutFile")) {
  
          $Params.Add("OutFile", $OutFile)
  
      }
  
      try {
  
          # --- Use either Invoke-WebRequest or Invoke-RestMethod
          if ($PSBoundParameters.ContainsKey("WebRequest")) {
  
              Invoke-WebRequest @Params
          }
          else {
  
              Invoke-RestMethod @Params
          }
      }
      catch {

          throw $_
      }
  }