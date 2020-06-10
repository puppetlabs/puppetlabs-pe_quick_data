#!/bin/bash

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

# See if there is already a pe_roles_and_profiles directory in the output directory and if not let's create it
if [ ! -d "$output_dir/pe_roles_and_profiles/" ]
then
    mkdir -p "$output_dir/pe_roles_and_profiles/"
fi

output_roles_profiles_file="$output_dir/pe_roles_and_profiles/roles_and_profiles.txt"
roles_profiles_json="$output_dir/pe_roles_and_profiles/roles_and_profiles.json"

echo "[" >> $roles_profiles_json

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# Retrieve the environments for the Puppet Enterprise install
codeenv=$(ls -1 /etc/puppetlabs/code/environments)
countenv=0

for env in $codeenv
do
    ((countenv=countenv+1))
done

# Go through each environment and find the roles, profiles and Puppetfile for extracting information
# For data found dump to a pe_roles_and_profiles directory located in the output director
peenvcount=0
for peenv in $codeenv
do
    ((peenvcount=peenvcount+1))
    cd /etc/puppetlabs/code/environments/$peenv
    
    roles=$(find *modules/role/manifests -name *.pp)
    rolecount=0

    # Counting the number of roles in the enviornment
    for role in $roles
    do
        ((rolecount=rolecount+1))
    done
    
    # If there are no roles set the rolecount to string 0 to print to file
    if [[ -z ${rolecount+x} ]]
    then
        rolecount="0"
    fi

    # Output of role information to the roles_and_profiles file
    echo "**** ${peenv} has $rolecount roles ****" >> $output_roles_profiles_file
    echo >> $output_roles_profiles_file
    echo "${roles}" >> $output_roles_profiles_file
    echo >> $output_roles_profiles_file
    
    echo $(pwd)
    profiles=$(find *modules/profile/manifests -name *.pp)
    profilecount=0
    
    # Counting the number of profiles in the environment
    for profile in $profiles
    do
        ((profilecount=profilecount+1))  
    done
    
    # If there are no roles set the rolecount to string 0 to print
    if [[ -z ${profilecount+x} ]]
    then
        profilecount="0"
    fi

    # Output of role information to the roles_and_profiles.txt file
    echo "**** ${peenv} has $profilecount profiles ****" >> $output_roles_profiles_file
    echo >> $output_roles_profiles_file
    echo "${profiles}" >> $output_roles_profiles_file
    echo >> $output_roles_profiles_file

    # Output of the Puppetfile to the roles_and_profiles.txt file
    echo "**** ${peenv} Puppetfile Contents ****" >> $output_roles_profiles_file
    cat Puppetfile >> $output_roles_profiles_file
    echo >> $output_roles_profiles_file

    if [ $peenvcount -ne $countenv ]
    then    
        echo "{ "\"${peenv}\"" : { \"roles\": $rolecount, \"profiles\": $profilecount}}," >> $roles_profiles_json 
    else
        echo "{ "\"${peenv}\"" : { \"roles\": $rolecount, \"profiles\": $profilecount}}" >> $roles_profiles_json
    fi

    # Need to reset the count variables for the next environment
    unset rolecount profilecount

done

echo "]" >> $roles_profiles_json