
$requestBody = Get-Content $req -Raw | ConvertFrom-Json
Write-Output $requestBody
$SharePointUrl = $requestBody.SharePointUrl
$ProjectName = $requestBody.ProjectName
$OU = $requestBody.OU

Write-Output "Porvisioning project space: $SharePointUrl"
  
try
{

    $username = $env:APPSETTING_SvcUserName
    $pwd = ConvertTo-SecureString $env:APPSETTING_SvcPassword -AsPlainText -Force
    $internalAccessGroup = "DemoAllStaff@culverdemo.onmicrosoft.com"
    
    $creds = New-Object System.Management.Automation.PSCredential($username, $pwd)

    ########################
    #SharePoint Part
    ########################

    Write-Output "Applying project settings"
    $spConnectionNewSite = Connect-PnPOnline -Url $SharePointUrl -Credentials $creds
    #Set default values
    $relativeFolderList
    Set-PnPDefaultColumnValues -List "Shared Documents" -Field "Project Name" -Value $ProjectName -Folder $ProjectName
    Set-PnPDefaultColumnValues -List "Shared Documents" -Field "Implementing Organisationsal Unit" -Value $OU -Folder $ProjectName

    #set permissions as required
    Set-PnPWebPermission -Connection $spConnectionNewSite -User $internalAccessGroup -AddRole "Read"
    #on internal folders
    $i = Get-PnPFolder -Connection $spConnectionNewSite -Url "Shared Documents/$ProjectName/Internal Documents" -Includes ListItemAllFields
    Set-PnPListItemPermission -Connection $spConnectionNewSite -List "Documents" -Identity $i.ListItemAllFields -User $internalAccessGroup -AddRole "Contribute" -ClearExisting

$body = @{
    SharePointUrl = $SharePointUrl
}

$return = $body | ConvertTo-Json | Out-String

Out-File -Encoding Ascii -FilePath $Response -inputObject $return

}
catch
{
    Write-Output $_.Exception.Message
    throw $_.Exception
}
