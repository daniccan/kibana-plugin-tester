#!/bin/bash

INFO_COLOR="\e[34m"
SUCCESS_COLOR="\e[32m"
ERROR_COLOR="\e[31m"
LOG_END="\e[0m"
NEW_LINE=""

echo -e "$INFO_COLOR Kibana Plugin Deploy Started. $LOG_END"

echo $NEW_LINE

if [ -z "$KIBANA_VERSION" ]
    then
        echo -e "$ERROR_COLOR KIBANA_VERSION environment variable is required. $LOG_END"
        exit 1
fi

if [ -z "$PLUGIN_FILE_NAME" ] && [ -z "$PLUGIN_URL" ]
    then
        echo -e "$ERROR_COLOR PLUGIN_FILE_NAME / PLUGIN_URL environment variable is required. $LOG_END"
        exit 1
fi

echo -e "$INFO_COLOR Download and Extract Elasticsearch. $LOG_END"

es_download_url="https://artifacts.elastic.co/downloads/elasticsearch"

es_linux_package="elasticsearch-$KIBANA_VERSION-linux-x86_64.tar.gz"
es_linux_status_code=`wget --no-check-certificate --spider -S $es_download_url/$es_linux_package 2>&1 | grep "HTTP/" | awk '{print $2}'`

if [ "$es_linux_status_code" != 200 ]
    then
        es_package="elasticsearch-$KIBANA_VERSION.tar.gz"
        es_status_code=`wget --no-check-certificate --spider -S $es_download_url/$es_package 2>&1 | grep "HTTP/" | awk '{print $2}'`

        if [ "$es_status_code" != 200 ]
            then
                echo -e "$ERROR_COLOR Elasticsearch .tar.gz Package not found. $LOG_END"
                exit 1
        else
            wget --no-check-certificate $es_download_url/$es_package
            tar -xzf $es_package
            rm -f $es_package
        fi
else
    wget --no-check-certificate $es_download_url/$es_linux_package
    tar -xzf $es_linux_package
    rm -f $es_linux_package
fi

cd elasticsearch-$KIBANA_VERSION

echo "network.host: 0.0.0.0" >> config/elasticsearch.yml
echo "discovery.type: single-node" >> config/elasticsearch.yml

bin/elasticsearch &
cd ..

echo -e "$INFO_COLOR Waiting for Elasticsearch to Start. $LOG_END"
status_code=-1
while [ "$status_code" -ne 200 ]
do
    status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:9200) 
    printf '.'
    sleep 2
done
echo $NEW_LINE

echo -e "$SUCCESS_COLOR Elasticsearch Started Successfully. $LOG_END"

echo $NEW_LINE

echo -e "$INFO_COLOR Download and Extract Kibana. $LOG_END"

kibana_download_url="https://artifacts.elastic.co/downloads/kibana"

kibana_linux_package="kibana-$KIBANA_VERSION-linux-x86_64.tar.gz"
kibana_linux_status_code=`wget --no-check-certificate --spider -S $kibana_download_url/$kibana_linux_package 2>&1 | grep "HTTP/" | awk '{print $2}'`

if [ "$kibana_linux_status_code" != 200 ]
    then
        echo -e "$ERROR_COLOR Kibana .tar.gz Package not found. $LOG_END"
        exit 1
else
    wget --no-check-certificate $kibana_download_url/$kibana_linux_package
    tar -xzf $kibana_linux_package
    rm -f $kibana_linux_package
fi

cd kibana-$KIBANA_VERSION-linux-x86_64 && mkdir logs

echo "server.host: \"0.0.0.0\"" >> config/kibana.yml
echo "logging.dest: /home/ubuntu/kibana-$KIBANA_VERSION-linux-x86_64/logs/kibana.log" >> config/kibana.yml

echo -e "$INFO_COLOR Install Kibana Plugin. $LOG_END"

if [ -n "$PLUGIN_URL" ]
    then
        bin/kibana-plugin install $PLUGIN_URL &
else
    bin/kibana-plugin install file:///kibana-plugin/$PLUGIN_FILE_NAME &
fi

echo $NEW_LINE

echo -e "$INFO_COLOR Waiting for Kibana Plugin Installation to Complete. $LOG_END"
log_count=0
kibana_install_pid=0
while [ "$log_count" -eq 0 ] && ! [ -z "$kibana_install_pid" ]
do
    if [ -f "logs/kibana.log" ]
        then
            log_count=`cat logs/kibana.log | grep -i 'Optimization' | grep -i 'complete' | wc -l`
    else
        kibana_install_pid=`ps -eaf | grep -i 'kibana' | grep -i 'install' | awk '{print $2}'`
    fi
    printf '.'
    sleep 2
done

if ! [ -z "$kibana_install_pid" ]
    then
        kill $kibana_install_pid
        wait $kibana_install_pid 2>/dev/null
fi

echo $NEW_LINE

echo -e "$SUCCESS_COLOR Kibana Plugin Installed Successfully. $LOG_END"

bin/kibana &

echo $NEW_LINE

echo -e "$INFO_COLOR Waiting for Kibana to Start. $LOG_END"
status_code=-1
while [ "$status_code" -ne 302 ]
do
    status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:5601) 
    printf '.'
    sleep 2
done
echo $NEW_LINE

echo -e "$SUCCESS_COLOR Kibana Started Successfully. $LOG_END"

echo $NEW_LINE

echo -e "$SUCCESS_COLOR Kibana Plugin Deploy Completed. Visit Kibana UI to Test your Plugin. $LOG_END"

echo $NEW_LINE

echo -e "$INFO_COLOR Displaying logs for Kibana: $LOG_END"

tail -500f logs/kibana.log
