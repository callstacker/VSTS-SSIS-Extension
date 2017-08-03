![Build Status](https://toxicglobe.visualstudio.com/_apis/public/build/definitions/62790b7f-50dd-4a0e-8954-b613d4a9e98b/17/badge)

## Introduction
> VSTS Extension task to build and deploy Visual Studio Project - SQL Server Integration Services using the Project Deployment Model.

## Description
> A Visual Studio project, containing packages and parameters, is built to a project deployment file (.ispac).
> [Deployment of Projects and Packages](https://msdn.microsoft.com/en-us/library/hh213290.aspx)

## Documentation
> Please check the Wiki
> <https://github.com/ToxicGlobe/VSTS-SSIS-Extension/wiki>


### How to Setup build
> <https://github.com/ToxicGlobe/VSTS-SSIS-Extension/wiki/How-to-Setup-build>

## Contribute
> * Contributions are welcome!
> * Submit bugs and help us verify fixes
> * Submit pull requests for bug fixes and features and discuss existing proposals

> [file an issue](https://github.com/ToxicGlobe/VSTS-SSIS-Extension/issues)

## Latest Updates
> 0.3.346
>
> Implementation for the DeploySSISTask, enabling the task to be used in a deployment pipeline to deploy SSIS projects. Thanks to https://github.com/sschutten !!
>
> It takes a few parameters:
> * Project File Path: the location of the *.ispac file
> * Project Name: the name of the SSIS project
> * Server Name: the name/instance of the SSIS server
> * SSIS Catalog
> * SSIS Catalog Folder: the Folder is created if it doesn't exist
> * Project Parameters: the task supports project parameter values, so you can specify different parameter values for each environment. Project parameters are provided each on a separate line in the form of [name]=[value].
>
> Other small tweaks include:
> * Remove space from task name as only alphanumeric characters are allowed
> * Add DeploymentGroup to runsOn options
> * Change Devenv.exe to Devenv.com for reliable build
> * Removed "Preview" status

> 0.1.0
>
> Supported version VS2013, VS2015

## TODO:
> * Implement custom path for Devenv.com utility
