#!/bin/bash

. ~/.bashrc
export LD_LIBRARY_PATH=$HOME/omrepo/q/zlib-1.2.8:$LD_LIBRARY_PATH
export QHOME=$HOME/omrepo/q
cd $HOME/omrepo/q
#./l32/q -p 8765 -u pwd
nohup ./l32/q ../getOptionsData.q -p 8766 -u pwd  > $HOME/omrepo/q/getOptionsData.log 2>&1 
