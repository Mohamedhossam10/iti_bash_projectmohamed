#! /usr/bin/bash
if [ -z "$(ls -A `pwd`)" ]; then
    echo "no databases yet"
else
    ls -F | grep -v "metadata" 
fi
