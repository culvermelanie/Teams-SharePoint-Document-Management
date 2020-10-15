# Introduction 
This is a demo collection of resources I use for my sessions on Document Management in Teams and SharePoint.

In this repo you will find the ARM templates for the Azure Resources and the PowerShell scripts used in the Azure Functions. 

# Technology Stack

*   Logic App for the handling for SharePoint list entries for the request of client and project space
*   Azure Functions called by the Logic App to apply additional configuration to the created SharePoint site and Team

Comment on the version of the Azure Function. At the time of creation of the demo, only the SharePoint cmdlets where available for .NET Core and the Teams cmdlet did not work. For that reason, I reverted to the old version 1 of the Azure Functions. An option would be to use the Graph API for the Teams interaction and then you should be able to move to the most recent Azure Function version.

# Pre-Requisites

## SharePoint
Add the Work Request list to your SharePoint site by applying this [template]( https://github.com/culvermelanie/Teams-SharePoint-Document-Management/blob/master/WorkspaceRequestListTemplate.xml) from the repo using this command: 

`Apply-PnPProvisioningTemplate -Path .\WorkspaceRequestListTemplate.xml`                                                                                         

## Azure
Create an Azure Resource group to provision the artefacts listed in this [directory](https://github.com/culvermelanie/Teams-SharePoint-Document-Management/tree/master/AzureSchema)

If you are real enthusiastic you can use the Azure ARM templates and provision the resources via Azure DevOps, otherwise just use the PowerShell cmdlts.

## User

Create a service account user with simple user permission in your tenant. That user should be able to create MS teams. 

# After Azure Setup

* fix the connection for the Logic App to point to the SharePoint list you provisioned in the previous step
* For the Azure Function App add the following two KeyValue-Pairs

| Name | Value |
| ----------- | ----------- |
| SvcUserName | *Ideally connect this to the AzureKeyVault* |
| SvcPassword | *Ideally connect this to the AzureKeyVault* |

* Open all of the Azure Functions and replace any hardcoded values to your environment values.

# General Note
If you are facing any issues or have questions, just drop me a line.

# Disclaimer
The code is provided as is and not ready to be used in an production environment.




