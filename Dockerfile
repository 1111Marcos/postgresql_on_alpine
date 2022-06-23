FROM alpine:3.15

ENV PG_VERSION "13"
ENV PGDATA /var/lib/postgresql/${PG_VERSION}/data

USER root

SHELL [ "/bin/ash", "-c" ]
RUN set -eux \
	&& apk update

RUN set -eux \
	&& apk add --no-cache postgresql"${PG_VERSION}" postgresql"${PG_VERSION}"-client 

RUN set -eux \
	&& apk add tzdata \
	&& cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
	&& echo "America/Sao_Paulo" > /etc/timezone \
	&& apk add musl-locales

ENV TZ America/Sao_Paulo
ENV LANG pt_BR.UTF-8
ENV LANGUAGE pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8

WORKDIR /etc/postgresql
RUN mkdir conf.d \
	&& chmod 751 conf.d
ADD etc/postgresql/postgresql.conf . 
ADD etc/postgresql/pg_hba.conf . 
ADD etc/postgresql/pg_ident.conf .

RUN chown postgres:postgres /etc/postgresql \
	&& chown postgres:postgres /etc/postgresql/* \
	&& chmod 0751 -R /etc/postgresql/*.conf

RUN mkdir /run/postgresql \
	&& mkdir /run/postgresql/${PG_VERSION}-main.pg_stat_tmp \
	&& chown postgres:postgres -R /run/postgresql \
	&& chown postgres:postgres /run/postgresql/${PG_VERSION}-main.pg_stat_tmp

USER postgres

RUN mkdir --parents ${PGDATA} \
	&& chmod 0700 -R /var/lib/postgresql/${PG_VERSION}

RUN echo "secr3ta" > /tmp/s.txt \
	&& initdb --locale=pt_BR.UTF-8 -D ${PGDATA} --pwfile=/tmp/s.txt --auth-local=scram-sha-256 \
	&& rm /tmp/s.txt

USER root

WORKDIR ${PGDATA}
ADD server.crt . 
ADD server.key .
RUN chown postgres:postgres server.*

USER postgres

EXPOSE 5432

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# I use PGDATA environment var to set data directory
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"] 
