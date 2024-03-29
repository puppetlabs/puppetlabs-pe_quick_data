# Changelog

All notable changes to this project will be documented in this file.

## Release v2.3.4 (2021-10-01)

**Known Issues**

**Resolved Issues**

**Features**

***Compatibility with PE 2021***

## Release v2.3.1 (2020-09-29)

**Known Issues**

***Puppet Metrics Collector increases output of data collection files to > 10GB in size***

**Resolved Issues**

***Corrected documentation versioning***

**Features**

## Release v2.3.0 (2020-09-29)

**Known Issues**

***Puppet Metrics Collector increases output of data collection files to > 10GB in size***

**Resolved Issues**

**Features**

***Added collection of agent versions and count on the Puppet Enterprise server by OS***

## Release v2.2.0 (2020-09-03)

**Resolved Issues**

**Features**

***Added the ability to download the gzip file from the Puppet Infrastructure server environment to the bolt client***

## Release v2.1.0 (2020-08-17)

**Resolved Issues**

**Features**

***Moved all module collection to the site module task and removed task roles_and_profiles***

***Moved to discovering modulepaths instead of assuming the path for better results***

***Made tasks hidden from task show and documentation to alleviate some confusion as to what to run for data collection***

***Started to use pe_quick_data.log to log information for troubleshooting and quick information on the site_modules task***

**Bugfixes**

**Known Issues**

## Release v2.0.2 (2020-07-24)

**Resolved Issues**

***Fixed documentation issues related to the Readme***

**Features**

**Bugfixes**

**Known Issues**

## Release v2.0.0 (2020-07-24)

**Resolved Issues**

**Features**

***Moved puppet db queries to curl requests to support SSL, move away from requiring access tokens, and to support non-monolithic environments***

***Added additional query to gather resource usage by environment***

***Added support for gathering data for PE 2016 environments***

**Bugfixes**

**Known Issues**

## Release v1.2.3 (2020-7-17)

### Resolved Issues

***Corrected the module documentation for correct module based on version number***

## Release v1.2.1 (2020-7-15)

### Resolved Issues

***Deleting all folders out of the pe_quick_data folder when running the collect task.  This is done to avoid an issue when removing***
***other directories later in the task***

***Fixed issue where tar.gz files would compound in size adding any zip files in the output directory to a previous zip file***

## Release v1.2.0 (2020-7-10)

### Resolved Issues

***Some instances of Puppet Enterprise code environments may not always be located in the default location,***
***thus the environments would not be found.   Corrected to locate directories via a search for the codedir.***

### Features

***Added an argument called enable_logs that defaults to not capturing the output of the support logs.***

### Bug Fixes

## Release v1.1.0 (2020-06-26)

**Resolved Issues**

***Corrected documentation with correct links for bolt docs***

**Features**

***Added site-module data task to the module***

***Bug Fixes***

***Corrected node count data collect to run appropriate queries based on PE version***

## Release v1.0.2 (2020-06-17)

**Resolved Issues**

***Fixed documentation to indicate correct setup of module***

***Added the data collection markdown and data_use links and content to github***

**Features**

**Bugfixes**

**Known Issues**

## Release v1.0.1 (2020-06-16)

This is the inital release of the module which adds puppet queries to the already included 'puppet enteprise support' command included with Puppet Enterprise.

**Features**

Adds data in the support script collection that includes;

`Number of roles and profiles
 Number of total resources utilized within the PE install
 Number of total resources per node
 Total Active Nodes
 Node Generic Operating System (OS) information`

**Bugfixes**

**Known Issues**

## Release [v1.0.1]

This is the inital release of the module which adds puppet queries to the already included 'puppet enteprise support' command included with Puppet Enterprise.

**Features**

Adds data in the support script collection that includes;

`Number of roles and profiles
 Number of total resources utilized within the PE install
 Number of total resources per node
 Total Active Nodes
 Node Generic Operating System (OS) information`

**Bugfixes**

**Known Issues**
