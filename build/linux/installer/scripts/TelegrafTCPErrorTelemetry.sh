#!/bin/sh
countErr=$(grep -iF  "socket_writer" /var/opt/khulnasoft/docker-cimprov/log/telegraf.log | wc -l | tr -d '\n')
echo "telegraf,Source=telegrafErrLog telegrafTCPWriteErrorCountTotal=${countErr}i"