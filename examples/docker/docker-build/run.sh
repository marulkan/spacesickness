#!/bin/bash

cp /archiso/packages.x86_64 /archiso/packages.x86_64.old
cp -rf /config/* /archiso
cat /archiso/packages.x86_64 /archiso/packages.x86_64.old | sort -u > /archiso/p
mv /archiso/p /archiso/packages.x86_64
rm /archiso/packages.x86_64.old
cd /archiso
./build.sh -v
rm -rf /output/{iso,unpacked}
mkdir /output/{iso,unpacked}
cp /archiso/out/*.iso /output/iso
mount -o loop /archiso/out/*.iso /mnt
cd /mnt
cp -av . /output/unpacked

