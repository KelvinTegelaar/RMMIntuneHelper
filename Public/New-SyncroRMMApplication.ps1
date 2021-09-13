function New-SyncroRMMApplication {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$SyncroURL,
        
        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$SyncroAPIKey,
        
        [parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$SyncroPolicyID,

        [parameter(Position = 3, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$SyncroInstallerURL,

        [parameter(Position = 4, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$ApplicationId,

        [parameter(Position = 5, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$ApplicationSecret,

        [parameter(Position = 6, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$YourTenantID,

        [parameter(Position = 7, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$refreshtoken,

        [parameter(Position = 8, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][bool]$AssignToAllDevices,

        [parameter(Position = 9, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$PackageName,
        
        [parameter(Position = 10, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$SyncroTenantVariable

    )
    Write-Verbose "Connecting to the Graph API for processing all clients"
    Connect-GraphAPI -ApplicationId $ApplicationId -ApplicationSecret $ApplicationSecret -Tenantid $YourTenantID -RefreshToken $refreshtoken
    Write-Verbose "Connecting to DRMM to get all tenants using tenant variable $SyncroTenantVariablee"
    $Tenants = Get-SyncroTenantInfo -URL $SyncroURL -key $SyncroAPIKey -VariableName $SyncroTenantVariable
    foreach ($Tenant in $Tenants) {
        write-verbose "Starting process for tenant $($tenant.name)"
        try {
            write-verbose "Downloading client for $($tenant.name) / $($tenant.tenantid)"
            #need to actually add the downloading of the agent.
            $null = New-item -ItemType Directory "$ENV:Temp\$($tenant.id)" -ErrorAction SilentlyContinue
            (New-Object System.Net.WebClient).DownloadFile("$($SyncroinstallerURL)", "$ENV:Temp\$($tenant.id)\SyncroSetup.exe")
            $params = @{
                packagename          = $PackageName
                packageversion       = '1.0'
                packageinstallcmd    = "SyncroSetup.exe --console --customerid $($tenant.id) --policyid $SyncroPolicyID"
                packageuninstallcmd  = "SyncroSetup.exe /X"
                packagedetectionpath = "C:\Program Files\RepairTech\Syncro"
                packagedetectionfile = "Update.exe"
                InstallerPath        = "$ENV:Temp\$($tenant.id)\SyncroSetup.exe"
                TenantID             = $Tenant.tenantid
            }
            write-verbose "Starting to create package for $($tenant.name)"
            $NewPackage = New-IntunePackage @Params
            if ($AssignToAllDevices) { Set-IntunePackageAssign -PackageID $NewPackage }
            $Cleanup = Get-ChildItem "$ENV:Temp\$($tenant.id)" | Remove-Item -Force
        }
        catch {
            write-error "Failed for tenant $($tenant.name): $($_.Exception.Message)"
        }

    }
}