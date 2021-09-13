function New-GenericApplication {
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

        [parameter(Position = 5, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageDetectionFile,

        [parameter(Position = 6, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][bool]$AssignToAllDevices,

        [parameter(Position = 7, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$InstallerPath,

        [parameter(Position = 8, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$ApplicationId,

        [parameter(Position = 9, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$ApplicationSecret,

        [parameter(Position = 10, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$YourTenantID,

        [parameter(Position = 11, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$refreshtoken
    )
    Write-Verbose "Getting a list of all tenants"
    Connect-GraphAPI -ApplicationId $ApplicationId -ApplicationSecret $ApplicationSecret -Tenantid $YourTenantID -RefreshToken $refreshtoken
    #Need to setup pagination here, not all tenants included if over 999
    $Tenants = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/contracts?`$top=999" -Method GET -Headers $script:GraphHeader).value
    foreach ($Tenant in $Tenants) {
        write-verbose "Starting process for tenant $($tenant.defaultdomainname)"
        try {
            $params = @{
                packagename          = $PackageName
                packageversion       = $PackageVersion
                packageinstallcmd    = $PackageInstallCmd
                packageuninstallcmd  = $PackageUninstallCmd
                packagedetectionpath = $PackageDetectionpath
                packagedetectionfile = $PackageDetectionfile
                InstallerPath        = $InstallerPath
                TenantID             = $Tenant.customerid
            }
            $NewPackage = New-IntunePackage @Params | Select-Object -last 1
            write-verbose "Assigning package"
            if ($AssignToAllDevices) { 
                write-verbose "Assigning Package $($NewPackage) to all devices, using type $($NewPackage.gettype())"
                Set-IntunePackageAssign -PackageID $NewPackage 
            }
        }
        catch {
            write-error "Failed for tenant $($tenant.defaultdomainname): $($_.Exception.Message)"
            continue
        }
    }
}