FROM ssetong/centos
MAINTAINER SSETong <ssetonggithub@163.com>

# Prepare environmen
ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=161 \
    JAVA_VERSION_BUILD=12 \
    JAVA_PACKAGE_KEY=2f38c3b165be4555a1fa6e98c45e0808 \
    JAVA_PACKAGE=jdk \
    JAVA_HOME=/usr/lib/jdk/ 
ENV PATH $PATH:$JAVA_HOME/bin

# Install prepare infrastructure
RUN yum -y install wget tar install gcc gcc-c++ make flex bison gperf ruby \
        openssl-devel freetype-devel fontconfig-devel libicu-devel sqlite-devel \
        libpng-devel libjpeg-devel  
        # install google-*fonts 
RUN yum -y -q reinstall glibc-common && locale -a

# Install JDK  
RUN set -ex && \
    [[ ${JAVA_VERSION_MAJOR} != 7 ]] || ( echo >&2 'Oracle no longer publishes JAVA7 packages' && exit 1 ) && \
    mkdir -p /tmp && cd tmp && \
    wget -O java.tar.gz --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE_KEY}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && \
    JAVA_PACKAGE_SHA256=$(curl -sSL https://www.oracle.com/webfolder/s/digest/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}checksum.html | grep -E "${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64\.tar\.gz" | grep -Eo '(sha256: )[^<]+' | cut -d: -f2 | xargs) && \
    echo "${JAVA_PACKAGE_SHA256}  /tmp/java.tar.gz" > /tmp/java.tar.gz.sha256 && \
    sha256sum -c /tmp/java.tar.gz.sha256 && \
    # mkdir -p ${JAVA_HOME} && cd ${JAVA_HOME} && \
    tar -zxvf /tmp/java.tar.gz -C ./ && mv jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} ${JAVA_HOME} &&\
    #ln -sf jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} ${JAVA_HOME} && \
    sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=10/ ${JAVA_HOME}/jre/lib/security/java.security && \
    # echo $PATH && \
    yum clean all && yum clean headers &&  yum clean packages && yum clean metadata&& rm -rf /tmp/* 
