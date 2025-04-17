#!/bin/bash
set -eu
set -o pipefail

# BUILD SH

# Remember to merge output streams into logs to try to prevent
#       buffering problems with conda build

# Environment notes:
# Generally, environment variables are not inherited into here.

# PREFIX is provided by Conda

TIMESTAMP=$( date '+%Y-%m-%d %H:%M:%S' )
echo "BUILD.SH START $TIMESTAMP"

show()
# Report shell value, aligned
{
  for V in ${*}
  do
    printf "%-13s %s\n" ${V}: ${!V:-unset}
  done
}

# Print key variables to log
{
  echo "python: " $( which python  )
  echo "Rscript:" $( which Rscript )
  show TIMESTAMP
  show PWD
  show RECIPE_DIR
  show PREFIX
} > $RECIPE_DIR/build-metadata.log

# Print environment to log
if [[ $PLATFORM =~ osx-* ]]
then
  NULL=""
  ZT=""
else
  NULL="--null" ZT="--zero-terminated"
fi
printenv ${NULL} | sort ${ZT} | tr '\0' '\n' > \
                                   $RECIPE_DIR/build-env.log

# if ! SDKROOT=$( xcrun --show-sdk-path )
# then
#   print "Error in xcrun!"
#   exit 1
# fi
# export SDKROOT
# show SDKROOT >> $RECIPE_DIR/build-metadata.log

# Make it!
{
  echo "INSTALL START: $( date '+%Y-%m-%d %H:%M:%S' )"
  which Rscript
  Rscript $RECIPE_DIR/install-RInside.R
  echo "INSTALL STOP:  $( date '+%Y-%m-%d %H:%M:%S' )"
} 2>&1 | tee $RECIPE_DIR/build-install.log

# Test it!
{
  echo "TEST RINSIDE START: $( date '+%Y-%m-%d %H:%M:%S' )"
  which Rscript R
  R --version
  R -e 'cat("R-TEST:", 42, "\n")'
  R -e 'library(RInside)'
  echo "TEST RINSIDE STOP:  $( date '+%Y-%m-%d %H:%M:%S' )"
} 2>&1 | tee $RECIPE_DIR/build-test.log

echo "BUILD.SH STOP $( date '+%Y-%m-%d %H:%M:%S' )"
