#!/bin/bash

# Variables for output directory and files to hold data
output_dir=$PT_output_dir
output_resrcs_file="$PT_output_dir/pe_resources/resourcescount.json"

# We're determining if an output directory exists on the host, finding out if there is a tar.gz file and taking the most recent one
# We're exiting out of this script if no gzip files exist, or if there is no output directory
if [ -d $PT_output_dir ]
then
    count=$(ls -1 "$PT_output_dir"/*.gz 2>/dev/null | wc -l)
    if [ $count != 0 ]
    then
        echo "gz file found for adding resource data to"
    else
        echo "No gzip files available to use for adding resource data"
        exit
    fi
else
    echo "No $PT_output_dir directory exists to dump files"
    exit
fi

# See if there is already a pe_resources directory in the output directory and if not let's create it
if [ ! -d "$PT_output_dir/pe_resources/" ]
then
    mkdir -p "$PT_output_dir/pe_resources/"
fi

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

echo " ** Collecting Output of: Number of Resources by Certname"
echo ""

# Get the total number of resource being utilized in the environment and get the number of resources by node
puppet query "resources[count()] {}" >> $output_resrcs_file
puppet query "resources[certname, count()] { group by certname }" >> $output_resrcs_file

# Just putting some commas in between arrays, TODO: need to better format the json coming out
sed -i 's/]\[/],\[/' $output_resrcs_file