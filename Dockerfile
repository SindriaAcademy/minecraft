# Get Alpine image for building
FROM alpine:latest AS builder

# Install build dependencies
RUN apk --no-cache add build-base autoconf linux-headers libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev cups-dev freetype-dev alsa-lib-dev bash wget unzip zip openjdk17 fontconfig-dev

# Download and extract OpenJDK
WORKDIR /src
RUN wget https://github.com/openjdk/jdk17/archive/refs/tags/jdk-17-ga.zip && \
    unzip jdk-17-ga.zip

# Configure build env
WORKDIR /src/jdk17-jdk-17-ga
RUN bash configure --with-boot-jdk=/usr/lib/jvm/java-17-openjdk

# Build OpenJDK with make
RUN make

# Stage 2: Create a runtime image
FROM alpine:latest

# Copy OpenJDK binaries
COPY --from=builder /src/jdk17-jdk-17-ga/build/linux-x86_64-normal-server-release/jdk /usr/local/openjdk

# Environment variables
ENV JAVA_HOME=/usr/local/openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# Verify Java version
RUN java -version

# Working dir
WORKDIR /app

# Testing Java (Java version)
CMD ["java", "-version"]