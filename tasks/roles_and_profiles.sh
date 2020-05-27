#!/bin/bash

# Variables for output directory and files to hold data
output_dir=$PT_output_dir
output_roles_profiles_file="$PT_output_dir/pe_roles_and_profiles/roles_and_profiles.txt"

# We're determining if an output directory exists on the host, finding out if there is a tar.gz file and taking the most recent one
# We're exiting out of this script if no gzip files exist, or if there is no output directory
if [ -d $PT_output_dir ]
then
    count=$(ls -1 "$PT_output_dir"/*.gz 2>/dev/null | wc -l)
    if [ $count != 0 ]
    then
        gzfile=$(ls -t "$PT_output_dir" | head -n1)
        #Set the path to the gzip file we are going to use to add this data to
        output_gz_file="$PT_output_dir"
        output_gz_file+="/"
        output_gz_file+="$gzfile"
    else
        echo "No gzip files available to use for adding node data"
        exit
    fi
else
    echo "No $PT_output_dir directory exists to dump files"
    exit
fi

# See if there is already a pe_roles_and_profiles directory in the output directory and if not let's create it
if [ ! -d "$PT_output_dir/pe_roles_and_profiles/" ]
then
    mkdir -p "$PT_output_dir/pe_roles_and_profiles/" || fail "pe_roles_and_profiles directory failed to create"
fi

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# Retrieve the environments for the Puppet Enterprise install
codeenv=$(ls -1 /etc/puppetlabs/code/environments)

# Go through each environment and find the roles, profiles and Puppetfile for extracting information
# For data found dump to a pe_roles_and_profiles directory located in the output director
for peenv in $codeenv
do
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

    # Need to reset the count variables for the next environment
    unset rolecount profilecount

done

# Unzip the tar.gz file to append pe_roles_and_profiles directory to it and zip it back up in the same directory
gzip -d "${output_gz_file}"

base_tarfile=$(basename $output_gz_file .gz)

new_tarfile="$PT_output_dir"
new_tarfile+="/"
new_tarfile+="$base_tarfile"

cd "${PT_output_dir}"
tar -rf "${new_tarfile}" "pe_roles_and_profiles"
gzip "${new_tarfile}"

# Clean up and remove pe_roles_and_profiles directory
rm -rf "$PT_output_dir/pe_roles_and_profiles/"