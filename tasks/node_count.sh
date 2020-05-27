#!/bin/bash

# Variables for output directory and files to hold data
output_dir=$PT_output_dir
output_nodes_file="$PT_output_dir/pe_nodes/nodecount.json"


# We're determining if an output directory exists on the host, finding out if there is a tar.gz file and taking the most recent one
# We're exiting out of this script if no gzip files exist, or if there is no output directory
if [ -d $PT_output_dir ]
then
    count=$(ls -1 "$PT_output_dir"/*.gz 2>/dev/null | wc -l)
    if [ $count != 0 ]
    then
        echo "gz file found for adding node data to"
    else
        echo "No gzip files available to use for adding node data"
        exit
    fi
else
    echo "No $PT_output_dir directory exists to dump files"
    exit
fi

# See if there is already a pe_nodes directory in the output directory and if not let's create it
if [ ! -d "$PT_output_dir/pe_nodes/" ]
then
    mkdir -p "$PT_output_dir/pe_nodes/" || fail "pe_nodes directory failed to create"
fi

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

echo " ** Collecting Output of: Number of Total Nodes"
echo ""

# Getting all nodes listed in the database that are active and count them.
# Get the count of active nodes by environment 
puppet query "nodes[count()]{node_state = 'active'}" >> $output_nodes_file
puppet query "nodes [facts_environment, count()]{node_state = 'active' group by facts_environment }" >> $output_nodes_file

echo " ** Collecting Output of: Number and Type of Total Linux Nodes"
echo ""

# Count all nodes by Linux OS and get node name and OS version
puppet query "inventory [count()] { facts.kernel = 'Linux' and facts.aio_agent_build is not null}" >> $output_nodes_file
puppet query "inventory[certname, facts.os.name, facts.os.release.full] {facts.kernel = 'Linux' and facts.aio_agent_build is not null}" >> $output_nodes_file

# sed -i 's/]\[/],\[/' $output_nodes_file

echo " ** Collecting Output of: Number and Type of Total Windows Nodes"
echo ""

# Count all nodes by Windows OS and get node name and OS version
puppet query "inventory [count()] { facts.kernel = 'windows' and facts.aio_agent_build is not null}" >> $output_nodes_file
puppet query "inventory[certname, facts.os.windows.product_name] {facts.kernel = 'windows' and facts.aio_agent_build is not null}" >> $output_nodes_file

# Just putting some commas in between arrays, TODO: need to better format the json coming out
sed -i 's/]\[/],\[/' $output_nodes_file