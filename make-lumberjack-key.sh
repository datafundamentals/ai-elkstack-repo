#! /bin/sh

openssl req -x509 -newkey rsa:2048 -keyout logstash-forwarder.key -out logstash-forwarder.crt -nodes -days 1000
CERT=`cat logstash-forwarder.crt  | base64 | xargs echo | sed 's/ //g'`
KEY=`cat logstash-forwarder.key  | base64 | xargs echo | sed 's/ //g'`

echo '{
  "id": "secrets",
  "key": "$KEY",
  "certificate": "$CERT"
}' | sed s/'$KEY'/$KEY/ | sed s/'$CERT'/$CERT/ > bag.json

echo
echo "Made: bag.json"

echo "Now run:  knife data bag from file logstash-forwarder bag.json"