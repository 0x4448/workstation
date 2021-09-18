#!/usr/bin/env bash

PYTHON_VERSION=3.9.7

set -euo pipefail


### Functions ###

function InstallDebianPythonBuildDeps() {
    sudo apt build-dep -y python3
    sudo apt-get install -y \
        libbz2-dev \
        libffi-dev \
        libgdbm-compat-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        tk-dev \
        uuid-dev \
        zlib1g-dev
}

function InstallPythonFromSource() {
    local cwd
    local tempdir

    # Download and extract
    cwd=$(pwd)
    tempdir=$(mktemp -d)
    cd "$tempdir"
    wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
    tar xvzf "Python-$PYTHON_VERSION.tgz"
    cd "Python-$PYTHON_VERSION"

    # Configure, build, and install
    ./configure --enable-optimizations
    make "-j$(grep -c ^processor < /proc/cpuinfo)"
    sudo make install

    # Cleanup
    cd "$cwd"
    sudo rm -rf "$tempdir"
}


### Main ###

if ! /usr/local/bin/python3 --version 2> /dev/null | grep -q "$PYTHON_VERSION"; then
    if uname -a | grep -q 'Debian\|buntu\|Mint'; then
        InstallDebianPythonBuildDeps
    else
        echo "Only Debian-based distributions are currently supported."
        exit 1
    fi
    InstallPythonFromSource
fi
