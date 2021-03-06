#!/bin/bash

release=${1:-"2.6"}

#sudo apt-get build-dep python2.7

case $release in
    "pypy") version="pypy-1.9" ;;
    "2.4") version="2.4.6" ;;
    "2.5") version="2.5.6" ;;
    "2.6") version="2.6.8" ;;
    "2.7") version="2.7.3" ;;
    "3.0") version="3.0.1" ;;
    "3.1") version="3.1.5" ;;
    "3.2") version="3.2.3" ;;
    "3.3") version="3.3.0" ;;
    *) echo "unknown version" >&2 && exit 1 ;;
esac

[[ ! -d build ]] && mkdir build
[[ ! -d src ]] && mkdir src
[[ ! -d venv ]] && mkdir venv

if [[ $release = "pypy" ]]; then
    if [[ $(uname -m) = "x86_64" ]]; then
        archive="${version}-linux64.tar.bz2"
    else
        archive="${version}-linux.tar.bz2"
    fi
    url="https://bitbucket.org/pypy/pypy/downloads/$archive"
    pydir=$(pwd)/pypy-1.9
else
    url="http://www.python.org/ftp/python/$version/Python-${version}.tar.bz2"
    archive=$(echo $url | sed 's#.*/\([^/]*.tar.bz2\)#\1#')
    pydir=$(pwd)/py-$release
fi

if [[ ! -f src/$archive ]]; then
    echo "Can't find $archive locally, downloading."
    pushd src
    wget $url
    popd
fi

distribute="distribute-0.6.32"
pip="pip-1.2.1"
virtualenv="virtualenv-1.8.4"

if [[ $release = "2.4" ]]; then
    pip="pip-1.1"
    virtualenv="virtualenv-1.7.2"
fi

[[ -d $pydir ]] && rm -rf $pydir


if [[ $release = "pypy" ]]; then
    tar xjf src/$archive
    python="$pydir/bin/pypy"
else
    mkdir $pydir

    pushd build

    rm -rf Python-$version
    tar xjf ../src/$archive

    pushd Python-$version

    LDFLAGS="-L/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)" ./configure --prefix=$pydir
    sed -i 's/^#_sha256/_sha256/' Modules/Setup
    sed -i 's/^#_sha512/_sha512/' Modules/Setup
    if [[ $release = "2.4" ]]; then
        sed -i 's/^#zlib/zlib/' Modules/Setup
    fi
    make && make install

    popd
    popd

    python="$pydir/bin/python$release"
fi

virtualenv_url="http://pypi.python.org/packages/source/v/virtualenv/${virtualenv}.tar.gz"
if [[ ! -f src/${virtualenv}.tar.gz ]]; then
    echo "Can't find virtualenv Downloading."
    pushd src
    wget $virtualenv_url
    popd
fi

distribute_url="http://pypi.python.org/packages/source/d/distribute/${distribute}.tar.gz"
if [[ ! -f src/${distribute}.tar.gz ]]; then
    echo "Can't find distribute. Downloading."
    pushd src
    wget $distribute_url
    popd
fi

pip_url="http://pypi.python.org/packages/source/p/pip/${pip}.tar.gz"
if [[ ! -f src/${pip}.tar.gz ]]; then
    echo "Can't find pip Downloading."
    pushd src
    wget $pip_url
    popd
fi

pushd build

rm -rf $distribute
tar xzf ../src/${distribute}.tar.gz
pushd $distribute
$python setup.py install
popd

rm -rf $pip
tar xzf ../src/${pip}.tar.gz
pushd $pip
$python setup.py install
popd

rm -rf $virtualenv
tar xzf ../src/${virtualenv}.tar.gz
pushd $virtualenv
$python setup.py install
popd

popd

rm -rf venv/$release
$pydir/bin/virtualenv --distribute -p $python ./venv/$release

