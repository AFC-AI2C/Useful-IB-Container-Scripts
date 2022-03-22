#! /bin/bash

# Terminal Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

# Converts command line arguments (the images) into a list/array
images=( "$@" )

# Test commands against image
for image in "${images[@]}"; do
    # # Removes existing report files
    # rm -f ./$ReportDir/stderr_$image.txt
    # rm -f ./$ReportDir/stderr_$image.txt

    test_cmd_file="./test.txt"
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
    fi
done
