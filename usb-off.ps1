# Run as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Exit
}

# Function to disable or enable USB ports
function Set-USBPortsStatus {
    param (
        [bool]$Enabled
    )

    $usbControllers = Get-WmiObject Win32_PnPEntity | Where-Object { $_.PNPClass -eq 'USB' -and $_.ConfigManagerErrorCode -ne 0 }
    $action = if ($Enabled) { 'Enable' } else { 'Disable' }

    foreach ($usbController in $usbControllers) {
        $method = $usbController.GetMethodParameters($action)
        $usbController.InvokeMethod($action, $method, $null)
    }
}

# Disable USB ports
Set-USBPortsStatus -Enabled $false