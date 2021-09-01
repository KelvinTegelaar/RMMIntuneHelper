#not in use yet
function New-GraphRequest {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$Uri,
        
        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$Method,

        [parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$Body
    )
    if ($Method -eq "GET") {
        $nextURL = $uri
        $ReturnedData = do {
            $Data = (Invoke-RestMethod -Uri $nextURL -Method GET -Headers $Script:GraphHeader)
            if ($data.value) { $data.value } else { ($Data) }
            $nextURL = $data.'@odata.nextLink'
        } until ($null -eq $NextURL)
        return $ReturnedData   
    }
    else {
        $ReturnedData = (Invoke-RestMethod -Uri $nextURL -Method $Method -UseBasicParsing -Body $Body -Headers $Script:GraphHeader)
    }


}