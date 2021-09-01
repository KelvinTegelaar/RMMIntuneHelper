function New-DrmmApiAccessToken {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$URL,
        
        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$Key,
        
        [parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$SecretKey
    )

    $params = @{
        Credential  = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('public-client', ('public' | ConvertTo-SecureString -AsPlainText -Force))
        Uri         = '{0}/auth/oauth/token' -f $Url
        Method      = 'POST'
        ContentType = 'application/x-www-form-urlencoded'
        Body        = 'grant_type=password&username={0}&password={1}' -f $Key, $SecretKey
    }
	
    # Request access token
    try {
        return (Invoke-RestMethod @params).access_token

    }
    catch {
        throw $_.Exception.Message
    }

}