#!/bin/bash

. ~/.bashrc
export LD_LIBRARY_PATH=$HOME/omrepo/q/zlib-1.2.8:$LD_LIBRARY_PATH
export QHOME=$HOME/omrepo/q
cd $HOME/q
#./l32/q -p 8765 -u pwd
nohup ./l32/q ../getOptionsData.q -p 8765 -u pwd  > $HOME/ompreo/q/getOptionsData.log 2>&1 
