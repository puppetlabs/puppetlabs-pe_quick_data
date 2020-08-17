#!/bin/bash

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# Retrieving environmentpaths and setting in a variable to iterate through gathering module data for each environment
codedirs=$(puppet config print environmentpath --section master | sed 's/:/ /g')

# Listing out environments directories based on PE master environmentpath and if environments directories exist moving on to see 
# if there are module folders in the environments
# Exit out if there are no environments directories 
if [[ $codedirs ]]
then

    # We're determining if an output directory exists on the host.
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
            # Set log file for some output
            pe_quick_data_log="$output_dir/pe_quick_data.log"
            exec 2>>$pe_quick_data_log
        else
            output_dir="$PT_output_dir"
            output_dir+="/"
            output_dir+="pe_quick_data"
            # Set log file for some output
            pe_quick_data_log="$output_dir/pe_quick_data.log"
            exec 2>>$pe_quick_data_log
        fi

    else
        echo "No $PT_output_dir directory exists to dump files"
        exit
    fi
    
    # See if there is already a pe_site-modules directory in the output directory and if not let's create it
    if [ ! -d "$output_dir/pe_site-modules/" ]
    then
        mkdir -p "$output_dir/pe_site-modules/"
    fi

    # Setting file variables for output of data
    output_site_modules_file="$output_dir/pe_site-modules/site_modules.txt"
    site_modules_json="$output_dir/pe_site-modules/site_modules.json"

    # Start of logging for module collection in the pe_quick_data.log file
    echo $(date +'%F %T') " | Started collection of site_modules" >> $pe_quick_data_log

    echo "[" >> $site_modules_json # Setting the start point for json type output

    # *******   Begin scripting for finding global modules *******

    # Variable to set global modules location as part of Puppet installation
    globalmods="/etc/puppetlabs/code/modules"

    if [[ -d $globalmods ]] # If the global module directory exist we are then determining if there are modules n the directory
    then 
        lsglobalmods=$(ls -1 $globalmods) # Set variable to get modules in the global modules directory, if they exist
        if [[ -z $lsglobalmods ]] # If the lsglobalmods variable is empty we'll note in the log and output files
        then
            echo $(date +'%F %T') " | No modules found in $globalmods" >>$pe_quick_data_log
            echo "**** ${globalmods} has 0 modules in its directory ****" >> $output_site_modules_file
            echo >> $output_site_modules_file
        else # If the lsglobalmods variables is not empty we capture the modules and count them then output the information to output file
            echo $(date +'%F %T') " | Found modules for $globalmods" >>$pe_quick_data_log
            globalmodcnt=$(echo "${lsglobalmods}" | wc -l) # Here we count the number of modules in the global modules directory
            
            for globalmod in $lsglobalmods
            do
                # Set variables to zero before counting below
                globalrolecount=0
                globalprofilecount=0

                # Use modrole variable for capturing if role directory is in the site-modules directory
                globalmodrole=false
                
                # Use modrole variable for capturing if role directory is in the site-modules directory
                globalmodprofile=false
                
                if [[ $globalmod = "role" ]] # if the module is named role
                then
                    globalmodrole=true # set the variable to indicate that roles may be defined
                    globalrolenames=$(find $globalmods/$globalmod/manifests -name *.pp) # find the roles defined in the module
                    globalrolecount=$(ls -1 $globalrolenames | wc -l) # count the roles in the module
                fi

                if [[ $globalmod = "profile" ]] # if the module is named profile
                then
                    globalmodprofile=true # set the variable to indicate that profile may be defined
                    globalprofnames=$(find $globalmods/$globalmod/manifests -name *.pp) # find the profiles defined in the module
                    globalprofilecount=$(ls -1 $globalprofnames | wc -l) # count the profiles in the module for output
                fi
            done
            
            # Outputt to the site_modules.json and sitemodules.txt files the echos below
            echo "{ \"global\" : " >> $site_modules_json
            echo "     { \"${globalmods}\": $globalmodcnt, \"role\": $globalmodrole, \"rolecount\": $globalrolecount, \"profile\": $globalmodprofile, \"profilecount\": $globalprofilecount}" >> $site_modules_json
            echo "}," >>$site_modules_json

            echo "**** ${globalmods} has $globalmodcnt modules in its directory ****" >> $output_site_modules_file
            echo >> $output_site_modules_file
            echo "${lsglobalmods}" >> $output_site_modules_file
            echo >> $output_site_modules_file
        fi
    else # if no modules found in globalcodemods directory log and indicate in the site_modules.txt file
        echo $(date +'%F %T') " | No modules directory found at location $globalmods" >>$pe_quick_data_log
        echo "**** ${globalmods} does not exist to store modules ****" >> $output_site_modules_file
        echo >> $output_site_modules_file
    fi

    # *******    End find global modules code    *******
    
    # *******   Begin scripting for finding Puppet Enterprise modules *******

    # Variable to Puppet Enterprise modules location as part of Puppet installation
    pemods="/opt/puppetlabs/puppet/modules"

    if [[ -d $pemods ]] # If the PE module directory exist we are then determining if there are modules in the directory
    then 
        lspemods=$(ls -1 $pemods) # Set variable to get modules in the pe modules directory, if they exist
        if [[ -z $lspemods ]] # If the lspemods variable is empty we'll note in the log and output files
        then
            echo $(date +'%F %T') " | No modules found in $pemods" >>$pe_quick_data_log
            echo "**** ${pemods} has 0 modules in its directory ****" >> $output_site_modules_file
            echo >> $output_site_modules_file
        else # If the lspemods variables is not empty we capture the modules and count them then output the information to output file
            echo $(date +'%F %T') " | Found modules for $pemods" >>$pe_quick_data_log
            pemodcnt=$(echo "${lspemods}" | wc -l) # Here we count the number of modules in the pe modules directory
            
            for pemod in $lspemods
            do
                # Set variables to zero before counting below
                perolecount=0
                peprofilecount=0

                # Use modrole variable for capturing if role directory is in the site-modules directory
                pemodrole=false
                
                # Use modrole variable for capturing if role directory is in the site-modules directory
                pemodprofile=false
                
                if [[ $pemod = "role" ]] # if the module is named role
                then
                    pemodrole=true # set the variable to indicate that roles may be defined
                    perolenames=$(find $pemods/$pemod/manifests -name *.pp) # find the roles defined in the module
                    perolecount=$(ls -1 $perolenames | wc -l) # count the roles in the module
                fi

                if [[ $pemod = "profile" ]] # if the module is named profile
                then
                    pemodprofile=true # set the variable to indicate that profile may be defined
                    peprofnames=$(find $pemods/$pemod/manifests -name *.pp) # find the profiles defined in the module
                    peprofilecount=$(ls -1 $peprofnames | wc -l) # count the profiles in the module for output
                fi
            done
            
            # Outputt to the site_modules.json and sitemodules.txt files the echos below
            echo "{ \"pe\" : " >> $site_modules_json
            echo "     { \"${pemods}\": $pemodcnt, \"role\": $pemodrole, \"rolecount\": $perolecount, \"profile\": $pemodprofile, \"profilecount\": $peprofilecount}" >> $site_modules_json
            echo "}," >>$site_modules_json

            echo "**** ${pemods} has $pemodcnt modules in its directory ****" >> $output_site_modules_file
            echo >> $output_site_modules_file
            echo "${lspemods}" >> $output_site_modules_file
            echo >> $output_site_modules_file
        fi
    else # if no modules found in pecodemods directory log and indicate in the site_modules.txt file
        echo $(date +'%F %T') " | No modules directory found at location $pemods" >>$pe_quick_data_log
        echo "**** ${pemods} does not exist to store modules ****" >> $output_site_modules_file
        echo >> $output_site_modules_file
    fi

    # *******    End find Puppet Enterprise modules code    *******

    # *******    Begin code to iterate through codedirs variable for environments and find modules to output information to output files

    # For loop to loop through the different environments locations and find modules for each.
    for dir in $codedirs
    do 
        codeenvs=$(ls -1 $dir) # We are listing out the environments under the individual code directory specified in loop $dir
        
        # For loop to iterate through each environment and determine modules existence, count them, and dump to text file
        for peenv in $codeenvs
        do
            # Add to peenvcount environment count as we enter the statement
            ((peenvcount=peenvcount+1))
            
            # Set variable envpath to the path of the environment we are working with
            envpath="$dir/$peenv"
            moddirs=$(puppet config print modulepath --section master --environment $peenv | sed 's/:/ /g' |\
            sed 's/\/etc\/puppetlabs\/code\/modules//' | sed 's/\/opt\/puppetlabs\/puppet\/modules//')
           
            cntmoddir=0 # This variable counts all modules in the env modulepath to use with formatting json below
            for nummods in $moddirs
            do
                ((cntmoddir=cntmoddir+1)) # Counting total number of modules for json formatting at the end of the script
            done

            # Determine if the environment path has any modules directory and echo that no directory was found if not or move on
            if [ ! "$moddirs" ]
            then
                echo "   No module paths found for $peenv located at $envpath" >> $pe_quick_data_log # Logging to pe_quick_data.log
            else
                echo $(date +'%F %T') " | Found modules for $peenv located at $envpath" >> $pe_quick_data_log # Logging to pe_quick_data.log
                echo "{ "\"${peenv}\"" : " >> $site_modules_json
                
                #Before entering the module directory for the specific environment we set a counter for use to format json better
                countmoddir=0
                rolecount=0
                profilecount=0

                for moddir in $moddirs
                do
                    ((countmoddir=countmoddir+1)) # Counting module directories in the modulepath for the environment to format json
                    
                    # Capture the modules in the environment into a variable mods
                    if [[ $(ls -1 $moddir) ]]
                    then
                        mods=$(ls -1 $moddir)
                    else
                        echo $(date +'%F %T') " | No modules found for $moddir" >>$pe_quick_data_log
                    fi
                    
                    # Set a modcount counter to zero for using to count the number of site-modules
                    modcount=0
                    
                    # Use modrole variable for capturing if role directory is in the site-modules directory
                    modrole=false
                    
                    # Use modrole variable for capturing if role directory is in the site-modules directory
                    modprofile=false

                    # Iterate through the modules to count them, determine if role and profile directories exist and set to true if they do
                    for mod in $mods
                    do
                        ((modcount=modcount+1)) # Counting the number of modules for the environment as we iterate through the modules
                        
                        if [[ $mod = "role" ]]
                        then
                            modrole=true
                            rolenames=$(find $moddir/$mod/manifests -name *.pp)
                            rolecount=$(ls -1 $rolenames | wc -l)
                        fi

                        if [[ $mod = "profile" ]]
                        then
                            modprofile=true
                            profnames=$(find $moddir/$mod/manifests -name *.pp)
                            profilecount=$(ls -1 $profnames | wc -l)
                        fi

                    done
                
                    # If there are no modules set the modcount to string 0 to print to file
                    # Output of module information to the site-modules file
                    if [[ -z ${modcount+x} ]]
                    then 
                        modcount="0"
                        echo "**** ${peenv} has $modcount modules in the ${moddir} directory ****" >> $output_site_modules_file
                        echo >> $output_site_modules_file
                    else # any modules that exist in site-modules will be sent to the site-modules file output
                        echo "**** ${peenv} has $modcount modules in the ${moddir} directory ****" >> $output_site_modules_file
                        echo >> $output_site_modules_file
                        echo "${mods}" >> $output_site_modules_file
                        echo >> $output_site_modules_file
                    fi
                    
                    # Output of the Puppetfile to the roles_and_profiles.txt file
                    echo "**** ${peenv} Puppetfile Contents ****" >> $output_site_modules_file
                    cat $envpath/Puppetfile >> $output_site_modules_file
                    echo >> $output_site_modules_file

                    # Send information for site-modules count, and whether role and profile directories exist counts to the site_modules.json file for output
                    if [ $countmoddir -ne $cntmoddir ] # counting the number of environments for use on determining whether a comma is needed on the last entry
                    then    
                        # echo "The moddir count is $countmoddir."
                        if [[ rolecount -eq 0 || profilecount -eq 0 ]]
                        then
                            echo "    { \"${moddir}\": $modcount, \"role\": $modrole, \"profile\": $modprofile}," >> $site_modules_json
                        else
                            echo "    { \"${moddir}\": $modcount, \"role\": $modrole, \"rolecount\": $rolecount, \"profile\": $modprofile, \"profilecount\": $profilecount}," >> $site_modules_json
                        fi
                    else
                        echo "    { \"${moddir}\": $modcount, \"role\": $modrole, \"profile\": $modprofile}}" >> $site_modules_json
                        echo "}," >> $site_modules_json
                    fi

                    unset rolecount
                    unset profilecount
                    unset mods
                    unset modcount

                done
            fi
        done     
                
        unset modcount
        unset envpath

    done
    echo "]" >> $site_modules_json
    echo $(date +'%F %T') " | Stopped collection of site_modules" >> $pe_quick_data_log
else
    echo "No environments found" >> $pe_quick_data_log
    exit
fi