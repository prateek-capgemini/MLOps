#!/bin/bash

sudo su #############prateek#############

echo "pre reboot userdata"
sudo chmod 777 pre_reboot.sh
python3 pre_reboot.sh

sleep 140

echo "post reboot userdata"
sudo chmod 777 post_reboot.sh
python3 post_reboot.sh