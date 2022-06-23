#!/bin/env bash
#
# docker-run.sh
#
# $ docker exec -it 11cfe8e74867 /bin/ash
# $ psql -h localhost -p 5432 -d postgres -U postgres --password
#

: ${UID?}

HOST_IP=127.0.0.1
HOST_PORT=5432

docker run --rm --detach --cpus 3 \
 	--publish=${HOST_PORT}:5432 \
	--name postgresql-on-alpine node1111/postgresql_on_alpine:v3.15
