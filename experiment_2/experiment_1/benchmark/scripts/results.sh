#!/bin/bash

cd /tmp/ && gzip -d *.tab.gz
cd /tmp/ && gzip -d *.tab.gz
sudo cp *.tab /var/log/collectl/

