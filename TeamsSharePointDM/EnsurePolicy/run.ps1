try
{

    $username = $env:APPSETTING_SvcUserName
    $pwd = ConvertTo-SecureString $env:APPSETTING_SvcPassword -AsPlainText -Force

    $HubSiteUrl = "https://culverdemo.sharepoint.com/sites/DemoHubSite"
    $hubSiteId = "abbf23a8-8a84-454f-b5c9-6ed48b435d8f"
    $internalAccessGroup = "demoallstaff@culverdemo.onmicrosoft.com"

    ########################
    #connections
    ########################
    $creds = New-Object System.Management.Automation.PSCredential($username, $pwd)
    $spConnectionHub = Connect-PnPOnline -Url $HubSiteUrl -Credentials $creds

 
    ########################
    #SharePoint Part
    ########################

    $site = Get-PnPSite -Includes HubSiteId -Connection $spConnectionHub
    $hubSiteId = $site.HubSiteId
    $searchQuery = "contentclass=sts_site AND DepartmentId:{$($hubSiteId.ToString())}"
    Write-Output $searchQuery
    $results = Submit-PnPSearchQuery -Query $searchQuery -TrimDuplicates $false -SelectProperties @("Title","Path","DepartmentId","SiteId") -All -Connection $spConnectionHub

    $siteCount = $results.ResultRows.Count
    Write-Output "Found $siteCount sites"
    $i = 1

    foreach($site in $results.ResultRows)
    {
        $connectionSite = Connect-PnPOnline -url $site.Path -Credentials $creds
        Write-Output "$i of $siteCount - $($site.Title) - $($site.Path)"
        $i++
        #set permissions as required
        Set-PnPWebPermission -Connection $connectionSite -User $internalAccessGroup -AddRole "Read"
    }
}
catch
{
    Write-Output $_.Exception.Message
    throw $_.Exception
}
