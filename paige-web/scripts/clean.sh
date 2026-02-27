#!/bin/bash

echo Removing locks...
rm -f package-lock.json

echo Removing packages...
rm -rf node_modules

echo Removing build files...
rm -rf .angular
rm -rf dist
rm -rf reports

echo
read -p "Install NPM Packages? [Y/y]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo
    echo Installing packages...
    npm i
fi