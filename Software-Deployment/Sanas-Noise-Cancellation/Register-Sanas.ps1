# Script: Automated License Injection for Sanas
# Description: Dynamically locates the installation path across architectures and injects the license key.
# Author: Leonardo Mejia

$ErrorActionPreference = "Continue"

# CONFIGURATION
# Note: License Key has been sanitized for repository security.
$KeyName   = "InstallerId"
$KeyValue  = "XXXX-XXXX-XXXX-XXXX" 
$Signature = "AppExecPath" # Validation key to confirm install path

# 1. INSTALLER SYNCHRONIZATION
# Buffer time to allow the installer to complete registry write operations.
Write-Output "Waiting for installation synchronization..."
Start-Sleep -Seconds 20

# 2. REGISTRY DISCOVERY
# Scan both x64 and x86 hives to handle dynamic installation paths.
Write-Output "Scanning registry for valid installation path..."

$SearchPaths = @("HKLM:\SOFTWARE", "HKLM:\SOFTWARE\WOW6432Node")
$RealKeyPath = $null

foreach ($Root in $SearchPaths) {
    # Filter for Sanas-related keys
    $Candidates = Get-ChildItem -Path $Root -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -like "Sanas*" }
    
    foreach ($Folder in $Candidates) {
        # Check root folder validity
        $Prop = Get-ItemProperty -Path $Folder.PSPath -Name $Signature -ErrorAction SilentlyContinue
        if ($Prop) {
            $RealKeyPath = $Folder.PSPath
            break
        }
        
        # Check sub-directories (e.g., Sanas.ia\Sanas structure)
        $SubFolders = Get-ChildItem -Path $Folder.PSPath -ErrorAction SilentlyContinue
        foreach ($Sub in $SubFolders) {
            $SubProp = Get-ItemProperty -Path $Sub.PSPath -Name $Signature -ErrorAction SilentlyContinue
            if ($SubProp) {
                $RealKeyPath = $Sub.PSPath
                break
            }
        }
        if ($RealKeyPath) { break }
    }
    if ($RealKeyPath) { break }
}

# 3. LICENSE APPLICATION

if ($RealKeyPath) {
    Write-Output "Target found at: $RealKeyPath"
    Write-Output "Injecting license key..."
    
    New-ItemProperty -Path $RealKeyPath -Name $KeyName -Value $KeyValue -PropertyType String -Force | Out-Null
    
    Write-Output "SUCCESS: License activated."
}
else {
    # Fallback: Attempt injection on default legacy path
    Write-Output "WARNING: Dynamic path not found. Attempting fallback..."
    $FallbackPath = "HKLM:\SOFTWARE\Sanas.ia\Sanas"
    
    if (!(Test-Path $FallbackPath)) { New-Item -Path $FallbackPath -Force | Out-Null }
    New-ItemProperty -Path $FallbackPath -Name $KeyName -Value $KeyValue -PropertyType String -Force | Out-Null
}