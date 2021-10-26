#!/bin/bash

# Copyright (c) 2019 Intel Corporation.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

RED='\033[0;31m'
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
NC='\033[0m' # No Color

function log_warn() {
    echo -e "${YELLOW}WARN: $1 ${NC}"
}

function log_info() {
    echo -e "${GREEN}INFO: $1 ${NC}"
}

function log_error() {
    echo -e "${RED}ERROR: $1 ${NC}"
}

function log_fatal() {
    echo -e "${RED}FATAL: $1 ${NC}"
    exit -1
}

function check_error() {
    if [ $? -ne 0 ] ; then
        log_fatal "$1"
    fi
}

INSTALL_PATH="/usr/local/lib"
ORIGINAL_CURRENT_DIR=`pwd`

# Library versions
zeromq_version="4.3.3"

# URLs
zeromq_url="https://github.com/zeromq/libzmq/releases/download/v4.3.3/zeromq-${zeromq_version}.tar.gz"

if [ ! -d "deps" ] ; then
    mkdir deps
    check_error "Failed to create dependencies directory"
fi

cd deps
check_error "Failed to change to dependencies directory"

if [ "$1" == "--cython" ] ; then
    # Installing Python dependencies
    log_info "Installing Cython for Python bindings"
    pip3 install -r $ORIGINAL_CURRENT_DIR/python/requirements.txt
    check_error "Failed to install Cython"
fi

# Installing ZeroMQ dependency
if [ -f "$INSTALL_PATH/libzmq.so" ]; then
    log_info "libzmq ${zeromq_version} already installed"
else
    if [ ! -f "zeromq.tar.gz" ] ; then
        log_info "Downloading libzmq source"
        wget -q --show-progress $zeromq_url -O zeromq.tar.gz
        check_error "Failed to download zeromq"
    fi

    zeromq_dir="zeromq-${zeromq_version}"

    if [ ! -d "$zeromq_dir" ] ; then
       log_info "Extracting libzmq"
       tar xf zeromq.tar.gz
       check_error "Failed to extract library"
    fi

    cd $zeromq_dir/
    check_error "Failed to change to libzmq directory"

    log_info "Configuring libzmq for building"
    ./configure
    check_error "Configuring libzmq build failed"

    log_info "Compiling libzmq library"
    make -j$(nproc --ignore=2)
    check_error "Failed to compile libzmq"

    log_info "Installing libzmq"
    make install
    check_error "Failed to install libzmq"

    cd ../
fi

log_info "Done."
