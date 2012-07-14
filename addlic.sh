#!/bin/bash
cat LICENSE.template $1 > $1.new
cp $1 $1.old
mv $1.new $1
