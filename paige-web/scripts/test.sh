#!/bin/bash

clear
cd /Users/RHMG/Documents/Projects/ccoe/paige-web || exit

echo "🚀  Launching Tests..."
npx jest --ci --runInBand
