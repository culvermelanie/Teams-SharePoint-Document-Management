# Introduction 
This is a demo collection of resources I use for my sessions on Document Management in Teams and SharePoint.

In this repo you will find the ARM templates for the Azure Resources and the PowerShell scripts used in the Azure Functions. 

Used technology stack in Azure:
*	Logic App for the handling for SharePoint list entries for the request of client and project space
*	Azure Functions called by the Logic App to apply additional configuration to the created SharePoint site and Team

Comment on the version of the Azure Function. At the time of creation of the demo, only the SharePoint cmdlets where available for .NET Core and the Teams cmdlet did not work. For that reason, I reverted to the old version of the Azure Functions. An option would be to use the Graph API for the Teams interaction and then you should be able to move to the most recent Azure Function version.

# Disclaimer
The code is provided as is and not ready to be used in an production environment.
