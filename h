#!/bin/bash

# curl -s -L https://raw.githubusercontent.com/paoloantinori/hhighlighter/master/h.sh > /usr/local/bin/h.sh
source /dev/stdin <<<"$(sed -e 's/h()/hhighlighter()/' /usr/local/bin/h.sh)"
hhighlighter $*
