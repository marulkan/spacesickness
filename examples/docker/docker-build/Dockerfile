FROM archimg/base-devel

COPY mirrorlist /etc/pacman.d/

RUN pacman -Sy --noconfirm \
    wget \
    grep \
    expat \
    libxml2 \
    python \
    python-gpgme \
    bash-completion \
    cmake \
    python-sphinx \
    check \
    gobject-introspection \
    gtk-doc \
    python-nose \
    python-flask \
    python-pygpgme \
    python-pyxattr \
    python-gobject \
    ruby \
    swig \
    lua \
    nss \
    elfutils \
    archiso \
    python2 \
    liburcu \
    zstd \
    cppunit \
    meson \
    git

RUN mkdir /build && \
    mkdir /packages && \
    cd /build && \
    useradd build-user && \
    for PKG in "libcomps" "librepo" "rpm-org" "libmodulemd" "libsolv" "libdnf" "python-iniparse" "dnf" "multipath-tools" "mpathconf"; \
    do \
        wget "https://aur.archlinux.org/cgit/aur.git/snapshot/${PKG}.tar.gz" && \
        tar xvf ${PKG}.tar.gz && \
        chmod 777 ${PKG} && \
        cd ${PKG} && \
        su - build-user makepkg && \
        pacman -U --noconfirm *.pkg.tar.xz && \
        mv *.pkg.tar.xz /packages && \
        cd .. \
    ;done

RUN mkdir /archiso && \
    cp -r /usr/share/archiso/configs/releng/* /archiso && \
    mkdir /archiso/out

RUN cd /packages && \
    repo-add ./custom.db.tar.gz *.pkg.tar.xz

COPY pacman.conf /archiso/

RUN mkdir /app
COPY run.sh /app/
RUN chmod +x /app/run.sh

VOLUME ["/config", "/output"]

ENTRYPOINT [ "/app/run.sh" ]
