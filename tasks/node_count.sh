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

# Variables for using to output data to and use in code
peversion=$(cat /opt/puppetlabs/server/pe_version)
nodecount_file="$output_dir/pe_nodes/activenodecount.json"
nodecountenv_file="$output_dir/pe_nodes/nodecount_byenv.json"
nixcount_file="$output_dir/pe_nodes/nixnodecount.json"
nixosinfo_file="$output_dir/pe_nodes/nixosinfo.json"
wincount_file="$output_dir/pe_nodes/winnodecount.json"
winosinfo_file="$output_dir/pe_nodes/winosinfo.json"

#Extract the puppet db server url for use in curl commands
pdbsrvrurl=$(awk '/server_url/{print $NF}' /etc/puppetlabs/puppet/puppetdb.conf | awk -v FS=, '{print $1}')
pdbsrvrname=$(echo ${pdbsrvrurl} | awk -F[/:] '{print $4}')
securecon="--tlsv1 --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem --cert /etc/puppetlabs/puppet/ssl/certs/${pdbsrvrname}.pem --key /etc/puppetlabs/puppet/ssl/private_keys/${pdbsrvrname}.pem"

if [[ $peversion = *"2019"* || $peversion = *"2021"* || $peversion = *"2023" ]]
then
    #Variable for agent versions file
    agentversions="$output_dir/pe_nodes/agentversions.json"

    # Ensure pathing is set to be able to run puppet commands
    # [[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

    echo " ** Collecting Output of: Number of Total Nodes"
    echo ""

    # Getting all nodes listed in the database that are not deactivated and count them.
    # Get the count of active nodes by environment 
    curl -X GET $pdbsrvrurl/pdb/query/v4/nodes $securecon --data-urlencode 'query=["extract", [["function","count"]],["null?", "deactivated", true]]' > $nodecount_file
    curl -X GET $pdbsrvrurl/pdb/query/v4/nodes $securecon --data-urlencode 'query=["extract", [["function","count"], "facts_environment"], ["null?", "deactivated", true], ["group_by", "facts_environment"]]' > $nodecountenv_file

    echo " ** Collecting Output of: Number and Type of Total Linux Nodes"
    echo ""

    # Count all nodes by Linux OS and get node name and OS version.  Deactivated nodes are not included by default
    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", [["function", "count"]], ["=", "facts.kernel", "Linux"]]' > $nixcount_file
    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", ["certname", "facts.os.name", "facts.os.release.major"],["=", "facts.kernel", "Linux"]]' > $nixosinfo_file
    
    echo " ** Collecting Output of: Number and Type of Total Windows Nodes"
    echo ""

    # Count all nodes by Windows OS and get node name and OS version. Deactivated nodes are not included by default
    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", [["function", "count"]], ["=", "facts.kernel", "windows"]]' > $wincount_file
    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", ["certname", "facts.os.windows.product_name"],["=", "facts.kernel", "windows"]]' > $winosinfo_file

    # Get Agent Versions by OS and Count them by OS - dot notation for individual extraction available in puppetdb 6.7 and later which is PE 2019.2.1 and later
    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", [["function", "count"], "facts.puppetversion", "facts.operatingsystem", "facts.operatingsystemrelease"], ["group_by", "facts.puppetversion","facts.operatingsystem", "facts.operatingsystemrelease"]]' > $agentversions

elif [[ $peversion = *"2018"* || $peversion = *"2017"* ]]
then
    echo "version of PE is $peversion"
    # Getting all nodes listed in the database that are active and count them.
    # Get the count of active nodes by environment 
    curl -X GET $pdbsrvrurl/pdb/query/v4/nodes $securecon --data-urlencode 'query=["extract", [["function","count"]],["null?", "deactivated", true]]' > $nodecount_file
    curl -X GET $pdbsrvrurl/pdb/query/v4/nodes $securecon --data-urlencode 'query=["extract", [["function","count"], "facts_environment"], ["null?", "deactivated", true], ["group_by", "facts_environment"]]' > $nodecountenv_file

    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", [["function", "count"]], ["=", "facts.kernel", "Linux"]]' > $nixcount_file
    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", [["function", "count"]], ["=", "facts.kernel", "windows"]]' > $wincount_file

    #Variable for linux agent versions file
    nixagentversions="$output_dir/pe_nodes/nixagentversions.json"
    curl -X GET $pdbsrvrurl/pdb/query/v4/facts $securecon  --data-urlencode 'query=["extract", [["function", "count"], "value"], ["and", ["=", "name", "puppetversion"], ["subquery", "facts", ["and", ["=", "name", "kernel"],["=", "value", "Linux"]]]], ["group_by", "value"]]' > $nixagentversions

    #Variable for linux agent versions file
    winagentversions="$output_dir/pe_nodes/winagentversions.json"
    curl -X GET $pdbsrvrurl/pdb/query/v4/facts $securecon  --data-urlencode 'query=["extract", [["function", "count"], "value"], ["and", ["=", "name", "puppetversion"], ["subquery", "facts", ["and", ["=", "name", "kernel"],["=", "value", "windows"]]]], ["group_by", "value"]]' > $winagentversions

elif [[ $peversion = *"2016"* ]]
then
    echo "version of PE is $peversion"
    # Getting all nodes listed in the database that are active and count them.
    # Get the count of active nodes by environment 
    curl -X GET $pdbsrvrurl/pdb/query/v4/nodes $securecon --data-urlencode 'query=["extract", [["function","count"]],["null?", "deactivated", true]]' > $nodecount_file
    curl -X GET $pdbsrvrurl/pdb/query/v4/nodes $securecon --data-urlencode 'query=["extract", [["function","count"], "facts_environment"], ["null?", "deactivated", true], ["group_by", "facts_environment"]]' > $nodecountenv_file

    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", [["function", "count"]], ["=", "facts.kernel", "Linux"]]' > $nixcount_file
    curl -X GET $pdbsrvrurl/pdb/query/v4/inventory $securecon --data-urlencode 'query=["extract", [["function", "count"]], ["=", "facts.kernel", "windows"]]' > $wincount_file
    
else
    echo "Wrong version of PE for this task"
fi
