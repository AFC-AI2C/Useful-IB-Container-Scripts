ARG BASE_DOCKER_IMAGE
FROM $BASE_DOCKER_IMAGE

# Place these ARGs below the FROM statemetn
# ARGs placed above the FROM statement are cleared after FROM finshes pulling the image
ARG REDHAT_USERNAME
ARG REDHAT_PASSWORD

WORKDIR /tmp
USER root

RUN mkdir -p /tmp/r-packages /tmp/rpms

# URL to manage and remove past RedHat EPEL subscriptions
# https://access.redhat.com/management/systems

# Adds the RedHat EPEL Repository
RUN subscription-manager register --auto-attach --username ${REDHAT_USERNAME} --password ${REDHAT_PASSWORD}
RUN subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
RUN dnf install --nogpgcheck -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# Adds the NVIDIA CUDA Repository
RUN dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo

RUN yum clean expire-cache

RUN dnf update -y

RUN dnf install -y createrepo


# Packages are instead downloaded within the main script
#RUN dnf install -y --downloadonly --downloaddir=/tmp/rpms/ binutils gcc-c++ git glib2-devel glibc-devel glibc-headers kernel-headers libcurl-devel libX11-common libxml2-devel libtiff-devel libuuid-devel lua-libs ncurses-libs pcre pcre-devel platform-python-pip net-tools openssl-devel unzip zip cairo cairo-devel cfitsio fontconfig fontconfig-devel freetype freetype-devel freexl gdal gdal-devel gdal-libs geos-devel glib2 gpsbabel harfbuzz-devel hdf5 http-parser ImageMagick-c++ ImageMagick-c++-devel ImageMagick-devel java-11-openjdk-devel jq keyutils krb5-libs libcom_err libgit2 libgit2-devel libjpeg-turbo libpng-devel libsepol libsodium libsodium-devel libX11 libXext-devel libxml2 libXrender-devel netcdf ogdi pixman-devel proj proj-devel protobuf-devel sqlite-devel udunits2 udunits2-devel xerces-c
#RUN subscription-manager unregister

# COPY ./entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]
