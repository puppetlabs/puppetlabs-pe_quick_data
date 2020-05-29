#!/bin/bash

# Determining if there is an output directory and if there is looking for a gz file to use to zip directories to
if [ -d $PT_output_dir ]
then
    output_dir=$PT_output_dir
    output_dir+="/pe_quick_data"
    output_file="$output_dir/pe_quick_data.txt"
    support_script_output_file="$output_dir/support_script_output.log"
    count=$(ls -1 "$output_dir"/*.gz 2>/dev/null | wc -l)
    if [ $count != 0 ]
    then
        gzfile=$(ls -t "$output_dir"/*.gz | head -n1)
    else
        echo "No gzip files available to use for adding node data"
        exit
    fi
else
    echo "No $output_dir directory exists to dump files"
    exit
fi

# Decompressing the zip file we found
gzip -d "${gzfile}"

# Get the name of the gz file with the filename and tar extension
base_tarfile=$(basename $gzfile .gz)

# Setting path for tar file to append to
new_tarfile="$output_dir"
new_tarfile+="/"
new_tarfile+="$base_tarfile"

# Ensure we are in the output directory
cd "${output_dir}"

# Getting directories in the output directory to use for appending to the tar file
currentdirs=$(ls -d */)

# Appending the directories in the output directory to the tar file and zipping
tar -rf "${new_tarfile}" $currentdirs
gzip "${new_tarfile}"

# Remove all directories in the output directory leaving only remaining gz file(s)
rm -rf $currentdirs
