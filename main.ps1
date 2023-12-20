# --- Source Environment Variables
$vCenterUsername = $env:VCENTER_USERNAME
$vCenterPassword = $env:VCENTER_PASSWORD
$vCenterServer = $env:VCENTER_SERVER
$VMNames = $env:IMAGE_NAMES

Write-Host "PSModulePath: " $env:PSModulePath

# --- Authenticate to vCenter and Delete VM
Connect-VIserver $vCenterServer -User $vCenterUsername -Password $vCenterPassword

foreach ($VMName in $VMNames) {
  # --- Check view to see if image is a Template or Virtual Machine
  $VMView = Get-View -ViewType VirtualMachine -Filter @{"Name" = $VMName } 

  # --- Cleanup image
  switch ($VMView.Config.Template) {
    $false {
      try {
        Get-VM -Name $VMName | Remove-VM -DeletePermanently -Confirm:$false -ErrorAction Stop
      }
      catch {
        Write-Host "Error removing VM: $_"
      }
    }
    $true {
      try {
        Get-Template -Name $VMName | Remove-Template -DeletePermanently -Confirm:$false -ErrorAction Stop
      }
      catch {
        Write-Host "Error removing Template: $_"
      }
    }
    Default {
      "No matching images found."
    }
  }
}