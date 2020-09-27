$requestBody = Get-Content $req -Raw | ConvertFrom-Json
Write-Output $requestBody
$TeamName = $requestBody.ClientName
$Owners = $requestBody.Owners | ConvertFrom-Json
$Members = $requestBody.Members | ConvertFrom-Json

Write-Output "Provisioning requested client space: $TeamName"

Write-Output "Owners: $Owners"
Write-Output "Members: $Members"
  
try
{

    $username = $env:APPSETTING_SvcUserName
    $pwd = ConvertTo-SecureString $env:APPSETTING_SvcPassword -AsPlainText -Force
    
    $NickName = ($TeamName -replace '\s+', '').ToLower()
    $SharePointUrl = "https://culverdemo.sharepoint.com/sites/$NickName"

    $HubSiteUrl = "https://culverdemo.sharepoint.com/sites/DemoHubSite"
    $InputSchemaFileUrl = "/SiteAssets/clienttemplate.xml"
    $hubSiteId = "abbf23a8-8a84-454f-b5c9-6ed48b435d8f"
    $internalAccessGroup = "DemoAllStaff@culverdemo.onmicrosoft.com"

    ########################
    #connections
    ########################
    $creds = New-Object System.Management.Automation.PSCredential($username, $pwd)
    $teamstconnetion = Connect-MicrosoftTeams -Credential $creds

    $spConnectionHub = Connect-PnPOnline -Url $HubSiteUrl -Credentials $creds

    ########################
    #Teams
    ########################
    #check if team already exists
    $doesExist = Get-Team -DisplayName $TeamName

    if($doesExist -eq $null)
    {
        Write-Output "Creating Team $TeamName"
        $group = New-Team -DisplayName $TeamName -MailNickName $NickName
    }
    else
    {
        throw "The requested team alerady exists with the provided name $TeamName"
    }

    Write-Output "Add team users"
    #Set further owners of team
    Foreach ($owner in $Owners)
    {
        Add-TeamUser -GroupId $group.GroupId -Role Owner -User $owner.Email
    }    
    Foreach ($member in $Members)
    {
        Add-TeamUser -GroupId $group.GroupId -Role Member -User $member.Email
    }

    #wait a while until the SharePoint site is provisioned
    Start-Sleep -Seconds 10

    ########################
    #SharePoint Part
    ########################

    Write-Output "Connect to hub site"
    $file = Get-PnPFile -Url $InputSchemaFileUrl -AsString -Connection $spConnectionHub
    $schema = Read-PnPProvisioningTemplate -Xml $file
    #set default value for client field
    $schema.Lists[0].FieldDefaults.Add("demo_clientname", $TeamName)

    Write-Output "Applying SharePoint schema"
    Start-Sleep -Seconds 10 #need to wait for sharepoint to be created
    $spConnectionNewSite = Connect-PnPOnline -Url $SharePointUrl -Credentials $creds
    Apply-PnPProvisioningTemplate -InputInstance $schema -Connection $spConnectionNewSite

    #set permissions as required
    Set-PnPWebPermission -Connection $spConnectionNewSite -User $internalAccessGroup -AddRole "Read"
    #on internal folders
    $i = Get-PnPFolder -Connection $spConnectionNewSite -Url "Shared Documents/General/Internal Documents" -Includes ListItemAllFields
    Set-PnPListItemPermission -Connection $spConnectionNewSite -List "Documents" -Identity $i.ListItemAllFields -User $internalAccessGroup -AddRole "Contribute" -ClearExisting

    Write-Output "Join HubSite"
    #https://culverdemo.sharepoint.com/sites/DemoHubSite/_api/site/id
    Invoke-PnPSPRestMethod -Url "/_api/site/JoinHubSite(@v1)?@v1='$hubSiteId'" -Method POST -Content "" -Connection $spConnectionNewSite


$body = @{
    SharePointUrl = $SharePointUrl;
    TeamID = $group.GroupId
}

$return = $body | ConvertTo-Json | Out-String

Out-File -Encoding Ascii -FilePath $Response -inputObject $return

}
catch
{
    Write-Output $_.Exception.Message
    throw $_.Exception
}
