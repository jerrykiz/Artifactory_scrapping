#!/bin/bash

###############################
# Variables for python script #
###############################

user=''
# EXAMPLE=> username

api=''
# EXAMPLE=> AKCp5e3KvXkna3LA9LHop7y768L...

repo=''
# EXAMPLE=> my-artifactory-repository

path=''
# EXAMPLE=> ABCD/CCD/GYTY-T1.1B_Work

# In $file_name _VERSION_ is the placeholder of the latest version
file_name=''
# EXAMPLE=> GYTY-T1.1B_Work_VERSION_+blob.zip

# Optional logfile path
logpath=''

# Optional download path
# If not specified, a search will only occur and the name of the file will be returned
download_path=''
# EXAMPLE=> /home/user/

###############################


##############################
# Variables for copying file #
##############################

# If true, specified file is being copied
copy_file=true
# EXAMPLE=> true

file_to_copy=''
# EXAMPLE=> file.txt

in_which_dir_to_copy=''
# EXAMPLE=> /home/user/

# Name of a new directory, in which you are going to copy the file
create_new_dir_name=''
# EXAMPLE=> new_folder

##############################


############################################################

###############################
if [ "$logpath" ];
    then
        log_var="-l ${logpath}"
else
    log_var=''
fi
###############################

####################################################
# Download file / Create new directory / Copy file #
####################################################
if [ -z "$download_path" ];
then
    filename=$(python get_latest.py -u $user -a $api -r $repo -p $path -f $file_name $log_var)
    echo $filename
else
    filename=$(python get_latest.py -u $user -a $api -r $repo -p $path -f $file_name -d $download_path)
    echo 'File successfully downloaded from Artifactory!'

    # Create a new directory if required
    if [ "$create_new_dir_name" ];
    then
        mkdir $in_which_dir_to_copy/$create_new_dir_name
    fi

    # Copy file from downloaded folder to new local folder
    if [ "$copy_file" ];
    then
        cp -r $filename/$file_to_copy $in_which_dir_to_copy/$create_new_dir_name/
        echo 'File successfully copied to specified directory!'
    fi
fi

########################################################