function Get-DRMMTenantInfo {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$URL,
        
        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$Key,
        
        [parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$SecretKey,

        [parameter(Position = 3, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$VariableName

    )

    if (!$VariableName) { $VariableName = 'O365Tenant' }
    Write-Verbose "Logging into DRMM API"
    try {
        $DRMMToken = New-DrmmAPIAccesstoken -URL $url -key $key -SecretKey $SecretKey
    }
    catch {
        throw "Could not login to DRMM API: $($_.Exception.Message)"
    }
    Write-Verbose "Setting login information for DRMM API"
    $headers = @{ 'Authorization' = "Bearer $($DRMMToken)" }
    $page = 0  
    Write-Verbose "    Getting all sites from DRMM API"
    $results = do {
        $Response = Invoke-RestMethod -Method GET -Headers $headers -uri "$($URL)/api/v2/account/sites?max=250&page=$page"
        if ($Response) {
            $nextPageUrl = $Response.pageDetails.nextPageUrl
            $Response.Sites
            $page++
        }
    }
    until ($null -eq $nextPageUrl)

    $Sites = $Results | Where-Object name -ne 'Deleted Devices'
    Write-Verbose "Getting tenant information from DRMM API"
    $DRMMSites = foreach ($Site in $Sites) {
        $TenantID = ((Invoke-RestMethod -Method get -Headers $headers -Uri "$($URL)/api/v2/site/$($site.uid)/variables" -verbose:$false).variables  | where-object -property name -eq $VariableName).value
        [PSCustomObject]@{
            Name     = $site.Name
            tenantid = $tenantid
            uid      = $site.uid
        }
    }
    Write-Verbose "    Collected $(($DRMMSites | Where-Object -Property TenantID -ne $null).count) sites in DRMM API."
    return $DRMMSites | Where-Object -Property TenantID -ne $null
}