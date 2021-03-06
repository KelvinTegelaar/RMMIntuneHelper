# RMM Intune Helper Module

This is a PowerShell module that uploads your RMM agent installer, or any other installer to your Microsoft 365 Intune environment to help decrease the management load. This module always uploads the latest version of your RMM package to all your managed intune clients, allowing you to deploy your RMM tooling with ease.

The RMM Intune Helper module does the following steps for you, for each client that you manage within your RMM system or Microsoft ecosystem:

- Creates unique .intunewin files per client
- Creates the application in endpoint manager
- Uploads the Intunewin to Endpoint Manager
- Assigns the application to all users or computers

The RMM Intune Helper module can help you deploy standard, non RMM applications aswell to all of the tenants under your partnership portal, allowing you to create a single application and spreading it to all managed tenants.

THIS PACKAGE IS HIGHLY EXPERIMENTAL - DO NOT EXPECT IT TO FUNCTION 100%, DO NOT USE AS A PRODUCTION TOOL YET.  

# Installation instructions

This module has been published to the PowerShell Gallery. Use the following command to install:  

    install-module RMMIntuneHelper

# Usage

The application requires some prep work beforehand. 

For DattoRMM you'll have to create a site variable first. you can name this site variable anything you want but I suggest "O365Tenant". Fill this variable in at all your clients. You can then run the following script to deploy the DRMM everywhere:


```powershell
$Params = @{
    ApplicationId       = 'appID'
    ApplicationSecret   = 'appsecret'
    YourTenantID        = 'tenantid'
    RefreshToken        = 'longrefreshtoken'
    DattoURL            = 'https://pinotage-api.centrastage.net'
    DattoKey            = 'DattoAPIKey'
    DattoSecretKey      = 'DattoAPISecret'
    AssignToAllDevices  = $false
    PackageName         = "MyMSP RMM Agent"
    DattoTenantVariable = "O365Tenant"
}
Import-Module "RMMIntuneHelper"  
New-DattoRMMApplication @params -Verbose
```

For SyncroRMM you'll have to create a customer custom field first. Browse to `yourdomain.syncromsp.com/customer_fields` you can name this site variable anything you want but I suggest "O365Tenant". Fill this variable in at all your clients. You can then run the following script to deploy the SyncroRMM client everywhere.


```powershell
$Params = @{
    ApplicationId       = 'appID'
    ApplicationSecret   = 'appsecret'
    YourTenantID        = 'tenantid'
    RefreshToken        = 'longrefreshtoken'
    SyncroURL           = 'https://YOURSUBDOMAIN.syncromsp.com/'
    SyncroAPIKey        = 'SyncroAPIKey'
    SyncroPolicyID      = 'SyncroPolicyID'
    SyncroInstallerURL = 'https://rmm.syncromsp.com/dl/rs/LONGSTRINGHERE'
    AssignToAllDevices  = $false
    PackageName         = "MyMSP RMM Agent"
    SyncroTenantVariable = "O365Tenant"
}
Import-Module "RMMIntuneHelper"  
New-syncroRMMApplication @params -Verbose
```


For generic applications that all your tenants need, you can use the following code. Change the values to what you need. I strongly suggest to create a empty folder with your installer in it. In this example we're uploading 7-zip.

```powershell
$Params = @{
    ApplicationId        = 'appID'
    ApplicationSecret    = 'appsecret'
    YourTenantID         = 'tenantid'
    RefreshToken         = 'longrefreshtoken'
    PackageName          = "7-Zip"
    PackageVersion       = "1.0"
    packageinstallcmd    = "7z1900-x64.exe /S"
    packageuninstallcmd  = "C:\Program Files\7-Zip\Uninstall.exe /S"
    packagedetectionpath = "C:\program files\7-Zip"
    packagedetectionfile = '7z.xe'
    InstallerPath        = "C:\Intune\7Zip\7z1900-x64.exe"
    AssignToAllDevices   = $false
}
Import-Module "RMMIntuneHelper"  
New-GenericApplication @params -Verbose

```

**Examples:**

to be documented


# Contributions

Feel free to send pull requests or fill out issues when you encounter them. I'm also completely open to adding direct maintainers/contributors and working together! :). There's loads of work to be done. If you feel like you can contribute then go ahead. We're trying to keep this a module without any external deps so please avoid integrating any other modules. :)


# Future plans

If we're looking at the current code, it's all simply ripped apart from some of my existing blogs which had very singular functionality, or was just for demonstration purposes. the code right now is not at a production ready state. the following list are items I want to work on/am going to work on

- [ ] Generalized and improve error handling
- [ ] Log to file option
- [ ] Split code into more functions
- [ ] Make graph request engine instead of manual irm
- [ ] Implement chunking so file size does no matter
- [ ] Documentation per cmdlet, improved documentation in general
- [ ] Support for all existing RMM platforms
- [ ] Loads of code cleanup and effeciency improvements
- [ ] Assign to all users option
- [ ] Add -WhatIf support
- [ ] actual version management instead of nuke and pave
- [ ] Improve housekeeping of temp files and prereqs
- [ ] Publish with Azure Function frontend
    - [ ] Selectable tenants
    - [ ] Easy to use upload functionality for intunewin
    - [ ] Assign rules