# bridge network creates its on private dns and the container name is used as hostname
# docker run -p 9090:9090 -v /prometheus:/mnt/data/promdb --user root --name my_prom --network=bridge --net-alias "prom.one" prom/prometheus

# the host network uses the hostmachines  ports and therefore -p has no meaning; we dont need to specify it.  
# --net-alias is not applicable either.  /mmnt/data/promdb is local filesystem mounted as /prometheus

# docker run -v /mnt/data/promdb:/prometheus --user root --name my_prom -p 8080:8080 --network my-mon-nw -d prom/prometheus
# docker run -v /mnt/data/promdb:/prometheus --user root --name my_prom -p 8080:8080 --network my-mon-nw prom/prometheus --storage.tsdb.path /prometheus

# stop and rm if container is running

this_container="my_prom"
ps_container=$(docker ps --filter "name=my_prom" --format {{".Names"}})
psa_container=$(docker ps -a --filter "name=my_prom" --format {{".Names"}})

echo "this: $this_container running: $ps_container recent: $psa_container" 


if [ "${ps_container}x" == "${this_container}x" ] ; then
	echo "$this_conainer is running.  Stop and remove before restarting.  Exiting"
	exit 1
fi

if [ "${psa_container}x" == "${this_container}x" ] ; then
	echo "removing recent container $psa_container..."
	docker rm $this_container
fi

echo Starting container $this_container...

# here are the things to do to start prometheus enging
docker run -v /mnt/promdata/promdb:/prometheus \
-v /mnt/promdata/promconfig:/promconfig \
--user root --name my_prom -p 9090:9090 \
--add-host=host.docker.internal:10.0.0.70 \
--network my-mon-nw -d  prom/prometheus --config.file=/promconfig/prometheus.yml 

echo "Network info..."
docker inspect $this_container -f 'Container: {{.Name}}, Network: {{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{.Aliases}} {{end}}'
