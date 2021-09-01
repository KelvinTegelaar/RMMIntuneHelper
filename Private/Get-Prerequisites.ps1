function Get-Prerequisites {
    [CmdletBinding()]
    Param()
    $AzCopyUri = "https://cyberdrain.com/wp-content/uploads/2020/04/azcopy.exe"
    $IntuneWinAppUri = "https://cyberdrain.com/wp-content/uploads/2020/04/IntuneWinAppUtil.exe"
    $ApplicationFolder = "$($ENV:TEMP)\IntuneRMMHelper"
    $null = new-item "$($ENV:TEMP)\IntuneRMMHelper" -ItemType Directory -ErrorAction SilentlyContinue -Force
    write-verbose "Checking AZCopy prerequisites and downloading these if required"
    try {
        $AzCopyDownloadLocation = Test-Path "$ApplicationFolder\AzCopy.exe"
        if (!$AzCopyDownloadLocation) { 
            Invoke-WebRequest -UseBasicParsing -Uri $AzCopyUri -OutFile "$($ApplicationFolder)\AzCopy.exe"
        }
        else {
            write-verbose "       AZCopy.exe found at $($applicationfolder)"
        }
    }
    catch {
        throw "The download and extraction of AzCopy failed. The script will stop. Error: $($_.Exception.Message)"
        exit 1
    }
    write-verbose "Checking IntuneWinAppUtil prerequisites and downloading these if required"
 
    try {
        $AzCopyDownloadLocation = Test-Path "$ApplicationFolder\IntuneWinAppUtil.exe"
        if (!$AzCopyDownloadLocation) { Invoke-WebRequest -UseBasicParsing -Uri $IntuneWinAppUri -OutFile "$($ApplicationFolder)\IntuneWinAppUtil.exe" } 
        else {
            write-verbose "       IntuneWinAppUtil found at $($applicationfolder)"
        }
    }
    catch {
        throw "The download and extraction of IntuneWinApp failed. The script will stop. Error: $($_.Exception.Message)"
    }

}