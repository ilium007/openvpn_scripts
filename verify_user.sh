#!/bin/sh

genhash() {
  hashpass=$(echo -n "$1$2" | md5sum | sed s'/\  -//')
  i=0
  while [ $i -lt 10 ]; do
    hashpass=$(echo -n $hashpass$hashpass | md5sum | sed s'/\  -//')
    i=$(expr $i + 1)
  done
  echo -n $hashpass
}

verify() {
  login=$(echo $1 | awk '{print tolower($0)}')
  echo "`date +"%a %b %d %T %Y"` verify script - user: $login"
  logger -t "openvpn auth" "verify script - user: $login"
  [[ $# -eq 2 ]] || exit 1
  for i in $users; do
    name=${i%:*}
    passhash=${i#*:}
    logincmp=$(echo $name | awk '{print tolower($0)}')

    if [ "$logincmp" == "$login" ]
    then
      hash=$(genhash "$login" "$2")
      if [ "$hash" == "$passhash" ]
      then
        echo "`date +"%a %b %d %T %Y"` verify script - success: $login"
        logger -t "openvpn auth" "verify script - success: $login"
        exit 0
      fi
    fi
  done
}

if [ "$1" == "--genhash" ]; then
  shift 1
  case $# in
    3) users_file=$1
       shift 1;;
    2) users_file="./users";;
    *) echo "Incorrect arguments provided";;
  esac

  login=$(echo $1 | awk '{print tolower($0)}')
  echo "$login:$(genhash "$login" "$2")" >> $users_file
  chown root:nobody $users_file
  chmod 640 $users_file
  exit 1
fi

users_file=$1
shift 1

users=$(cat $users_file)
#verify $(cat $*)
verify $(cat $1)
echo "`date +"%a %b %d %T %Y"` verify script - failed to auth: $login"
logger -t "openvpn auth" "verify script - failed to auth: $login"
exit 1