#!/bin/sh

WORKDIR=$(dirname $0)
MSG='autocommit at '$(date)

cd $WORKDIR/../
ruby tools/update.rb -a
git add .
git commit -m "$MSG"
git push github master
