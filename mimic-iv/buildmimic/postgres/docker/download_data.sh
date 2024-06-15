#!/bin/bash
read -p "Enter PhysioNet username: " USERNAME
echo "Downloading MIMIV-IV data to ./mimic-data/"
wget -P -A gz,txt ./mimic-data/ -r -N -c -nd -np --user ${USERNAME} --ask-password https://physionet.org/files/mimiciv/2.2/
