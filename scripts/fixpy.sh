#!/bin/bash

set -eu

MIRTKDIR=$1

for TOOL in $(find $MIRTKDIR/lib/tools/ -exec file {} \; | grep text | cut -d: -f1) $MIRTKDIR/bin/mirtk; do
    if [[ $(head -n1 $TOOL) == *"python" ]]; then
        sed -i '1 c#! /usr/bin/env python' $TOOL && echo "Fixed: $TOOL";
    fi
done
