#!/bin/bash

DATA_DIR=${1-.}

echo 'Unzipping MIMIC data files in directory '  $DATA_DIR ' ...' 

for f in $DATA_DIR/*.gz; do 
	echo 'Unzipping ' $f ' ...';
	gunzip $f; 
done

chmod -R 0755 $DATA_DIR

echo 'Done!'
