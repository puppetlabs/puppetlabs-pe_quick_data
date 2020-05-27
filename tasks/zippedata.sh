#!/bin/bash

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

gzip -d "${output_gz_file}"

base_tarfile=$(basename $output_gz_file .gz)

new_tarfile="$PT_output_dir"
new_tarfile+="/"
new_tarfile+="$base_tarfile"

cd "${PT_output_dir}"

tar -rf "${new_tarfile}" "pe_roles_and_profiles"
gzip "${new_tarfile}"