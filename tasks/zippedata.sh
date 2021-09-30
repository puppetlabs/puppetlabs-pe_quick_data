#!/bin/bash

declare PT__installdir
source "$PT__installdir/pe_quick_data/files/common.sh"

# Determining if there is an output directory and if there is looking for a gz file to use to zip directories to
if [ -d $PT_output_dir ]
then
    output_dir=$PT_output_dir
    output_dir+="/pe_quick_data"
    output_file="$output_dir/pe_quick_data.txt"
    support_script_output_file="$output_dir/support_script_output.log"
    pe_quick_data_log="$output_dir/pe_quick_data.log"
    count=$(ls -1 "$output_dir"/*.gz 2>/dev/null | wc -l)
    if [ $count != 0 ]
    then
        gzfile=$(ls -t "$output_dir"/*.gz | head -1)
    else
        echo "No gzip files available to use for adding node data"
        exit
    fi
else
    echo "No $output_dir directory exists to dump files"
    exit
fi

shopt -s extglob

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
# !(*tar|*gz) to exclude any other previous .tar, .tar.gz, or .gz files from being included in the tar and gzip
tar -rf "${new_tarfile}" !(*tar|*gz) $currentdirs
gzip "${new_tarfile}"

# Remove all directories in the output directory leaving only remaining gz file(s) and the pe_quick_data.log file
rm -rf $currentdirs

# File name to use for download or in success function.   Adding the .gz extension
fileout="${new_tarfile}.gz"

# We are finding if the value of download is false and then returning the success function output if it is or printing the fileout variable as output for download
if [ $PT_download == false ]
then
    success "{ \"status\": \"Support data collect task complete. Please retrieve the file and work with your Puppet SE to send the data.\", \"file\": \"$fileout\" }"
else
    # Ensuring we can read the file to download with chmod
    sudo chmod 644 "${fileout}"
    printf "${fileout}"
fi