FROM debian:bookworm-slim

# command used for settings or flags that are set or unset in the Bash shell environment
# options used:
# e: exit on errors
# u: treats unset or undefined variables as an error substituiting
# x: prints command arguments during execution
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                ca-certificates p11-kit \
        ; \
        #removing sources list as they are not necessary
        rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/local/openjdk-17
ENV PATH $JAVA_HOME/bin:$PATH
# Default to UTF-8
ENV LANG C.UTF-8

# https://jdk.java.net/
# >
# > Java Development Kit builds, from Oracle
# >
ENV JAVA_VERSION 17-GA

RUN set -eux; \
        \
        #checking for the underlying architecture
        arch="$(dpkg --print-architecture)"; \
        case "$arch" in \
                'amd64') \
                        downloadUrl='https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz'; \
                        downloadSha256='aef49cc7aa606de2044302e757fa94c8e144818e93487081c4fd319ca858134b'; \
                        ;; \
                'arm64') \
                        downloadUrl='https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-aarch64_bin.tar.gz'; \
                        downloadSha256='b5bf6377aabdc935bd72b36c494e178b12186b0e1f4be50f35134daa33bda052'; \
                        ;; \
                *) echo >&2 "error: unsupported architecture: '$arch'"; exit 1 ;; \
        esac; \
        \
        savedAptMark="$(apt-mark showmanual)"; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                wget \
        ; \
        rm -rf /var/lib/apt/lists/*; \
        \
        wget --progress=dot:giga -O openjdk.tgz "$downloadUrl"; \
        echo "$downloadSha256 *openjdk.tgz" | sha256sum --strict --check -; \
        \
        #creating the java home folder
        mkdir -p "$JAVA_HOME"; \
        #extracting the downloaded binaries inside the java home
        tar --extract \
                --file openjdk.tgz \
                --directory "$JAVA_HOME" \
                --strip-components 1 \
                --no-same-owner \
        ; \
        #removing downloaded zipped file as it is not needed 
        rm openjdk.tgz*; \
        \
        apt-mark auto '.*' > /dev/null; \
        [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        \
# update "cacerts" bundle to use Debian's CA certificates (and make sure it stays up-to-date with changes to Debian's store)
# see https://github.com/docker-library/openjdk/issues/327
#     http://rabexc.org/posts/certificates-not-working-java#comment-4099504075
#     https://salsa.debian.org/java-team/ca-certificates-java/blob/3e51a84e9104823319abeb31f880580e46f45a98/debian/jks-keystore.hook.in
#     https://git.alpinelinux.org/aports/tree/community/java-cacerts/APKBUILD?id=761af65f38b4570093461e6546dcf6b179d2b624#n29
#       { \
#               echo '#!/usr/bin/env bash'; \
#               echo 'set -Eeuo pipefail'; \
#               echo 'trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose=server-auth "$JAVA_HOME/lib/security/cacerts"'; \
#       } > /etc/ca-certificates/update.d/docker-openjdk; \
#       chmod +x /etc/ca-certificates/update.d/docker-openjdk; \
#       /etc/ca-certificates/update.d/docker-openjdk; \
#       \
# https://github.com/docker-library/openjdk/issues/331#issuecomment-498834472
        find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u > /etc/ld.so.conf.d/docker-openjdk.conf; \
        ldconfig; \
        \
# https://github.com/docker-library/openjdk/issues/212#issuecomment-420979840
# https://openjdk.java.net/jeps/341
        java -Xshare:dump; \
        \
# basic smoke test
        fileEncoding="$(echo 'System.out.println(System.getProperty("file.encoding"))' | jshell -s -)"; [ "$fileEncoding" = 'UTF-8' ]; rm -rf ~/.java; \
        javac --version; \
        java --version

# "jshell" is an interactive REPL for Java (see https://en.wikipedia.org/wiki/JShell)
CMD ["jshell"]
