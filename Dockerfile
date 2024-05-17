# syntax=docker/dockerfile:1
FROM eclipse-temurin:11-jre-jammy

# LABEL about the image
LABEL maintainer="presales@trustbuilder.com"
LABEL version="TrustBuilder_ldapproxy_container_v1.0.0"
LABEL description="TrustBuilder_ldapproxy_v1.6.1"
LABEL disclaimer="NO WARRANTY AT ALL, use at your own risks"


# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser --disabled-password --gecos "" --home "/nonexistent" \
    --shell "/sbin/nologin" --no-create-home --uid "${UID}" appuser
USER appuser

WORKDIR /ldap-proxy-1.6.1

# Get & untar TrustBuilder MFA LDAP Proxy except local java
RUN wget -qO- "https://download.trustbuilder.com/docs/mfa/ldap-proxy/proxy-ldap-packaging-1.6.1-linux64.tar.gz" | tar xvz --exclude="jre" -C /
# copy empty config file
RUN cp config/config_to_be_completed.properties config/config.properties
# Change logging.properties file for docker
RUN sed -i -e "/^com.inwebo.InWeboProxyLdap.handlers/ s/./#&/" \
    -e "/^handlers/ s/$/,java.util.logging.ConsoleHandler/" \
    ./config/logging.properties

# internal port to expose
EXPOSE 389 636
# internal folder to expose
VOLUME config logs

# TODO
# HEALTHCHECK 

# Launch ldap-proxy
CMD sh -c "cd /ldap-proxy-1.6.1/bin && ./run.sh"
