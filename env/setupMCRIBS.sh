#!/bin/bash

export PATH="/opt/MCRIBS/bin:/opt/MCRIBS/MIRTK/MIRTK-install/bin:/opt/MCRIBS/MIRTK/MIRTK-install/lib/tools:${PATH}"
export LD_LIBRARY_PATH="/opt/MCRIBS/lib:/opt/MCRIBS/ITK/ITK-install/lib:/opt/MCRIBS/VTK/VTK-install/lib:/opt/MCRIBS/MIRTK/MIRTK-install/lib:${LD_LIBRARY_PATH}"
export MCRIBS_HOME="/opt/MCRIBS" \
export PYTHONPATH="/opt/MCRIBS/lib/python:$PYTHONPATH"

if [[ -z "$FREESURFER_HOME" ]]; then
    echo "MCRIBS: missing FreeSurfer installation"
fi

if [[ -z "$FSLDIR" ]]; then
    echo "MCRIBS: missing FSL installation"
fi

# Allow arbitrary commands
$@
