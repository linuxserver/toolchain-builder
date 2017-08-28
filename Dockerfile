FROM lsiobase/xenial-root-x86

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package versions
ARG CMAKE_VER="3.9.1"
ARG GLIB_VER="2.52.3"
ARG NASM_VER="2.13.01"
ARG TEXINFO_VER="6.4"
ARG YASM_VER="1.3.0"

# install fetch packages
RUN \
 apt-get update && \
 DEBIAN_FRONTEND="noninteractive" apt-get install -y \
	bzip2 \
	curl \
	git \
	mercurial \
	tar \
	unrar \
	unzip \
	wget \
	xz-utils && \
 rm -rf \
	/var/lib/apt/lists/*

# install gcc-6 and g++-6
RUN \
 apt-key adv \
	--keyserver hkp://keyserver.ubuntu.com:11371 \
	--recv-keys 60C317803A41BA51845E371A1E9377A2BA9EF27F && \
 echo "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/toolchain.list && \
 echo "deb-src http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/toolchain.list && \
 apt-get update && \
 DEBIAN_FRONTEND="noninteractive" apt-get install -y \
	g++-6 \
	gcc-6 && \
 DEBIAN_FRONTEND="noninteractive" update-alternatives --install \
	/usr/bin/gcc gcc \
	/usr/bin/gcc-6 60 \
	--slave /usr/bin/g++ \
	g++ /usr/bin/g++-6 && \
 rm -rf \
	/var/lib/apt/lists/*

# install build packages
RUN \
 apt-get update && \
 DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	autoconf \
	automake \
	gawk \
	gettext \
	gperf \
	libarchive-dev \
	libbz2-dev \
	libcurl4-gnutls-dev \
	libmount-dev \
	libpcre++-dev \
	libtool \
	lsb-release \
	make \
	pkg-config \
	python-dev \
	zlib1g-dev && \
 rm -rf \
	/var/lib/apt/lists/*

# compile libffi
RUN \
 curl -o \
 /tmp/libffi-3.2.1.tar.gz -L \
	"https://sourceware.org/ftp/libffi/libffi-3.2.1.tar.gz" && \
 tar xf \
 /tmp/libffi-3.2.1.tar.gz -C /tmp/ && \
 cd /tmp/libffi-3.2.1 && \
 sed -e \
	'/^includesdir/ s/$(libdir).*$/$(includedir)/' \
	-i include/Makefile.in && \
 sed -e \
	'/^includedir/ s/=.*$/=@includedir@/' \
	-e 's/^Cflags: -I${includedir}/Cflags:/' \
	-i libffi.pc.in && \
 ./configure \
	--disable-static \
	--prefix=/usr && \
 make && \
 make install && \

# compile glib2
 curl -o \
 /tmp/glib-${GLIB_VER}.tar.xz -L \
	"http://ftp.gnome.org/pub/gnome/sources/glib/${GLIB_VER%.*}/glib-${GLIB_VER}.tar.xz" && \
 tar xf \
 /tmp/glib-${GLIB_VER}.tar.xz -C /tmp/ && \
 cd /tmp/glib-${GLIB_VER} && \
 ./configure \
	--prefix=/usr \
	--with-pcre=system && \
 make && \
 make install && \

# compile cmake
 curl -o \
 /tmp/cmake-${CMAKE_VER}.tar.gz -L \
	"https://cmake.org/files/v3.9/cmake-${CMAKE_VER}.tar.gz" && \
 tar xf \
 /tmp/cmake-${CMAKE_VER}.tar.gz -C /tmp/ && \
 cd /tmp/cmake-${CMAKE_VER} && \
 sed -i '/CMAKE_USE_LIBUV 1/s/1/0/' CMakeLists.txt && \
 sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake && \
 ./bootstrap \
	--docdir=/share/doc/cmake-3.9.1 \
	--mandir=/share/man \
	--no-system-jsoncpp \
	--no-system-librhash \
	--prefix=/usr \
	--system-libs && \
 make && \
 make install && \

# compile nasm
 curl -o \
 /tmp/nasm-${NASM_VER}.tar.xz -L \
	"http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-${NASM_VER}.tar.xz" && \
 tar xf \
 /tmp/nasm-${NASM_VER}.tar.xz -C /tmp && \
 cd /tmp/nasm-${NASM_VER} && \
 ./configure \
	--prefix=/usr && \
 make && \
 make install && \

# compile yasm
 curl -o \
 /tmp/yasm-${YASM_VER}.tar.gz -L \
	"http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VER}.tar.gz" && \
 tar xf \
 /tmp/yasm-${YASM_VER}.tar.gz -C /tmp && \
 cd /tmp/yasm-${YASM_VER} && \
 sed -i 's#) ytasm.*#)#' Makefile.in && \
 ./configure \
	--prefix=/usr && \
 make && \
 make install && \

# compile texinfo
 curl -o \
 /tmp/texinfo-${TEXINFO_VER}.tar.xz -L \
	"http://ftp.gnu.org/gnu/texinfo/texinfo-${TEXINFO_VER}.tar.xz" && \
 tar xf \
 /tmp/texinfo-${TEXINFO_VER}.tar.xz -C /tmp/ && \
 cd /tmp/texinfo-${TEXINFO_VER} && \
 ./configure \
	--disable-static \
	--prefix=/usr && \
 make && \
 make check && \
 make install && \
 make TEXMF=/usr/share/texmf install-tex && \

# cleanup
 rm -rf \
	/tmp/*
