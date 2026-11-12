#!/bin/bash

IN="$URLs"
# Endpoint that needs basic auth over HTTPS (optional)
ELASTIC_HOST="${ELASTIC_HOST:-elasticsearch:9200}"

checkstatus()
{
echo "check the status of the dependencies"

arrIN=(${IN//;/ })

j=1
for i in "${arrIN[@]}"
do
  echo "checking connection for $i"
  if [ "$i" == "$ELASTIC_HOST" ]
  then
  	if [ -n "$ELASTIC_USERNAME" ] && [ -n "$ELASTIC_PASSWORD" ]
        then
	  echo "Authenticating elasticsearch"
          status=$(curl -o /dev/null -w "%{http_code}" -k -u "$ELASTIC_USERNAME:$ELASTIC_PASSWORD" https://$i)
        else
          status=$(curl -o /dev/null -s -w "%{http_code}\n" $i)
        fi
  else 
	status=$(curl -o /dev/null -s -w "%{http_code}\n" $i)
  fi
  if [ "$status" == 200 ]
  then
  	echo "connection successful for $i"	
	k=${#arrIN[@]}
        if [ "$j" == "${#arrIN[@]}" ]
        then
            exit 0
        fi
  else
    echo "Unable to connect to $i"
    break

  fi
  j=$((j+1))
done

}

sleepTime="$RETRY_TIME"

while true
do
    checkstatus
    echo "retrying in $sleepTime seconds"
    sleep "$sleepTime"
done
