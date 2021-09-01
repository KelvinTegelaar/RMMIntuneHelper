function New-AutomateApplication {
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
        [ValidateNotNullOrEmpty()][String]$IntuneWinPath,

        [parameter(Position = 5, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][bool]$OverwriteExisting

    )
    Write-Verbose "Getting a list of all tenants"
    Connect-GraphAPI -ApplicationId $ApplicationId -ApplicationSecret $ApplicationSecret -Tenantid $TenantID
    $Tenants = New-GraphRequest -resource "contracts"
    foreach ($Tenant in $Tenants) {
        try {
            Connect-GraphAPI -Tenantid $TenantID
            $params = @{
                packagename           = $PackageName 
                packageversion        = $PackageVersion
                packageinstallcmd     = $PackageInstallCmd 
                packageuninstallcmd   = $PackageUninstallCmd 
                packaagedetectionpath = $PackageDetectionPath 
                packagedetectionfile  = $PackageDetectionFile
            }
            New-IntunePackage @Params
        }
        catch {
            write-error "Failed for tenant $($tenant.defaultdomainname). Moving onto next client."
        }
    }
}