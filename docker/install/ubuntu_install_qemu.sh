#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

#
# Install QEMU on Ubuntu.
#
# Usage: ubuntu_install_qemu.sh [--target-list target0,target1,...]
#   --target-list is list of target for QEMU comma seperated. e.g. aarch64-softmmu,arm-softmmu,...
#

set -e
set -o pipefail

# Get number of cores for build
if [ -n "${TVM_CI_NUM_CORES}" ]; then
  num_cores=${TVM_CI_NUM_CORES}
else
  num_cores=2
fi

# Set target list for QEMU
if [ "$1" == "--target-list" ]; then
    shift
    target_list=$1
else
    # Build these by defualt for microtvm reference virtual machine and ci_qemu.
    target_list="aarch64-softmmu,arm-softmmu,i386-softmmu,riscv32-softmmu,riscv64-softmmu,x86_64-softmmu"
fi

sudo sed -i '/deb-src/s/^# //' /etc/apt/sources.list
apt update
apt-get -y build-dep qemu

gpg --keyserver keys.gnupg.net --recv-keys 0x3353C9CEF108B584
cat <<EOF | gpg --dearmor >qemu-5.1.0.tar.xz.sig
-----BEGIN PGP ARMORED FILE-----
Comment: Use "gpg --dearmor" for unpacking

iQEzBAABCgAdFiEEzqzJ4VU066u4LT+gM1PJzvEItYQFAl8zEnAACgkQM1PJzvEI
tYSp2wf/X/8I+hz1OLHCnoJuA9AqXEz1vtQ/dsvL1FfkOerMglih8wh9HYastf2+
CWsX8o9i5ryrxWafJKIRjj7uAgEuekvpkm3on7/iiZNXYkQOqeBBylUuGXI2BOXr
ObS4alzzgowp2laoe2n7Ew391HbvYX0NT5HqKxlCYsLcbCeYtI+7jVgQzxtnwFzO
Vb4zLJybhHQfAVlc5SkKfZkW+0yPnMeS376bYqJz+Wo3UZYVfZrHPygHX1NhRVYc
p5ez/+2k4VAIwIQoP5DoO06waLBffvLIAdPPKYsx71K67OoGG2svc7duC/+5qf1x
8FBFJX9b4ft0tr/cwpVdq8dr/VWqQg==
=hCS7
-----END PGP ARMORED FILE-----
EOF
curl -OLs https://download.qemu.org/qemu-5.1.0.tar.xz
gpg --verify qemu-5.1.0.tar.xz.sig

tar -xf qemu-5.1.0.tar.xz
cd qemu-5.1.0
./configure --target-list=${target_list}
make -j${num_cores}
sudo make install

# For debugging with qemu
apt-get -y install libpython3.8
