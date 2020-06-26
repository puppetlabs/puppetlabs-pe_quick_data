# Module for quick data collection of Puppet Enterprise environment

## Description

The plans and tasks in this repo will quickly collect data from a Puppet Enterprise server to be used for understanding the environment better and providing the customer with value as a baseline moving forward.  Plans and tasks included in this module can be run using either Puppet Bolt or Puppet Enterprise Plans and/or Tasks. Thanks to the repository at https://github.com/puppetlabs/pe_tech_check for providing support script parts of the data collect.   

***For a review of the data collected as part of the module please see the documentation located at https://github.com/puppetlabs/puppetlabs-pe_quick_data/blob/master/data_use/data_use.md***

## Requirements

- Puppet Bolt version 2 or higher when using Bolt to execute the plans and tasks
    - See https://puppet.com/docs/bolt/latest/bolt_installing.html for installation and Bolt usage
- Puppet Enterprise master server with bash capabilities
- Puppet Enterprise 2019 or higher for running plans
- Root/su authentication to the PE Master

## Setup for use - Bolt

1. Use module from the forge by adding the module to your Boltdir directory Puppetfile.

    ```
    mod 'puppetlabs-pe_quick_data', '1.1.0'
    ```
2. Run ```bolt puppetfile install``` from the Boltdir directory where the Puppetfile is located.
3. Save inventory.yaml file with PE master defined for the environment into the same Boltdir directory.
4. The default directory for the data collection is currently /var/tmp/pe_quick_data on the Puppet Enterprise master, but this can be changed at run time.
5. If an alternate directory is specified for the data collection through the outputdir parameter, the folder pe_quick_data will be created on the PE master, in the alternate directory.

## Setup for use - Puppet Enterprise (PE) 2019 or higher

1. Use the module from the forge by adding the module to your Puppetfile in the appropriate environment.
2. Deploy the updated Puppetfile to the environment via your current deployment method.
3. Run the pe_quick_data::data_collect plan using Plans in PE.
    1. Specify the PE master as the target and optionally specify the output_dir location.

## Bolt Plan Use

To use the plan run `bolt plan run pe_quick_data::data_collect` with --targets specified to point to the master or masters for Puppet Enterprise

### Parameters for use with the plan

    output_dir - specifies the directory where the pe_quick_data directory will be created to collect the all data to be retrieved.  
    
    This uses tar and gzip to zip the data into a file and will be left in the output_dir.   
    
    The default directory is /var/tmp/ and a tar.gz file is placed within pe_quick_data directory in the default directory.

### Required Parameters

    output_dir is a required parameter. 
    
    It does not need to be included in the command if using the default path.

## Plan Use Examples

#### **Run data collection with default output directory**

```
bolt plan run pe_quick_data::data_collect --targets master
```

#### **Run data collection with default output directory with no inventory.yaml**

```
bolt plan run pe_quick_data::data_collect --targets master.example.com --user <USER> --private-key <KEY_PATH> --transport ssh --no-host-key-check --run-as root
```

#### **Run data collection specifying an alternate output_dir**

```
bolt plan run pe_quick_data::data_collect --targets master output_dir=/tmp/
```

## Bolt Task Usage

The tasks in this repository can be used as well to perform the individual data collections as required.   

For instance, if only the roles and profiles need to be collected this can be done using a task.   

The tasks also output the data to the default output_dir of /var/tmp/pe_quick_data, but the directory can be overwritten at run time.  The data ran using a task is not placed into a gz zip file, other than the pe_quick_data::collect task, but can be zipped using the task pe_quick_data::zippedata if needed.   

## Task Example Usage

#### **Gather only the roles and profiles data**

```
bolt task run pe_quick_data::roles_and_profiles --targets master
```

#### **Gather only the roles and profiles data using no inventory.yaml file**

```
bolt task run pe_quick_data::roles_and_profiles --targets master.example.com --user <USER> --private-key <KEY_PATH> --transport ssh --no-host-key-check --run-as root
```

#### **Gather only the support script data**

```
bolt task run pe_quick_data::collect --targets master
```

#### **Gather only the support script data using no inventory.yaml file**

```
bolt task run pe_quick_data::collect --targets master.example.com --user <USER> --private-key <KEY_PATH> --transport ssh --no-host-key-check --run-as root
```