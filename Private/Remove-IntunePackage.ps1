function Remove-IntunePackage {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageName
    )
    try {
        $Applicationlist = (Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps" -Headers $script:GraphHeader -Method get -ContentType "application/json").value | where-object { $_.DisplayName -eq $Packagename }
    }
    catch {
        throw "Error: Could not connect to API to retrieve current packages: $($_.Exception.Message)"
    } 

    foreach ($Application in $applicationlist) {
        write-verbose "Removing application $($application.name)"
        (Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$($Application.id)" -Headers $script:GraphHeader -Method DELETE -ContentType "application/json")

    }
}