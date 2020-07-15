#!/bin/bash
# A variance of the script used to collect puppet enterprise support for pe_tech_checks using the puppetlabs-pe_tech_check module
# Thanks to the Puppet support team for sharing

# Variables that need to be interpolated as part of the command won't show up here
# Should still be useful

_debug () {
  echo "DEBUG: running $@" >>"$_tmp.debug"
}

# Function to support what parameter/arguments to use with support collect $1 = argument to check for
has_opt() {
  grep -q -- "$1" "$_tmp_support"
}

declare PT__installdir
source "$PT__installdir/pe_quick_data/files/common.sh"

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

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
        if [[ $(ls -d "$output_dir"/*/) ]]
        then
          rmdirs=$(ls -d "$output_dir"/*/) # List directories under the pe_quick_data directory to delete on next line
          rm -rf $rmdirs # remove everything from the directory but .gz files to avoid directories being in the folder from other processes
        fi
    fi
    
    output_file="$output_dir/pe_quick_data.txt"
    support_script_output_file="$output_dir/support_script_output.log"

else
    echo "No $PT_output_dir directory exists create a pe_quick data folder and to dump files to"
    exit
fi

shopt -s nullglob extglob globstar || fail "This utility requires Bash >=4.0"
trap '_debug $BASH_COMMAND' DEBUG

(( $EUID == 0 )) || fail "This utility must be run as root"

# Use the appropriate version of the support script command
if version_gt $(puppet -V) "4.5.2"; then
  sup_cmd=(puppet enterprise support)
else
  export IS_DEBUG='y'
  sup_cmd=(puppet-enterprise-support)
fi

## Dump command help to a file in the interest of speed
_tmp_support="$(mktemp)"
"${sup_cmd[@]}" --help &>"$_tmp_support"

# Use enable_logs parameter to determine logging and add additional parameters to arguements for support output
case $PT_enable_logs in
    "true")
      has_opt '--log-age' && sup_args+=("--log-age" "3")
      has_opt '--classifier' && sup_args+=("--classifier")
      has_opt '--dir' && sup_args+=("--dir" "$output_dir")
      ;;
    "false")
      has_opt '--log-age' && sup_args+=("--log-age" "0")
      has_opt '--v3' && sup_args+=("--v3")
      has_opt '--disable' &&sup_args+=("--disable" "system.logs,puppet.logs,puppetserver.logs,puppetdb.logs,pe.logs,pe.console.logs,pe.orchestration.logs,pe.postgres.log")
      has_opt '--classifier' && sup_args+=("--classifier")
      has_opt '--dir' && sup_args+=("--dir" "$output_dir")
      ;;
esac

# Clone stdout, then redirect it to our output file for the following steps.
exec 3>&1
exec >>"$output_file"

echo "Puppet Enterprise Quick Data Check: $(date)"
echo

grep -i -v UUID /etc/puppetlabs/license.key

"${sup_cmd[@]}" "${sup_args[@]}" >"$support_script_output_file"

# If we don't have --dir, we'll need to find where the support script output landed
# Use globstar to find the newest file under /var/tmp and /tmp
if [[ ! ${sup_args[@]} =~ "--dir" ]]; then
  for f in /tmp/**/puppet_enterprise_support*gz /var/tmp/**/puppet_enterprise_support*gz; do
    [[ $f -nt $newest ]] && newest="$f"
  done

  [[ $newest ]] || fail "Error running support script"
  mv "$newest" "$output_dir"
fi

# Redirect stdout back to the original terminal/calling program
exec >&3

# Hack-ish, but we can tar everything into one file by unzipping, adding to the tarball, and zipping again
cd "$output_dir"
# We previously removed everything, so this should be the only .tar.gz
tarball=$(ls -t *.gz | head -1)
[[ -e $tarball ]] || fail "Error running support script"
gunzip "$tarball" || fail "Error building tarball"
tar uf "${tarball%*.gz}" !(*tar|*gz) "$_tmp" "$_tmp.debug" || fail "Error building tarball"
gzip "${tarball%*.gz}" || fail "Error building tarball"
rm !(*gz) || fail "Error building tarball"
cd - &>/dev/null

success \
  "{ \"status\": \"Support data collect task complete. Please retrieve the file and work with your Puppet SE to send the data.\", \"file\": \"${output_dir}/${tarball}\" }"