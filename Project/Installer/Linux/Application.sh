#!/bin/bash

if [ -z "$LD_LIBRARY_PATH" ]; then
        export LD_LIBRARY_PATH=%lib%
else
        export LD_LIBRARY_PATH=%lib%:$LD_LIBRARY_PATH
fi

%path% $*


