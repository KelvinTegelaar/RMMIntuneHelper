function Connect-graphAPI {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$ApplicationId,
        
        [parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$ApplicationSecret,
        
        [parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$TenantID,

        [parameter(Position = 3, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$RefreshToken

    )
    Write-Verbose "Removing old token if it exists"
    $Script:GraphHeader = $null
    Write-Verbose "Logging into Graph API"
    try {
        if ($ApplicationId) {
            Write-Verbose "   using the entered credentials"
            $script:ApplicationId = $ApplicationId
            $script:ApplicationSecret = $ApplicationSecret
            $script:RefreshToken = $RefreshToken
            $AuthBody = @{
                client_id     = $ApplicationId
                client_secret = $ApplicationSecret
                scope         = 'https://graph.microsoft.com/.default'
                refresh_token = $RefreshToken
                grant_type    = "refresh_token"
               
            }
            
        }
        else {
            Write-Verbose "   using the cached credentials"
            $AuthBody = @{
                client_id     = $script:ApplicationId
                client_secret = $Script:ApplicationSecret
                scope         = 'https://graph.microsoft.com/.default'
                refresh_token = $script:RefreshToken
                grant_type    = "refresh_token"
               
            }
        }
        $AccessToken = (Invoke-RestMethod -Method post -Uri "https://login.microsoftonline.com/$($tenantid)/oauth2/v2.0/token" -Body $Authbody -ErrorAction Stop).access_token

        $Script:GraphHeader = @{ Authorization = "Bearer $($AccessToken)" }
    }
    catch {
        write-error "Could not log into the Graph API for tenant $($TenantID): $($_.Exception.Message)"
    }

}