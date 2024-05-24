#!/bin/bash
BRANCH=`git rev-parse --abbrev-ref HEAD`
TAG="$BRANCH"

if [[ "$BRANCH" == "master" ]]; then
	TAG=latest
fi

exec docker buildx build . -t luksamuk/psxtoolchain:$TAG --push

