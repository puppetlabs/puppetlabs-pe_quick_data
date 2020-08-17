# Module for quick data collection of Puppet Enterprise environment

## Description

The plan in this repo will quickly collect data from a Puppet Enterprise server to be used for understanding the environment better and providing the customer with value as a baseline moving forward.  Plans and tasks included in this module can be run using either Puppet Bolt or Puppet Enterprise Plans and/or Tasks. Thanks to the repository at https://github.com/puppetlabs/pe_tech_check for providing support script parts of the data collect.   

***For a review of the data collected as part of the module please see the documentation located at https://github.com/puppetlabs/puppetlabs-pe_quick_data/blob/master/data_use/data_use.md***

## Requirements

- If running the module from an admin workstation, Puppet Bolt version 2 or higher when using Bolt to execute the plan via command line
    - See https://puppet.com/docs/bolt/latest/bolt_installing.html for installation and Bolt usage
- Puppet Enterprise master server with bash capabilities for collecting data
- The module can be run from the Puppet Enterprise 2019 or higher console through PE Plans 
- Root/su authentication to the PE Master that data is collected from is required

## Setup for using the module - Bolt

1. Use module from the forge by adding the module to your Boltdir directory Puppetfile.

    ```
    mod 'puppetlabs-pe_quick_data', '2.1.0'
    ```
2. Run ```bolt puppetfile install``` from the Boltdir directory where the Puppetfile is located.
3. Save inventory.yaml file with PE master defined for the environment into the same Boltdir directory.
4. The default directory for the data collection is currently /var/tmp/pe_quick_data on the Puppet Enterprise master, but this can be changed at run time.
5. If an alternate directory is specified for the data collection through the outputdir parameter, the folder pe_quick_data will be created on the PE master, in the alternate directory.

## Setup for using the module - Puppet Enterprise (PE) 2019 or higher

1. Use the module from the forge by adding the module to your Puppetfile in the appropriate environment.
2. Deploy the updated Puppetfile to the environment via your current deployment method.
3. Run the pe_quick_data::data_collect plan using Plans in PE.
    1. Specify the PE master as the target and optionally specify the output_dir location.

## Bolt Plan Use

To use the plan run `bolt plan run pe_quick_data::data_collect` with --targets specified to point to the master or masters for Puppet Enterprise

### Parameters for use with the plan

**output_dir - specifies the directory where the pe_quick_data directory will be created.**
  * This uses tar and gzip to zip the data into a file and will be left in the output_dir.   
  * The default directory is /var/tmp/ and a tar.gz file is placed within pe_quick_data directory in the default directory.
  * It is an optional parameter at run time.  If not specified, the default directory output will be used.

**enable_logs - specifies whether or not to include the support script log output**
  * To enable, specifiy enable_logs=true when running the plan
  * It is an optional parameter at run time.  If not specified, support script logs are not included.
  * If enabled_logs=true, the size of the output will be increased to a potentially large size.

## Plan Use Examples

#### **Run data collection with default output directory**

```
bolt plan run pe_quick_data::data_collect --targets puppetm.example.com
```

#### **Run data collection with default output directory with no inventory.yaml**

```
bolt plan run pe_quick_data::data_collect --targets puppetm.example.com --user <USER> --private-key <KEY_PATH> --transport ssh --no-host-key-check --run-as root
```

#### **Run data collection specifying an alternate output_dir**

```
bolt plan run pe_quick_data::data_collect --targets puppetm.example.com output_dir=/tmp/
```

#### **Run data collection and include support script logging**

```
bolt plan run pe_quick_data::data_collect --targets puppetm.example.com enable_logs=true
```