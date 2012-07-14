#!/bin/bash
if [ -z "$(grep 'GNU General Public' $1)" ]; then
  echo adding GPL license to $1
  cat LICENSE.template $1 > $1.new
  cp $1 $1.old
  mv $1.new $1
fi
