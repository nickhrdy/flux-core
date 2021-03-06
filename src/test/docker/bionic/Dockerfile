FROM ubuntu:bionic

LABEL maintainer="Tom Scogland <scogland1@llnl.gov>"

# Update pkg caches, install latest pkg utils:
RUN apt-get update \
 && apt-get -qq install -y --no-install-recommends \
        apt-utils \
 && rm -rf /var/lib/apt/lists/*

# Utilities
RUN apt-get update \
 && apt-get -qq install -y --no-install-recommends \
        locales \
        ca-certificates \
        wget \
        man \
        git \
        sudo \
        vim \
        luarocks \
        ruby \
        munge \
        lcov \
        ccache \
        lua5.2 \
        mpich \
        valgrind \
        jq \
 && rm -rf /var/lib/apt/lists/*

# Compilers, autotools
RUN apt-get update \
 && apt-get -qq install -y --no-install-recommends \
        build-essential \
        pkg-config \
        autotools-dev \
        libtool \
        autoconf \
        automake \
        make \
        cmake \
        clang-6.0 \
        clang-tidy \
        gcc-8 \
        g++-8 \
 && rm -rf /var/lib/apt/lists/*

# Python
# NOTE: sudo pip install is necessary to get differentiated installations of
# python binary components for multiple python3 variants, --ignore-installed
# makes it ignore local versions of the packages if your home directory is
# mapped into the container and contains the same libraries
RUN apt-get update \
 && apt-get -qq install -y --no-install-recommends \
        python-dev \
        python3-dev \
        python3.7-dev \
        python3.8-dev \
        python-pip \
        python-setuptools \
        python-wheel \
        python3-pip \
        python3-setuptools \
        python3-wheel \
 && rm -rf /var/lib/apt/lists/* \
 && for PY in python2 python3.6 python3.7 python3.8 ; do \
        sudo $PY -m pip install --upgrade --ignore-installed cffi six pyyaml jsonschema ; \
    done ; \
    apt-get -qq purge -y python-pip python3-pip \
 && apt-get -qq autoremove -y

# Other deps
RUN apt-get update \
 && apt-get -qq install -y --no-install-recommends \
        libsodium-dev \
        libzmq3-dev \
        libczmq-dev \
        libjansson-dev \
        libmunge-dev \
        liblua5.2-dev \
        liblz4-dev \
        libsqlite3-dev \
        uuid-dev \
        libhwloc-dev \
        libmpich-dev \
 && rm -rf /var/lib/apt/lists/*

# Testing utils and libs
RUN apt-get update \
 && apt-get -qq install -y --no-install-recommends \
        faketime \
        libfaketime \
        pylint \
        cppcheck \
        aspell \
        aspell-en \
 && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

# NOTE: luaposix installed by rocks due to Ubuntu bug: #1752082 https://bugs.launchpad.net/ubuntu/+source/lua-posix/+bug/1752082
RUN luarocks install luaposix

# NOTE: we need asciidoctor 1.5.7 to handle manpages, install with gem install
RUN /usr/bin/gem install asciidoctor

# Install caliper by hand for now:
RUN mkdir caliper \
 && cd caliper \
 && wget -O - https://github.com/LLNL/Caliper/archive/v1.7.0.tar.gz | tar xvz --strip-components 1 \
 && mkdir build \
 && cd build \
 && CC=gcc CXX=g++ cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
 && make -j 4 \
 && make install \
 && cd ../.. \
 && rm -rf caliper
