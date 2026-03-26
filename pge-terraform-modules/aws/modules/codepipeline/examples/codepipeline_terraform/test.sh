

#!/bin/sh
#echo "Hello world"

string='My - long string'
if [[ $string == *"My long"* ]]; then
  echo "It's there!"
else
  echo "its not theere"
fi

