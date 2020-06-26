#!/bin/bash

# Listing out environments directory and if environments directories exist moving on to see if there are site-modules folders in the environments
# Exit out if there are no environments directories 
if [[ $(ls -1 /etc/puppetlabs/code/environments) ]]
then
    echo "Environments found"
    
    # We're determining if an output directory exists on the host, finding out if there is a tar.gz file and taking the most recent one
    # Checking for the specified output directory.   If it exists, check for a pe_quick_data directory and create it if not present.
    # Set the variable output_dir to user specified output directory plus pe_quick_data directory to avoid issues when zipping and deleting files
    # Exit if no user directory exists
    if [ -d $PT_output_dir ]
    then
        if [ ! -d "$PT_output_dir/pe_quick_data" ]
        then
            mkdir -p "$PT_output_dir/pe_quick_data"
            output_dir="$PT_output_dir"
            output_dir+="/"
            output_dir+="pe_quick_data"
        else
            output_dir="$PT_output_dir"
            output_dir+="/"
            output_dir+="pe_quick_data"
        fi
    
    # retrieving the number of gz files in the outputdir for use in determining if there is a gz file to use for zipping
    # Not sure this is needed for today's use and may be able to be removed, but keeping in if we decide that tarballing the task data
    # is something we want to do
        count=$(ls -1 "$output_dir"/*.gz 2>/dev/null | wc -l)
    
        if [ $count != 0 ]
        then
            echo "gz file found for adding roles and profiles data to"
        else
            echo "No gzip files available to use for adding roles and profiles data"
        fi

    else
        echo "No $PT_output_dir directory exists to dump files"
        exit
    fi
    
    # See if there is already a pe_site-modules directory in the output directory and if not let's create it
    if [ ! -d "$output_dir/pe_site-modules/" ]
    then
        mkdir -p "$output_dir/pe_site-modules/"
    fi

    output_site_modules_file="$output_dir/pe_site-modules/site_modules.txt"
    site_modules_json="$output_dir/pe_site-modules/site_modules.json"

    echo "[" >> $site_modules_json

    # Ensure pathing is set to be able to run puppet commands
    [[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"
    
    # Setting peenvcount and countenv variable for use to count number of environments to use in formatting json output below 
    countenv=0
    peenvcount=0
    
    # Retrieving environments directories in a variable to iterate through gathering site-module data for each environment
    codeenv=$(ls -1 /etc/puppetlabs/code/environments)
    
    # For loop to count environments using countenv variable
    for numenv in $codeenv
    do
        ((countenv=countenv+1))
    done

    # For loop to iterate through each environment and determine site-modules existence, count them, and dump to text file
    for peenv in $codeenv
    do
        # Add to peenvcount environment count as we enter the statement
        ((peenvcount=peenvcount+1))
        
        # Set variable envpath to the path of the environment we are working with
        envpath="/etc/puppetlabs/code/environments/$peenv"
        
        # Determine if the environment path has a site-modules directory and echo that no directory was found
        if [ ! -d "$envpath/site-modules/" ]
        then
            echo "No site-modules found for $peenv!"
        else
            echo "Found site-modules for $peenv!"
            
            # Capture the modules in the environment into a variable mod
            mods=$(ls -1 "$envpath/site-modules/")
            
            # Set a modcount counter to zero for using to count the number of site-modules
            modcount=0
            
            # Use modrole variable for capturing if role directory is in the site-modules directory
            modrole=false
            
            # Use modrole variable for capturing if role directory is in the site-modules directory
            modprofile=false

            # Iterate through the modules to count them, determine if role and profile directories exist and set to true if they do
            for mod in $mods
            do
                echo $mod
                ((modcount=modcount+1))
                
                if [[ $mod = "role" ]]
                then
                    modrole=true
                fi

                if [[ $mod = "profile" ]]
                then
                    modprofile=true
                fi

            done
            
            # If there are no modules set the modcount to string 0 to print to file
            # Output of module information to the site-modules file
            if [[ -z ${modcount+x} ]]
            then 
                modcount="0"
                echo "**** ${peenv} has $modcount modules in the site-modules directory ****" >> $output_site_modules_file
                echo >> $output_site_modules_file
            else # any modules that exist in site-modules will be sent to the site-modules file output
                echo "**** ${peenv} has $modcount modules in the site-modules directory ****" >> $output_site_modules_file
                echo >> $output_site_modules_file
                echo "${mods}" >> $output_site_modules_file
                echo >> $output_site_modules_file
            fi

            # Send information for site-modules count, and whether role and profile directories exist counts to the site_modules.json file for output
            if [ $peenvcount -ne $countenv ] # counting the number of environments for use on determining whether a comma is needed on the last entry
            then    
                echo "{ "\"${peenv}\"" : { \"site-modules\": $modcount, \"role\": $modrole, \"profile\": $modprofile}}," >> $site_modules_json
            else
                echo "{ "\"${peenv}\"" : { \"site-modules\": $modcount, \"role\": $modrole, \"profile\": $modprofile}}" >> $site_modules_json
            fi

        fi
        
        unset modcount

    done

    echo "]" >> $site_modules_json
else
    echo "No environments found"
    exit
fi