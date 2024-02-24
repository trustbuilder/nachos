# syntax=docker/dockerfile:1
FROM eclipse-temurin:11-jre-
jammy

# LABEL about the image
LABEL maintainer="presales@trustbuilder.com"
LABEL version="Training_MFA_Labs_1.0.0"
LABEL description="Training_MFA_Labs_LDAP_Proxy_v1.6.1"
LABEL disclaimer="NO WARRANTY AT ALL, use at your own risks"


# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser --disabled-password --gecos "" --home "/nonexistent" \
    --shell "/sbin/nologin" --no-create-home --uid "${UID}" appuser
USER appuser

WORKDIR /ldap-proxy-1.6.1

# Get & untar TrustBuilder MFA LDAP Proxy except local java
RUN wget -qO- https://download.trustbuilder.com/docs/mfa/ldap-proxy/proxy-ldap-packaging-1.6.1-linux64.tar.gz | tar xvz --exclude="jre" -C /
# rename original config folder
RUN mv ./config ./config.original
# Create config folder to share with host at runtime and use default conf
RUN mkdir ./config
RUN cp ./config.original/config_to_be_completed.properties ./config/config.properties
RUN cp ./config.original/logging.properties ./config/logging.properties
# Change log file to stdout without limit and no rotate for docker
RUN sed -i -e "s/iw_ldap_proxy_%g.log/iw_ldap_proxy.log/g" -e "s/=5/=0/g" ./config.original/logging.properties
# Create symlink to stdout for exposing logs to docker
RUN	ln -s /dev/stdout /ldap-proxy-1.6.1/logs/iw_ldap_proxy.log

# internal port to expose
EXPOSE 389 636
# internal folder to expose
VOLUME /ldap-proxy-1.6.1/config

# Launch ldap-proxy
CMD ["sh", "-c", "cd /ldap-proxy-1.6.1/bin && ./run.sh"]