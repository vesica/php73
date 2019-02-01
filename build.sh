#!/bin/bash

## Release tag / version. If this is not for a specific release, please set this to latest, otherwise set it to a specific release.
version=6

###########################################################################################
#UNLESS YOU WANT TO CHANGE SOMETHING TO DO WITH THE PUSH TO NEXUS, LEAVE THE BELOW ALONE #
###########################################################################################
## The URL of the repo. Do not change unless you're sure about this.
prod=vesica/php72:$version
dev=vesica/php72:dev
latest=vesica/php72:latest

## The actual script to build and push the image
echo "Building production image"
docker build -f Dockerfile . -t $prod
docker push $prod

echo "Building development image"
docker build -f Dockerfile.dev . -t $dev
docker push $dev

if [ "$version" != "latest" ]
    then
        docker build -f Dockerfile . -t $latest
        docker push $latest
    fi
