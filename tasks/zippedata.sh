#!/bin/bash

if [ -d $PT_output_dir ]
then
    count=$(ls -1 "$PT_output_dir"/*.gz 2>/dev/null | wc -l)
    if [ $count != 0 ]
    then
        gzfile=$(ls -t "$PT_output_dir"/*.gz | head -n1)
        # #Set the path to the gzip file we are going to use to add this data to
        # output_gz_file="$PT_output_dir"
        # output_gz_file+="/"
        # output_gz_file+="$gzfile"
    else
        echo "No gzip files available to use for adding node data"
        exit
    fi
else
    echo "No $PT_output_dir directory exists to dump files"
    exit
fi

echo ${gzfile}

gzip -d "${gzfile}"

base_tarfile=$(basename $gzfile .gz)

echo $base_tarfile

new_tarfile="$PT_output_dir"
new_tarfile+="/"
new_tarfile+="$base_tarfile"

echo $new_tarfile

cd "${PT_output_dir}"
currentdirs=$(ls -d */)

tar -rf "${new_tarfile}" $currentdirs
gzip "${new_tarfile}"

rm -rf $currentdirs
