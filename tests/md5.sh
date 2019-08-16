# run in the folder:
#  ./md5.sh checksum_md5_zipped.txt
# OR
#  ./md5.sh checksum_md5_unzipped.txt
while read p; do
  A="$(echo $p | cut -d' ' -f1)"
  B="$(echo $p | cut -d' ' -f2)"
  if [ ! -f $B ]
  then
    echo "ERROR: $B does not exist"
    continue
  fi
  read C< <(md5 -q $B)
  echo $B $A = $C
  if [ $C != $A ]
  then
    echo "ERROR: $B wrong md5"
    exit
  fi
done <$1
