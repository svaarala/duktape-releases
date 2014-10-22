#!/bin/sh

TMPTARXZ=/tmp/unpack-temp.tar.xz

set -e

TARXZ="$1"
if [ x"$TARXZ" = "x" ]; then
	echo "Missing tar.xz argument"
	exit 1
fi

VERSION=`echo "$1" | perl -n -e'/^duktape-(?:full-)?(.*?).tar.xz$/ && print $1'`

echo "Tar.xz: $TARXZ"
echo "Version: <$VERSION>"
echo -n "Confirm (y): "
read ans
if [ x"$ans" != "xy" ]; then
	echo "Aborted"
	exit 1
fi

cp "$TARXZ" $TMPTARXZ
git checkout master
git checkout --orphan unpacked-v$VERSION
git rm -rf .
tar --strip-components=1 -x -J -f $TMPTARXZ
git add --all
git diff | diffstat

echo -n "Confirm (y): "
read ans
if [ x"$ans" != "xy" ]; then
	echo "Aborted"
	exit 1
fi

git commit -m "Release $VERSION"
git tag -a -m "Release $VERSION" v$VERSION
git push origin v$VERSION
git checkout master
git branch -D unpacked-v$VERSION
