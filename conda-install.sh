#!/bin/zsh
set -eu

# CONDA INSTALL
# Install script for use by maintainers when testing PKGs.
# Normally you will want to use a different fresh Conda
#          from the Conda you used to build the PKG.
# Provide the PKG on the command line.
# NOTE: conda install from file does not install dependencies!
#       Cf. https://docs.anaconda.com/free/anaconda/packages/install-packages
#       Thus this script installs dependencies using PLATFORM/deps.sh
# NOTE: Keep LIST in sync with meta.yaml
# USAGE: Provide PKG

if (( ${#*} != 1 )) {
  print "Provide PKG!"
  return 1
}
PKG=$1

# Get this directory (absolute):
DEV_CONDA=${0:A:h}
# The Swift/T Git clone:
SWIFT_T_TOP=${DEV_CONDA:h:h}

# Report information about given PKG:
print "PKG=$PKG"
# PKG is of form
# ANACONDA/conda-bld/PLATFORM/swift-t-V.V.V-pyVVV.tar.bz2
# Pull out PLATFORM (head then tail):
PLATFORM=${PKG:h:t}
print "PLATFORM=$PLATFORM"
zmodload zsh/stat zsh/mathfunc
zstat -H A -F "%Y-%m-%d %H:%M" $PKG
printf "PKG: timestamp: %s size: %.1f MB\n" \
       ${A[mtime]} $(( float(${A[size]}) / (1024*1024) ))
# printf "md5sum: "
# checksum $PKG

# Report information about active Python/Conda:
if ! which conda >& /dev/null
then
  print "No conda!"
  return 1
fi

print
print "using python:" $( which python )
print "using conda: " $( which conda )
print

# Build dependency list:
LIST=(
  libcurl
  pcre2
  xz
  gfortran
  emews-r
)

# Run conda install!

set -x
if (( INSTALL_DEPS )) conda install --yes -c conda-forge -c swift-t $LIST
conda install --yes $PKG
