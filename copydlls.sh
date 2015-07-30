#!/bin/bash

# This script is intedned to copy the relevant dll's and other KiCad binaries
# from the MSYS2 version of the KiCad build, for standalone inclusion in the
# NSIS installer, which is run in the end of this script.


display_help() {
    echo "Usage: copydlls.sh [OPTION]"
    echo "  -h, --help           This help message"
    echo "  -a, --arch=ARCH      Determine arch for packaging"
    echo "  -p, --pkgpath=PATH   Path to pkg.tar.xz package"
    exit 0
}

decode_arch() {
    #echo $1
    tmp=${1#*-}
    tmp=${tmp#*-}
    tmp=${tmp%%-*}
    ARCH=$tmp
}

decode_ver() {
    tmp=${1#*-}
    tmp=${tmp#*-}
    tmp=${tmp#*-}
    tmp=${tmp#*-}
    tmp=${tmp#*-}
    tmp=${tmp%%-*}
    VERSION=$tmp
}

# This function expects a basename as:
# mingw-w64-x86_64-kicad-git-r5464.25b9a42-1-any.pkg.tar.xz
decode_pkg() {
    decode_arch $1
    decode_ver $1
}

extract_pkg() {
#    cd $2
#    echo standing in:
    pwd
    echo ======================

    # Extract the pkg.tar.xz
    bsdtar xf $1 --strip-components 1 -C $2
}


for i in "$@"; do
case $i in
    -h|--help)
    display_help
    shift
    ;;
    -a=*|--arch=*)
    ARCH="${i#*=}"
    echo "\$ARCH=$ARCH"
    decode_arch
    shift
    ;;
    -p=*|--pkgpath=*)
    PKGPATH="${i#*=}"
    echo "\$PKGPATH=$PKGPATH"
    decode_pkg
    shift
    ;;
    *)
    echo "Unknown option, see the help info below:"
    display_help
    ;;
esac
done

# Sets some other variables depending on the ARCH set
handle_arch() {
    #ARCH="x86_64"
    #ARCH="i686"

    if [ -z $ARCH ]; then
        echo "error: ARCH is not set"
        exit 0
    fi
     
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
}


# Temporary dir to store the file structure
OUTDIR="$HOME/out"
# Path to the KiCad NSIS scripts
NSISPATH="$HOME/kicad-windows-nsis-packaging/nsis"
# Path to the NSIS compiler
MAKENSIS="$HOME/NSIS-bin/Bin/makensis.exe"

copystuff() {
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
        "libtiff*.dll" \
        "libpixman*.dll" \
        "libfreetype*.dll" \
        "libfontconfig*.dll" \
        "libharfbuzz*.dll" \
        "libexpat*.dll" \
        "libbz2*.dll" \
        "liblzma*.dll" \
        "libglib*.dll" \
        "libiconv*.dll" \
        "zlib*.dll" \
        "libintl*.dll" \
        "libpython*.dll" )

    #echo Copying kicad binaries and stuff...
    #cp -r $MSYSDIR/bin/* $TARGETDIR/bin

    echo Copying dll depends...
    for i in ${SEARCHLIST[@]}; do
        echo $i
        find $MSYSDIR/bin -name $i | xargs cp -t $TARGETDIR/bin
    done

    echo Copying include/python2.7...
    cp -r $MSYSDIR/include/python2.7 $TARGETDIR/include

    echo Copying lib/python2.7...
    cp -r "$MSYSDIR/lib/python2.7/" "$TARGETDIR/lib/"
    rm -f $TARGETDIR/lib/python2.7/config/libpython2.7.dll.a # Not really needed

    echo Copying python.exe...
    cp $MSYSDIR/bin/python.exe $TARGETDIR/bin

    echo Building NSIS insaller exe...
    cp -r $NSISPATH $TARGETDIR
}


makensis() {
    cd $TARGETDIR/nsis
    pwd
    echo "This is still a work in progress... but GPL..." > ../COPYRIGHT.txt 
    $MAKENSIS \
        //DOPTION_STRING="native-mingw-with-scripting-$ARCH" \
        //DPRODUCT_VERSION=$VERSION \
        //DOUTFILE="..\kicad-product-$VERSION-$ARCH.exe" \
        //DARCH="$ARCH" \
        install.nsi
    cd -
}


# This loop looks for package files in the PKGPATH
for entry in "$PKGPATH"/*; do
if [[ $entry == *"pkg.tar.xz"* ]]; then
    decode_pkg $(basename $entry)
    echo "Decoded pkg is $ARCH and $VERSION"
    handle_arch
    echo $ARCH $ARCH
    
    TARGETDIR="$OUTDIR/pack-$ARCH"
    MSYSDIR="/$MINGWBIN"

    echo "\$TARGETDIR=$TARGETDIR"
    echo "\$MSYSDIR=$MSYSDIR"
    
    echo Output will be in $TARGETDIR
    if [ -e $TARGETDIR ]; then
        rm -rf $TARGETDIR/*
    fi
    mkdir -p $TARGETDIR/bin
    mkdir -p $TARGETDIR/lib
    mkdir -p $TARGETDIR/include
    
    copystuff
    extract_pkg $entry $TARGETDIR
    makensis
fi
done










