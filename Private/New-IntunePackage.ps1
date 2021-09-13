function New-IntunePackage {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageName,
        
        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageVersion,
        
        [parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageInstallCmd,

        [parameter(Position = 3, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageUninstallCmd,

        [parameter(Position = 4, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageDetectionPath,

        [parameter(Position = 4, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageDetectionFile,

        [parameter(Position = 5, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$TenantID,

        [parameter(Position = 5, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$InstallerPath


    )
    Write-Verbose "Getting prerequisites $TenantID"
    try {
        Get-Prerequisites
    }
    catch {
        throw "Failed to download stuff: $($_.Exception.Message)"
    }

    try {
        Connect-graphAPI -TenantID $tenantid
    }
    catch {
        throw "Failed to log into Graph API: $($_.Exception.Message)"
    }
    Write-Verbose "Creating new intune package for $TenantID"
    write-verbose "Creating intune package in Endpoint Manager, if $($PackageNames) does not exist"
    try {
        $ApplicationList = (Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps" -Headers $script:GraphHeader -Method get -ContentType "application/json")
        if ($ApplicationList.value) { $applicationlist = $ApplicationList.value }
    }
    catch {
        throw "Error: Could not connect to API to retrieve current packages: $($_.Exception.Message)"
    } 
    
    if ($ApplicationList | where-object { $_.DisplayName -eq $Packagename }) {
        write-output "The package $($PackageName) already exists, We are removing the existing application."
        Remove-IntunePackage -Packagename $PackageName
    }

    write-verbose "Creating new intunewin package for $($PackageName)"
    $IntuneWinPath = New-IntunewinPackage -InstallerPath $InstallerPath
    write-verbose "Collecting encryption information for $($PackageName)"
    $EncryptionInfo = Get-IntunewinEncryptioninfo -package $IntuneWinPath
    Write-Verbose "Setting application template file."
    $intuneBody = (get-content "$PSScriptRoot\AppTemplate.json") | ConvertFrom-Json
    $intuneBody.DisplayName = $PackageName
    $intuneBody.installcommandline = $PackageInstallCmd
    $intuneBody.uninstallCommandLine = $PackageUnInstallCmd
    $intuneBody.detectionrules[0].path = $PackageDetectionPath
    $intuneBody.detectionRules[0].fileorfoldername = $PackageDetectionFile
    Write-Verbose "Sending package to endpoint manager."
    Send-Intunepackage -package $IntuneWinPath -encryptioninfo $EncryptionInfo -intunebody ($intunebody | ConvertTo-Json)
}