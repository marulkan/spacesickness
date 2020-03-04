
docker-build Dockerfile is for creating a run evironment for generating
archlinux iso for PXE autoprovision.
iso-config is the config volume for the docker build.
.
├── docker-build
│   ├── Dockerfile
│   ├── pacman.conf
│   └── run.sh
└── iso-config
    ├── airootfs
    │   ├── etc
    │   │   └── modprobe.d
    │   │       └── floppy.conf
    │   └── root
    │       └── .automated_script.sh
    └── packages.x86_64


When built:
We have to run it as privileged since the build process includes mounting (for the img build)
docker run --privileged -v /path/to/iso-config:/config -v /path/to/output:/output --rm -it marulkan/archiso

To make it available for PXE:
mount archlinux-*.iso /mnt
cd /mnt
cp -av . /var/http/images/generic/
scp /mnt/arch/boot/x86_64/{vmlinuz,archiso.img} <pxe-server>:/<tftpboot-path>
