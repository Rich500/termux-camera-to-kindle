#!/bin/bash

# -----------------------------------------------------------------------------
# Info:
#   author:    Richard Calow
#   file:      termux-camera-to-kindle.sh
#   created:   21.08.2020
#   revision:  21.08.2020
#   version:   0.1
# -----------------------------------------------------------------------------
#
# Requirements:
#  Termux - with API installed for camera access. Additionally, sshpass and
#           imagemagick packages.
#
#  Kindle ereader - Jailbroken and with root access.  
# -----------------------------------------------------------------------------

# Settings
kindle_user=root
kindle_password=PASSWORD
kindle_ip=192.168.0.42

declare -a pkgs=("sshpass" "convert")

for val in "${pkgs[@]}"; do
   type $val >/dev/null 2>&1 || { echo >&2 "I require $val but it's not installed.  Aborting."; exit 1; }
done

echo "Taking a photo."

termux-camera-photo -c 0 file.jpg

echo "Converting JPEG to a PNG, and enhance."

#convert file.jpg -resize 600x800 -enhance -equalize -contrast -gravity Center -type GrayScale -depth 8 -colors 256  file.png

convert file.jpg -resize 600x800 -auto-gamma -auto-level -normalize  -gravity Center -type GrayScale -depth 8 -colors 256 file.png

echo "Sending PNG to kindle"

sshpass -p $kindle_password scp file.png $kindle_user@$kindle_ip:/mnt/base-us/

echo "Done sending, will now attempt to disable kindle processes. (If they are already turned off errors will show.)"

sshpass -p $kindle_password ssh $kindle_user@$kindle_ip /ect/init.d/powerd stop
sshpass -p $kindle_password ssh $kindle_user@$kindle_ip /ect/init.d/framework stop

echo "Telling the kindle to display your image."

sshpass -p $kindle_password ssh $kindle_user@$kindle_ip eips -g /mnt/base-us/file.png
