function New-DattoRMMApplication {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$DattoURL,
        
        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$DattoKey,
        
        [parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$DattoSecretKey,

        [parameter(Position = 3, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$ApplicationId,

        [parameter(Position = 4, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$ApplicationSecret,

        [parameter(Position = 5, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$YourTenantID,

        [parameter(Position = 6, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$refreshtoken,

        [parameter(Position = 7, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][bool]$AssignToAllDevices,

        [parameter(Position = 8, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$PackageName,
        
        [parameter(Position = 9, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][string]$DattoTenantVariable

    )
    Write-Verbose "Connecting to the Graph API for processing all clients"
    Connect-GraphAPI -ApplicationId $ApplicationId -ApplicationSecret $ApplicationSecret -Tenantid $YourTenantID -RefreshToken $refreshtoken
    Write-Verbose "Connecting to DRMM to get all tenants using tenant variable $DattoTenantVariable"
    $Tenants = Get-DRMMTenantInfo -URL $DattoURL -key $DattoKey -SecretKey $DattoSecretKey -VariableName $DattoTenantVariable
    foreach ($Tenant in $Tenants) {
        write-verbose "Starting process for tenant $($tenant.name)"
        try {
            write-verbose "Downloading client for $($tenant.name) / $($tenant.tenantid)"
            $null = New-item -ItemType Directory "$ENV:Temp\$($tenant.uid)" -ErrorAction SilentlyContinue
            (New-Object System.Net.WebClient).DownloadFile("https://pinotage.centrastage.net/csm/profile/downloadAgent/$($tenant.uid)", "$ENV:Temp\$($tenant.uid)\AgentInstall.exe")
            $params = @{
                packagename          = $PackageName
                packageversion       = '1.0'
                packageinstallcmd    = "AgentInstall.exe /PROF $($tenant.uid)"
                packageuninstallcmd  = "C:\Program Files (x86)\CentraStage\uninst.exe /S"
                packagedetectionpath = "C:\Programdata\CentraStage\AEMAgent"
                packagedetectionfile = "AEMAgent.exe"
                InstallerPath        = "$ENV:Temp\$($tenant.uid)\AgentInstall.exe"
                TenantID             = $Tenant.tenantid
            }
            write-verbose "Starting to create package for $($tenant.name)"
            $NewPackage = New-IntunePackage @Params | Select-Object -last 1
            write-verbose "Assigning Package $($NewPackage) to all devices, using type $($NewPackage.gettype())"
            if ($AssignToAllDevices) { Set-IntunePackageAssign -PackageID $NewPackage }
            $Cleanup = Get-ChildItem "$ENV:Temp\$($tenant.uid)" | Remove-Item -Force
        }
        catch {
            write-error "Failed for tenant $($tenant.name): $($_.Exception.Message)"
        }

    }
}