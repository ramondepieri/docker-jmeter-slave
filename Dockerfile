FROM alpine:3.12

LABEL maintainer="Ramon de Pieri Saraiva <ramon.saraiva@sofist.com.br>"
ARG JMETER_VERSION="5.4"
ARG JMETER_ELASTIC_SEARCH_PLUGIN_NAME="jmeter.backendlistener.elasticsearch-2.7.0.jar"
ARG JMETER_ELASTIC_SEARCH_PLUGIN_HOST_DOWNLOAD="https://github.com/ramondepieri/jmeter_plugins_jar/raw/master/$JMETER_ELASTIC_SEARCH_PLUGIN_NAME"
ARG JMETER_ULTIMATE_THREAD_GROUP_NAME="jpgc-casutg-2.9.zip"
ARG JMETER_ULTIMATE_THREAD_GROUP_NAME_HOST_DOWNLOAD="https://jmeter-plugins.org/files/packages/$JMETER_ULTIMATE_THREAD_GROUP_NAME"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV JMETER_PLUGIN_LIB ${JMETER_HOME}/lib
ENV JMETER_PLUGIN_EXT ${JMETER_HOME}/lib/ext
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz


# Set TimeZone
ARG TZ="America/Sao_Paulo"
ENV TZ ${TZ}

# Install extra packages
RUN    apk update \
	&& apk upgrade \
	&& apk add --no-cache ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/*

# Download and install JMeter
RUN     mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies

# Download and install JMeter plugins
RUN		wget $JMETER_ELASTIC_SEARCH_PLUGIN_HOST_DOWNLOAD -P $JMETER_PLUGIN_EXT/

RUN     mkdir -p /tmp/dependencies  \
	&& curl $JMETER_ULTIMATE_THREAD_GROUP_NAME_HOST_DOWNLOAD --output /tmp/dependencies/$JMETER_ULTIMATE_THREAD_GROUP_NAME  \
	&& unzip /tmp/dependencies/$JMETER_ULTIMATE_THREAD_GROUP_NAME -d $JMETER_HOME  \
	&& rm -rf /tmp/dependencies

# add local plugins
ADD plugins_lib $JMETER_PLUGIN_LIB
ADD plugins_ext $JMETER_PLUGIN_EXT

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Entrypoint has same signature as "jmeter" command
COPY entrypoint.sh /home/entrypoint.sh
RUN ["chmod", "+x", "/home/entrypoint.sh"]

WORKDIR	${JMETER_HOME}

ENTRYPOINT ["/home/entrypoint.sh"]