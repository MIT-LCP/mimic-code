while read p; do
  A="$(echo $p | cut -d' ' -f1)"
  B="$(echo $p | cut -d' ' -f2)"
  read C< <(md5 -q $B)
  echo $B $A = $C
  if [ ! -z $B ]
  then
    echo "ERROR: $B does not exist"
    exit
  fi
  if [ $C != $A ]
  then
    echo "ERROR: $B wrong md5"
    exit
  fi
done <$1
