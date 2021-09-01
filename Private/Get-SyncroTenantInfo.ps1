function Get-SyncroTenantInfo {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$URL,
        
        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$Key,

        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$VariableName

    )

    if (!$VariableName) { $VariableName = 'O365Tenant' }

    Write-Verbose "Setting login information for Syncro API"
    $headers = @{ 'Authorization' = "Bearer $($key)" }
    $page = 1
    Write-Verbose "    Getting all sites from Syncro API"
    $results = do {
        $Response = Invoke-RestMethod -Method GET -Headers $headers -uri "$($url)/api/v1/customers?page=$page"
        if ($Response) {
            if ($Response.meta.totalpages -ne $page) { $page++ }
            $Response.customers
            
        }
    }
    until ($page -ne $Response.meta.totalpages)

    Write-Verbose "Getting tenant information from Syncro API"
    $SyncroSites = foreach ($Site in $results) {
        [PSCustomObject]@{
            Name     = $site.Business_Name
            tenantid = $site.properties.$VariableName
            id       = $site.id
        }
    }
    Write-Verbose "    Collected $(($SyncroSites  | Where-Object -Property TenantID -ne $null).count) sites in Syncro API."
    return $SyncroSites | Where-Object -Property TenantID -ne $null
}