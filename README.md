# Module for quick data collection of Puppet Enterprise environment

## Description

The Bolt plans and tasks in this repo will quickly collect data from a Puppet Enterprise server to be used for understanding the environment better and providing the customer with value as a baseline moving forward.  Thanks to the repository at https://github.com/puppetlabs/pe_tech_check for providing support script parts of the data collect.

## Requirements

- Puppet Bolt version 2 or higher
- Puppet Enterprise master server with Linux Bash capabilities enabled
- Root/SU authentication to the PE Master

## Setup for use


1. To use repo module, add the module git repository to your Boltdir Puppetfile.

    ```
    mod 'pe_quick_data',
        :git => 'https://github.com/puppetlabs/pe_quick_data'
    ```

2. Run ```bolt puppetfile install``` from the Boltdir directory where the Puppetfile is located.
3. Save inventory.yaml file for the environment into the same Boltdir directory.
4. Default directory for the data collection is currently /var/tmp/pe_quick_data, but can be change at run time.

## Bolt Plan Use

To use the plan run `bolt plan run pe_quick_data::data_collect' with --targets specified to point to the master or masters for Puppet Enterprise

#### Parameters for use with the plan

    output_dir - specifies the directory to collect the data to be retrieved.   This uses tar and gzip to zip the data into a file and will be left in the output_dir.   The default directory is /var/tmp/pe_quick_data

#### Required Parameters

    output_dir is a required parameter, but does not need to be included in the command if using the default path

## Plan Use Examples

#### **Run data collection with default output directory**

```
bolt plan run pe_quick_data::data_collect --targets master
```

#### **Run data collection specifying an alternate output_dir**

```
bolt plan run pe_quick_data::data_collect --targets master output_dir=/tmp/pe_data_folder
```

## Bolt Task Usage

The tasks in this repository can be used as well to perform the individual data collections as required.   For instance, if only the roles and profiles need to be collected this can be done using a task.   The tasks also output the data to the default output_dir of /var/tmp/pe_quick_data, but the directory can be overwritten at run time.  The data ran using a task is not placed into a gz zip file, other than the pe_quick_data::collect task, but can be zipped using the task pe_quick_data::zippedata if needed.   

## Task Example Usage

#### **Gather only the roles and profiles data**

```
bolt task run pe_quick_data::roles_and_profiles --targets master
```

#### **Gather only the support script data**

```
bolt task run pe_quick_data::collect --targets master
```
