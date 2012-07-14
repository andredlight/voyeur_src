#!/bin/bash
find . -name "*.java" -exec ./lichelp.sh {} LICENSE.java.template \;
find . -name "*.rb" -exec ./lichelp.sh {} LICENSE.rb.template \;
