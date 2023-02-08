#!/bin/bash

set -eu

DIRS=$@

for TOOL in $(find ${DIRS[@]} -exec file {} \; | grep text | cut -d: -f1); do
    if [[ $(head -n1 $TOOL) == *"python"* ]]; then
        sed -i '1 c#! /usr/bin/env python' $TOOL && echo "Fixed: $TOOL";
    fi
done
