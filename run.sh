#!/bin/bash

set -e

if [ "${AWS_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the AWS_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${AWS_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the AWS_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${AWS_BUCKET}" = "**None**" ]; then
  echo "You need to set the AWS_BUCKET environment variable."
  exit 1
fi

if [ "${PREFIX}" = "**None**" ]; then
  echo "You need to set the PREFIX environment variable."
  exit 1
fi

if [ "${PGDUMP_DATABASE}" = "**None**" ]; then
  echo "You need to set the PGDUMP_DATABASE environment variable."
  exit 1
fi

if [ -z "${POSTGRES_ENV_POSTGRES_USER}" ]; then
  echo "You need to set the POSTGRES_ENV_POSTGRES_USER environment variable."
  exit 1
fi

if [ -z "${POSTGRES_ENV_POSTGRES_PASSWORD}" ]; then
  echo "You need to set the POSTGRES_ENV_POSTGRES_PASS environment variable."
  exit 1
fi

if [ -z "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
  echo "You need to set the POSTGRES_PORT_5432_TCP_ADDR environment variable or link to a container named POSTGRES."
  exit 1
fi

if [ -z "${POSTGRES_PORT_5432_TCP_PORT}" ]; then
  echo "You need to set the POSTGRES_PORT_5432_TCP_PORT environment variable or link to a container named POSTGRES."
  exit 1
fi

POSTGRES_HOST_OPTS="-h $POSTGRES_PORT_5432_TCP_ADDR -p $POSTGRES_PORT_5432_TCP_PORT -U $POSTGRES_ENV_POSTGRES_USER"

echo "Starting dump of ${PGDUMP_DATABASE} database(s) from ${POSTGRES_PORT_5432_TCP_ADDR}..."

export PGPASSWORD=${POSTGRES_ENV_POSTGRES_PASSWORD}

DUMPFILE=$DUMPFILE_PREFIX`date +%Y%m%d_%H%M%S`
pg_dump $PGDUMP_OPTIONS $POSTGRES_HOST_OPTS $PGDUMP_DATABASE > $DUMPFILE
gzip $DUMPFILE
aws s3 cp $DUMPFILE.gz s3://$AWS_BUCKET/$PREFIX/$DUMPFILE.gz

echo "Done!"

exit 0
