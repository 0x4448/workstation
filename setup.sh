#!/usr/bin/env bash
set -euo pipefail

### Variables ###

PYTHON_VERSION=3.10.0


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
    ./configure --enable-optimizations --prefix="$HOME/.local/python/$PYTHON_VERSION"
    make "-j$(grep -c ^processor < /proc/cpuinfo)"
    make install

    # Cleanup
    cd "$cwd"
    rm -rf "$tempdir"

    # Create symlinks
    ln -s "$HOME/.local/python/$PYTHON_VERSION/bin/python3" "$HOME/.local/bin/python3"
    ln -s "$HOME/.local/python/$PYTHON_VERSION/bin/pip3" "$HOME/.local/bin/pip3"

    # Update pip
    python3 -m pip install --upgrade pip

    # Install pipx
    pip3 install pipx

    # Install pipx packages
    pipx install --include-deps ansible
    pipx install pre-commit
}


### Main ###

export PATH="$HOME/.local/bin:$HOME/.local/python/$PYTHON_VERSION/bin:$PATH"
mkdir -p "$HOME/.local/bin"

if ! "$HOME/.local/bin/python3" --version 2> /dev/null | grep -q "$PYTHON_VERSION"; then
    if uname -a | grep -q 'Debian\|buntu\|Mint'; then
        InstallDebianPythonBuildDeps
    else
        echo "Only Debian-based distributions are currently supported."
        exit 1
    fi
    InstallPythonFromSource
fi
