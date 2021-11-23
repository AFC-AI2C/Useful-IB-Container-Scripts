#!/bin/bash

clear

# Terminal Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

function helpmenu {
    echo -e "\n${red}Usage:\n${reset}$0 parent_image child_image grandchild_image ..etc"
    echo -e "       -h   --help       Shows help"
    echo -e "       -v   --verbose    Verbose mode"
    echo -e "\n${red}Notes:${reset}"
    echo -e "The image names should be the same as its directory name"
    echo -e "The version specified below is the same throughout the Dockerfiles"
    echo -e "This script should be ran from the partent dir common to the those that have Dockerfiles"
    echo -e "\n${red}hardening_manifest.yaml${reset} needs to be in the same dir at the Dockerfile"
    echo -e "- this file is parsed to download any dependencies"
    echo -e "\n${red}test_commands.txt${reset} needs to be in the same dir as the Dockerfile"
    echo -e "- this file contains one command per line to run against an image"
    echo -e "- sample test commands:"
    echo -e "    wget www.google.com"
    echo -e "    netstat"
    echo -e "    python3.6 -c 'import plotly'"
    echo -e "\n${red}Examples:${reset}"
    echo -e "./Build-DockerImageTree.sh parent_image child_image grandchild_image ..etc"
    echo -e "./Build-DockerImageTree.sh python36-ai jlab-eda jlab-dl jlab-cv\n"
    exit 0
}
# Simple Help switches/arguments
if [ -z "$*" ]; then
    helpmenu
fi
for arg in $@; do
    if [[ ($arg == "-h") || ($arg == "--help") ]]; then
       helpmenu
fi
done


# Converts command line arguments (the images) into a list/array
images=( "$@" )

version='latest'

# # Creates directory if it does not exist
# ReportDir='docker_build_reports'
# if [ ! -d "$ReportDir" ]; then
#     echo -e "\n${red}[!]${green} Creating Directory...  $ReportDir${reset}"
#     mkdir ./$ReportDir
# fi

echo -e "\n${yellow}================================================================================${reset}"

# iterates through list and builds images
# reports are saved to the above directory 
for image in "${images[@]}"; do
    # Parses hardening_manifest.yaml and download packages to the image's docker directory
    echo -e "\n${red}[!]${green} Checking hardening_manifest for packages${reset}"
    hardening_manifest=$(cat ./$image/hardening_manifest.yaml | grep ' filename:' -A 4)
    IFS=; while read -r FileName; do 
        #echo "$FileName"
        PackageURL=$(echo "$FileName" | grep ' url:' | tr -s ' ' | cut -d ' ' -f 3)
        #echo "$PackageURL"
        PackageName=$(echo "$PackageURL" | rev | cut -f -1 -d '/' | rev)
        #echo "$PackageName"
        if [[ $(ls ./$image/$PackageName) ]]; then 
            #echo "./$image/$PackageName"
            for arg in $@; do
                if [[ ($arg == "-v") || ($arg == "--verbose") ]]; then
                    echo -e "    - Package already exists...  $PackageName${reset}"                    
                fi
            done
            #echo '----------------------------------'
            ManifestHash=$(echo "$FileName" | grep ' value:' | tr -s ' ' | cut -d ' ' -f 3)
            #echo "$ManifestHash"
            PackageHash="$(sha256sum ./$image/$PackageName | cut -d ' ' -f 1)"
            #echo "$PackageHash"
            #echo -e "$ManifestHash=====$PackageHash"
            #if ( $ManifestHash == $PackageHash ); then
            #    echo 'Yes--------'
            #else
            #    echo 'no'
            #fi
        else
            echo -e "    - Downloading package...  ${yellow}$PackageURL${reset}"
            curl --location --url $PackageURL --output ./$image/$PackageName
        fi 2> /dev/null
    done <<< $hardening_manifest


#    # Removes any existing test builds; helps keep docker image listing clean
#    echo -e "\n${red}[!]${green} Checking for any removing previous test builds${reset}"
#    if docker images | grep "^$image\b" | grep "$version"; then
#        echo -e "    - Removing previous test build...${yellow}  $image:$version${reset}"
#        docker images | grep "^$image\b" | grep "$version" && docker rmi "$image:$version" -f
#    fi


    # Builds the image(s) 
    echo -e "\n${red}[!]${green} Attempting to build image...${yellow}  $image:$version${reset}"
    docker build -t "$image:$version" ./"$image"


    # Checkes if image is built or not and provides message
    if [[ $(docker images | grep "^$image\b" | grep "$version") ]]; then 
        echo -e "\n${red}[!]${green} Image was successfully built!${reset}"
    else 
        echo -e "\n${red}[!]${green} Image failed to build - view error report in:${yellow} $ReportDir${reset}"
    fi

    echo -e "\n${yellow}================================================================================${reset}"

done

echo -e ' '
echo -e "${red}[!]${green} Images successfully created:${reset}"

# Lists the docker images created
for image in "${images[@]}"; do
    docker images | grep "^$image\b" | grep "$version"
done

echo -e "\n${yellow}================================================================================${reset}\n"

# Test commands against image
for image in "${images[@]}"; do
    # # Removes existing report files
    # rm -f ./$ReportDir/stderr_$image.txt
    # rm -f ./$ReportDir/stderr_$image.txt

    test_cmd_file="./$image/test_commands.txt"
    if test -f "$test_cmd_file"; then    
        image_id=$(docker images | grep "^$image\b" | grep "$version" | tr -s ' ' | cut -d ' ' -f 3)

        echo -e "${red}[!]${reset} Testing commands aginst image:${yellow}  $image${reset}"
        test_commands=$(cat $test_cmd_file)
        while IFS= read -r cmd; do

            # runs each command against the docker image and creates logs 
            test_cmd="docker run --rm $image_id $cmd"
            eval "$test_cmd" 2&>1 /dev/null #2>> ./$ReportDir/stderr_$image.txt 1>> ./$ReportDir/stdout_$image.txt
            
            # Set text color if eval code is successful or not (exit code 0)
            if [ "$?" == "0" ]; then
                echo -e "    - ${green}$cmd${reset}"
            else
                echo -e "    - ${red}$cmd  ${yellow}[View Error Log:  ./$ReportDir/stderr_$image.txt]${reset}"
            fi
        done <<< $test_commands
    fi
done

echo -e "\n${yellow}================================================================================${reset}\n"



