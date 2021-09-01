function Set-IntunePackageAssign {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$PackageID
    )
    $AssignMentInfo = @"
{"mobileAppAssignments":[{"@odata.type":"#microsoft.graph.mobileAppAssignment","target":{"@odata.type":"#microsoft.graph.allDevicesAssignmentTarget"},"intent":"Required","settings":{"@odata.type":"#microsoft.graph.win32LobAppAssignmentSettings","notifications":"hideAll","installTimeSettings":null,"restartSettings":null,"deliveryOptimizationPriority":"notConfigured"}}]}
"@
    Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$($PackageID)/assign" -Headers $script:GraphHeader -body $AssignMentInfo -Method POST -ContentType "application/json"

}