# Set-NetworkAdapterState.ps1
# Purpose:  Disable and re-enable a network adapter, specifically for wireless / wifi.
# Requires: PowerShell, Administrator privileges
# Usage:    Set-NetworkAdapterState ([state])
#           Set-NetworkAdapterState (restart|off|stop|on|start)
# Examples: 
#   Set-NetworkAdapterState
#   Set-NetworkAdapterState on
#   Set-NetworkAdapterState off
#   Set-NetworkAdapterState restart

param(
	[string] $State = "restart"
	, [switch] $NoDelay
)

$name = "Wi-Fi"
$adapter = Get-NetAdapter -Name $name -ErrorAction SilentlyContinue
$secondsToWait = 5

if (!$adapter) {
	Write-Output "Adapter not found: '$($name)'"
	Write-Output "Searching for 'wireless' in the interface descriptions...."

	$adapters = Get-NetAdapter -ErrorAction SilentlyContinue
	$adapter = $adapters.Where( { $_.InterfaceDescription -like "*wireless*" } ) | Select-Object -first 1

	if ($adapter) {
		Write-Output "Found adapter: '$($adapter.Name)'.... w00t!"
	}

	Write-Output ""
}

if ($adapter) {	
	Write-Output "$($adapter.Name) status was '$($adapter.Status)'"
	Write-Output "Desired state: '$State'"
	Write-Output ""

	if ($State -like "off" -or $State -like "stop" -or $State -like "restart") {
		Write-Output "Disabling now...."
		Disable-NetAdapter -Name $adapter.Name -Confirm:$false
	} 
	
	if ($State -like "on" -or $State -like "start" -or $State -like "restart") {
		Write-Output "Enabling now...."
		Enable-NetAdapter -Name $adapter.Name -Confirm:$false
	}

	Start-Sleep -Seconds $secondsToWait

	$adapter = Get-NetAdapter -Name $adapter.Name -ErrorAction SilentlyContinue

	Write-Output ""
	Write-Output "$($adapter.Name) status is now '$($adapter.Status)'"
}
else {
	Write-Output "Adapter not found: '$name''"
}

Write-Output ""
Write-Output "Done"
Write-Output ""

if (!$NoDelay) {
	Write-Output "Exiting in $secondsToWait seconds...."
	Start-Sleep -Seconds $secondsToWait
}