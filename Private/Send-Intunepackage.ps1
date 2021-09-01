function Send-intunepackage {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$Package,
        
        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$IntuneBody,

        [parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][pscustomobject]$EncryptionInfo
    )
    $Baseuri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps"
    write-verbose "Creating $($Package) on intune platform"
    $InTuneProfileURI = "$($BaseURI)"
    Write-Verbose "Creating Intune Application"
    $NewApp = Invoke-RestMethod -Uri $InTuneProfileURI -Headers $Script:GraphHeader -body $intuneBody -Method POST -ContentType "application/json"
    $ContentBody = $EncryptionInfo | Select-Object Name, Size, sizeEncrypted | ConvertTo-Json
    Write-Verbose "Sending expected encrypted body size to Graph API: $ContentBody"
    $ContentReq = Invoke-RestMethod -Uri "$($BaseURI)/$($NewApp.id)/microsoft.graph.win32lobapp/contentVersions/1/files/" -Headers $script:GraphHeader -body $ContentBody -Method POST -ContentType "application/json"
    Write-Verbose "Trying to get file uri for $package"
    do {
        Write-Verbose "    Still trying to get file uri. Please wait."
        $AzFileUriCheck = "$($BaseURI)/$($NewApp.id)/microsoft.graph.win32lobapp/contentVersions/1/files/$($ContentReq.id)"
        $AzFileUri = Invoke-RestMethod -Uri $AzFileUriCheck -Headers $script:GraphHeader -Method get -ContentType "application/json"
        if ($AZfileuri.uploadState -like "*fail*") { break }
        start-sleep 5
    } while ($null -eq $AzFileUri.AzureStorageUri) 
    Write-Verbose "Retrieved upload URL. Uploading package $($package) via AzCopy."
    $InstallerDir = [System.IO.Path]::GetDirectoryName("$($InstallerPath)")
    $ExtactedEncFile = "$($InstallerDir)\$($EncryptionInfo.name)"
    write-host "Trying to upload $($ExtactedEncFile)"
    $UploadResults = & "$($ENV:Temp)\IntuneRMMHelper\azCopy.exe" cp "$($ExtactedEncFile)" "$($Azfileuri.AzureStorageUri)"  --block-size-mb 4 --output-type 'json'   
     
    $EncBody = $EncryptionInfo | Select-Object fileEncryptionInfo | ConvertTo-Json

    $CommitReq = Invoke-RestMethod -Uri "$($BaseURI)/$($NewApp.id)/microsoft.graph.win32lobapp/contentVersions/1/files/$($ContentReq.id)/commit" -Headers $script:GraphHeader -body $EncBody -Method POST -ContentType "application/json"
    do {
        write-verbose "Still trying to get commit state. Please wait."
        $CommitStateReq = Invoke-RestMethod -Uri "$($BaseURI)/$($NewApp.id)/microsoft.graph.win32lobapp/contentVersions/1/files/$($ContentReq.id)" -Headers $script:GraphHeader -Method get -ContentType "application/json"
        if ($CommitStateReq.uploadState -like "*fail*") { throw "Commit Failed for $($Package). Moving on to Next application. Manual intervention will be required" }
        start-sleep 10
    } while ($CommitStateReq.uploadState -eq "commitFilePending") 
    if ($CommitStateReq.uploadState -like "*fail*") { continue }
    write-verbose  "Commiting application version"
    $ConfirmBody = @{
        "@odata.type"             = "#microsoft.graph.win32lobapp"
        "committedContentVersion" = "1"
    } | Convertto-Json
    $CommitFinalizeReq = Invoke-RestMethod -Uri "$($BaseURI)/$($NewApp.id)" -Headers $script:GraphHeader -body $Confirmbody -Method PATCH -ContentType "application/json"
    Write-Verbose "Removing temporary files as everything has been uploaded."
    $Cleanup = get-childitem $InstallerDir -Filter *.intunewin | remove-item -Force
    return $($NewApp.id)
}