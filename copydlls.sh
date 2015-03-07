#!/bin/bash

# This script is intedned to copy the relevant dll's user for the MSYS2 version of the kicad build, for standalone inclusion in the NSIS installer.


if [[ ($# == "--help") || $# == "-h" ]]; then
    echo foobar
    display_help
    exit 1
fi

echo something is wrong, the above stuff does not work, I suck at bash


#ARCH="x86_64"
ARCH="i686"
 
if [ "$ARCH" == "x86_64" ]; then
    echo 64bit
    MINGWBIN="mingw64"
elif [ "$ARCH" == "i686" ]; then
    echo 32bit
    MINGWBIN="mingw32"
else
    echo "Use either \"x86_64\" or \"i686\" for the ARCH variable"
    exit 0
fi


BINDIR=/$MINGWBIN/bin
PKGDIR="/home/nosterga/MINGW-packages/mingw-w64-kicad-git/pkg/mingw-w64-$ARCH-kicad-git/$MINGWBIN/"
TARGETDIR=/home/nosterga/out
NSISPATH=~/nsis
MAKENSIS=~/NSIS-bin/Bin/makensis.exe

echo Output will be in $TARGETDIR
if [ ! -e $TARGETDIR ]; then
    mkdir -p $TARGETDIR
fi


SEARCHLIST=( \
    "*wx*.dll" \
    "*glew*.dll" \
    "*jpeg*.dll" \
    "libcairo*.dll" \
    "*ssl*.dll" \
    "libgomp*.dll" \
    "libstd*.dll" \
    "libgcc*.dll" \
    "libwinpthread-1.dll" \
    "libboost*.dll" \
    "libeay32.dll" \
    "ssleay32.dll" \
    "libpng*.dll" \
    "libpixman*.dll" \
    "libfreetype*.dll" \
    "libfontconfig*.dll" \
    "libharfbuzz*.dll" \
    "libexpat*.dll" \
    "libbz2*.dll" \
    "libglib*.dll" \
    "libiconv*.dll" \
    "zlib*.dll" \
    "libintl*.dll" \
    "libpython*.dll" )

echo Copying kicad binaries and stuff...
cp -r $PKGDIR/* $TARGETDIR

echo Copying dll depends...
for i in ${SEARCHLIST[@]}; do
    echo $i
    find $BINDIR -name $i | xargs cp -t $TARGETDIR/bin
done

echo Copying include/python2.7...
cp -r $BINDIR/../include/python2.7 $TARGETDIR/include

echo Copying lib/python2.7...
cp -r $BINDIR/../lib/python2.7 $TARGETDIR/lib

echo Copying python.exe...
cp $BINDIR/python.exe $TARGETDIR/bin

echo Building NSIS insaller exe...
cp -r $NSISPATH $TARGETDIR

cd $TARGETDIR/nsis
pwd
echo "This is still a work in progress... but GPL..." > ../COPYRIGHT.txt 
$MAKENSIS install.nsi














display_help() {
   echo "-h, --help   This help message"
   echo "-a, --arch   Determine arch for packaging"
}
