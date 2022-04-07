#! /bin/bash
     
# Example:
#    test-docker-images-against-commands.sh <image_ID | image_name:tag>
#
# Note:
#    You must populate the test_commands.txt with the commands to run against the container.
#    Each command per line is executed against a fresh container of the image provided.
#    The test_commands.txt file must be in the same directory as this script.
#
# Usage:
#    !!! The script currently only supports 'local' images, as in do not include images with repo/project in their imagename, like
#    !!!      afcai2c/jlab-eda:latest
#    !!! This will cause errors, because when the results are output to file, this script uses the image name, and it trys to output the results to a non-existant directory
#    !!! Tag images with a simple name, for example:
#    !!!      docker tag afcai2c/jlab-eda:latest jlab-eda

# Terminal Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

# Converts command line arguments (the images) into a list/array
images=( "$@" )

# Test commands against image
for image in "${images[@]}"; do
    rm -f /tmp/stdout_$image.txt
    rm -f /tmp/stderr_$image.txt

    touch /tmp/stdout_$image.txt
    touch /tmp/stderr_$image.txt

    test_cmd_file="./test_commands.txt"
    if test -f "$test_cmd_file"; then
        #image_id=$(docker images | grep "^$image\b" | grep "$version" | tr -s ' ' | cut -d ' ' -f 3)

        echo -e "${red}[!]${reset} Testing commands aginst image:${yellow}  $image${reset}"
        test_commands=$(cat $test_cmd_file)
        while IFS= read -r cmd; do

            # runs each command against the docker image and creates logs
            test_cmd="docker run --rm $image $cmd"
            eval "$test_cmd" 2>> /tmp/stderr_$image.txt 1>> /tmp/stdout_$image.txt
	    #2&>1 /dev/null

            # Set text color if eval code is successful or not (exit code 0)
            if [ "$?" == "0" ]; then
                echo -e "    - ${green}$cmd${reset}"
            else
                echo -e "    - ${red}$cmd  ${yellow}[View Error Log:  /tmp/stderr_$image.txt]${reset}"
            fi
        done <<< $test_commands

        echo -e "${red}[!] ${reset}Successful std_out can be found at: ${yellow}[View Log:  /tmp/stdout_$image.txt]${reset}"
    fi
done
