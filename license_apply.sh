#!/bin/bash
find . -name "*.java" -exec ./lichelp.sh {} \;
find . -name "*.rb" -exec ./lichelp.sh {} \;
