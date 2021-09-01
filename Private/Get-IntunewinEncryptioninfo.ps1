function Get-IntunewinEncryptioninfo {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$Package
    )
    $Directory = [System.IO.Path]::GetDirectoryName("$($package)")
    Add-Type -Assembly System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead("$($package)")
    $zip.Entries | Where-Object { $_.Name -like "Detection.xml" } | ForEach-Object {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$Directory\Detection.xml", $true)
    }
    $zip.Dispose()
    [xml ]$intunexml = get-content "$Directory\Detection.xml"
    remove-item  "$Directory\Detection.xml" -Force
    #Unzip the encrypted file to prepare for upload.
    $Directory = [System.IO.Path]::GetDirectoryName("$($package)")
    Add-Type -Assembly System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead("$($package)")
    $zip.Entries | Where-Object { $_.Name -like "IntunePackage.intunewin" } | ForEach-Object {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$Directory\IntunePackage.intunewin", $true)
    }
    $zip.Dispose()
    $intunewinFileSize = (Get-Item "$Directory\IntunePackage.intunewin").Length
    $ContentBody = [pscustomobject]@{
        name               = $intunexml.ApplicationInfo.FileName
        size               = [int64]$intunexml.ApplicationInfo.UnencryptedContentSize
        sizeEncrypted      = [int64]$intunewinFileSize
        fileEncryptionInfo = [pscustomobject]@{
            encryptionKey        = $intunexml.ApplicationInfo.EncryptionInfo.EncryptionKey
            macKey               = $intunexml.ApplicationInfo.EncryptionInfo.MacKey
            initializationVector = $intunexml.ApplicationInfo.EncryptionInfo.InitializationVector
            mac                  = $intunexml.ApplicationInfo.EncryptionInfo.Mac
            profileIdentifier    = $intunexml.ApplicationInfo.EncryptionInfo.ProfileIdentifier
            fileDigest           = $intunexml.ApplicationInfo.EncryptionInfo.FileDigest
            fileDigestAlgorithm  = $intunexml.ApplicationInfo.EncryptionInfo.FileDigestAlgorithm
        }
    }
    
    return $ContentBody
}