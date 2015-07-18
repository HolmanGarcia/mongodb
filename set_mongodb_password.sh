#!/bin/bash

PASS=${MONGODB_PASS:-$(pwgen -s 12 1)}
A_PASS=${APP_PASS:-$(pwgen -s 12 1)}
U_PASS=${USER_PASS:-$(pwgen -s 12 1)}

_word=$( [ ${MONGODB_PASS} ] && echo "preset" || echo "random" )

RET=1
while [[ RET -ne 0 ]]; do
  echo "=> Waiting for confirmation of MongoDB service startup"
  sleep 5
  mongo admin --eval "help" >/dev/null 2>&1
  RET=$?
done

echo "=> Creating an admin user with a ${_word} password in MongoDB"
mongo admin --eval "db.createUser({user: 'admin', pwd: '$PASS', roles:[{role:'root',db:'admin'}, { role: 'userAdminAnyDatabase', db: 'admin' } ]});"

mongo icon -u admin -p $PASS --eval "db.createUser({user: 'web-app', pwd: '$A_PASS', roles:[{role:'readWrite',db:'icon'}]});" --authenticationDatabase admin
mongo icon -u admin -p $PASS --eval "db.createUser({user: 'user', pwd: '$U_PASS', roles:[{role:'readWrite',db:'icon'}]});" --authenticationDatabase admin

echo "=> Done!"
touch /data/db/.mongodb_password_set

echo "========================================================================"
echo "You can now connect to this MongoDB server using:"
echo ""
echo "    mongo admin -u admin -p $PASS --host <host> --port <port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"
