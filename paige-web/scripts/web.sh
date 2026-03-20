#!/bin/bash

clear
cd /Users/RHMG/Documents/Projects/ccoe/paige-web || exit

# Check for "update" parameter
if [[ "$1" == "update" ]]; then
    echo
    read -p "Clean files? [Y/y]" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "🗑️  Removing packages..."
        rm -rf node_modules

        echo "🗑️  Removing build files..."
        rm -rf .angular
        rm -rf dist
        rm -rf reports
    fi

    echo
    echo "📦  Updating packages..."
    rm -f package-lock.json
    npm i

    echo
    read -p "Run fix? [Y/y]" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "🔄  Running audit fix..."
        npm audit fix
    fi

    echo
fi

echo "🚀  Launching Web..."
ng serve paige -o

## Other runtime options ##
# ng serve dash -ssl -o
# ng serve -o
# ng serve --ssl -o
# ng serve --verbose
# ng serve --proxy-config proxy.conf.json -o
