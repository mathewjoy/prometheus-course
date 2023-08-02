## docker run --network host --name my_graf grafana/grafana

this_container="my_graf"
ps_container=$(docker ps --filter "name=${this_container}" --format {{".Names"}})
psa_container=$(docker ps -a --filter "name=${this_container}" --format {{".Names"}})

echo "this: $this_container running: $ps_container recent: $psa_container" 


if [ "${ps_container}x" == "${this_container}x" ] ; then
	echo "$this_conainer is running.  Stop and remove before restarting.  Exiting"
	exit 1
fi

if [ "${psa_container}x" == "${this_container}x" ] ; then
	echo "removing recent container $psa_container..."
	docker rm $this_container
fi


# env vars from inspect image grafana/grafana
##               "PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
##                "GF_PATHS_CONFIG=/etc/grafana/grafana.ini",
##                "GF_PATHS_DATA=/var/lib/grafana",
##                "GF_PATHS_HOME=/usr/share/grafana",
##                "GF_PATHS_LOGS=/var/log/grafana",
##                "GF_PATHS_PLUGINS=/var/lib/grafana/plugins",
##                "GF_PATHS_PROVISIONING=/etc/grafana/provisioning"

echo Starting container $this_container...
docker run \
-v /mnt/promdata/grafdb:/grafdata \
-v /mnt/promdata/grafconfig:/grafconfig \
-e GF_PATHS_DATA=/grafdata \
-e GF_PATHS_CONFIG=/grafconfig/grafana.ini \
--name my_graf \
-p 3000:3000 \
--network my-mon-nw -d  grafana/grafana 

echo "Network info..."
docker inspect $this_container -f 'Container: {{.Name}}, Network: {{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{.Aliases}} {{end}}'
