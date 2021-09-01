function New-IntunewinPackage {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$InstallerPath
    )
    Write-Verbose "Creating intune package for $($PackageName)"
    $InstallerDirectory = [System.IO.Path]::GetDirectoryName("$($InstallerPath)")
    try { 
        $InstallerFiles = get-childitem $InstallerDirectory
    }
    catch {
        throw "could not get installer path. Did you enter the right path?"
    }
    try {
        $InstallerSize = [math]::round(($InstallerFiles | Measure-Object -Property Length -sum).sum)
        if ($InstallerSize -lt 11MB) {
            Write-Verbose "Adding padding for $($PackageName) as it is under the minimum file size for AzCopy"
            $bytes = 11MB - $InstallerSize
            [System.Security.Cryptography.RNGCryptoServiceProvider] $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
            $rndbytes = New-Object byte[] $bytes
            $rng.GetBytes($rndbytes)
            [System.IO.File]::WriteAllBytes("$InstallerDirectory\dummy.dat", $rndbytes)
        }
    }
    catch {
        throw "Failed to create padding file. Do we have write permissions?"
    }
    try {
        $FileToExecute = $InstallerPath.split('\') | Select-Object -last 1
        start-process "$env:TEMP\IntuneRMMHelper\IntuneWinAppUtil.exe" -argumentlist "-c $InstallerDirectory -s $FileToExecute -o $InstallerDirectory -q" -wait
    }
    catch {
        throw "Failed to create intunewin file: $($_.Exception.Message)"
    }
    $Returnedfile = get-childitem $InstallerDirectory -Filter *.intunewin | Sort-Object LastWriteTime | Select-Object -Last 1
    return $Returnedfile.fullname
}