#!/bin/bash

# We're determining if an output directory exists on the host, finding out if there is a tar.gz file and taking the most recent one
# Checking for the specified output directory.   If it exists, check for a pe_quick_data directory and create it if not present.
# Set the variable output_dir to user specified output directory plus pe_quick_data directory to avoid issues when zipping and deleting files
# We're exiting out of this script if no gzip files exist, or if there is no output directory
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
        echo "gz file found for adding node data to"
    else
        echo "No gzip files available to use for adding node data"
    fi
else
    echo "No $PT_output_dir directory exists to dump files"
fi

# See if there is already a pe_nodes directory in the output directory and if not let's create it
if [ ! -d "$output_dir/pe_nodes/" ]
then
    mkdir -p "$output_dir/pe_nodes/"
fi

peversion=$(cat /opt/puppetlabs/server/pe_version)

echo $peversion

nodecount_file="$output_dir/pe_nodes/activenodecount.json"
nodecountenv_file="$output_dir/pe_nodes/nodecount_byenv.json"
nixcount_file="$output_dir/pe_nodes/nixnodecount.json"
nixosinfo_file="$output_dir/pe_nodes/nixosinfo.json"
wincount_file="$output_dir/pe_nodes/winnodecount.json"
winosinfo_file="$output_dir/pe_nodes/winosinfo.json"

if [[ $peversion = *"2019"* ]]
then
    # Ensure pathing is set to be able to run puppet commands
    [[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

    echo " ** Collecting Output of: Number of Total Nodes"
    echo ""

    # Getting all nodes listed in the database that are active and count them.
    # Get the count of active nodes by environment 
    puppet query "nodes [count()] {node_state = 'active'}" > $nodecount_file
    puppet query "nodes [facts_environment, count()]{node_state = 'active' group by facts_environment }" > $nodecountenv_file

    echo " ** Collecting Output of: Number and Type of Total Linux Nodes"
    echo ""

    # Count all nodes by Linux OS and get node name and OS version
    puppet query "inventory [count()] { facts.kernel = 'Linux' and facts.aio_agent_build is not null}" > $nixcount_file
    puppet query "inventory [certname, facts.os.name, facts.os.release.major] {facts.kernel = 'Linux' and facts.aio_agent_build is not null}" > $nixosinfo_file

    echo " ** Collecting Output of: Number and Type of Total Windows Nodes"
    echo ""

    # Count all nodes by Windows OS and get node name and OS version
    puppet query "inventory [count()] { facts.kernel = 'windows' and facts.aio_agent_build is not null}" > $wincount_file
    puppet query "inventory[certname, facts.os.windows.product_name] {facts.kernel = 'windows' and facts.aio_agent_build is not null}" > $winosinfo_file
elif [[ $peversion = *"2018"* ]]
then
    echo "version of PE is $peversion"
    # Getting all nodes listed in the database that are active and count them.
    # Get the count of active nodes by environment 
    puppet query "nodes [count()] {node_state = 'active'}" > $nodecount_file
    puppet query "nodes [facts_environment, count()]{node_state = 'active' group by facts_environment }" > $nodecountenv_file
elif [[ $peversion = *"2017"* ]]
then
    echo "Puppet Query unavailable in $peversion" > $nodecount_file
else
    echo "Wrong version of PE for this task"
fi