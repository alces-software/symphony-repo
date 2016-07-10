#!/bin/bash -x

. /etc/symphony.cfg

PUPPET=1

############# START PUPPET ###################
if [ $PUPPET -gt 0 ]; then
  puppet agent -t --environment=symphony
fi
############# END PUPPET #####################
