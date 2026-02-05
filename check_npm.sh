#!/bin/bash
if ! command -v npm &> /dev/null
then
    echo "npm could not be found. Please install npm to ensure pyright and other servers can be installed."
else
    echo "npm is installed: $(npm --version)"
fi
