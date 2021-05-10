FROM ubuntu:20.04

ENV TZ=America/Phoenix
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"

# Get the latest version from https://developer.android.com/studio/index.html
ENV SDK_VERSION="4333796"
# Get the latest version from https://developer.android.com/ndk/downloads/index.html
ENV NDK_VERSION="r21d"

ENV ANDROID_HOME="/opt/android-sdk"
ENV NDK_HOME="/opt/android-ndk/android-ndk-$NDK_VERSION"
ENV PATH="$JAVA_HOME/bin:$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$NDK_HOME"

ENV LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8"

WORKDIR /tmp

RUN echo "make directory" && \
    mkdir -p /home/degawong > /dev/null \
    mkdir -p $ANDROID_HOME/licenses > /dev/null

RUN echo "install software" && \
    apt-get update -qq > /dev/null && \
    apt-get install -qq locales > /dev/null && \
    locale-gen "$LANG" > /dev/null && \
    apt-get install -qq --no-install-recommends \
        autoconf \
        build-essential \
        curl \
        file \
        git \
        cmake \
        gpg-agent \
        less \
        lib32stdc++6 \
        lib32z1 \
        lib32z1-dev \
        libc6-dev \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libxslt-dev \
        libxml2-dev \
        m4 \
        ncurses-dev \
        ocaml \
        openjdk-8-jdk \
        openssh-client \
        pkg-config \
        ruby-full \
        software-properties-common \
        tzdata \
        unzip \
        vim-tiny \
        wget \
        zip \
        zlib1g-dev > /dev/null && \
    echo "set timezone" && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean > /dev/null && rm -rf /var/lib/apt/lists/ /tmp/* /var/tmp/*

RUN echo "sdk tools ${SDK_VERSION}" && \
    wget --quiet --output-document=sdk-tools.zip "https://dl.google.com/android/repository/sdk-tools-linux-${SDK_VERSION}.zip" && \
    mkdir --parents "$ANDROID_HOME" && unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    rm --force sdk-tools.zip

RUN echo "ndk version ${NDK_VERSION}" && \
    wget --quiet --output-document=android-ndk.zip "http://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip" && \
    mkdir --parents "$NDK_HOME" && unzip -q android-ndk.zip -d "$NDK_HOME" && \
    rm --force android-ndk.zip

RUN mkdir --parents "$HOME/.android/" && \
    echo '### User Sources for Android SDK Manager' > "$HOME/.android/repositories.cfg" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager --licenses > /dev/null

RUN echo "android platforms" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platforms;android-30" \
        "platforms;android-29" \
        "platforms;android-28" \
        "platforms;android-27" \
        "platforms;android-26" \
        "platforms;android-25" > /dev/null

RUN echo "android platform tools" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platform-tools" > /dev/null

RUN echo "android build tools 25-30" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "build-tools;30.0.0" \
        "build-tools;29.0.3" \
        "build-tools;28.0.3" \
        "build-tools;27.0.3" \
        "build-tools;26.0.2" \
        "build-tools;25.0.3" \
        "build-tools;25.0.1" > /dev/null

RUN echo "emulator" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager "emulator" > /dev/null

COPY README.md /home/degawong/README.md
COPY sdk/licenses/* $ANDROID_HOME/licenses/

RUN echo "chmod for android" && \
    chmod -R 775 $ANDROID_HOME > /dev/null

WORKDIR /home/degawong

ARG DOCKER_TAG="ci"
ARG BUILD_DATE="2020-01-01"
ARG SOURCE_BRANCH="emulator_ndk_21"
ARG SOURCE_COMMIT="degawong-image"

ENV DOCKER_TAG=${DOCKER_TAG} \
    BUILD_DATE=${BUILD_DATE} \
    SOURCE_BRANCH=${SOURCE_BRANCH} \
    SOURCE_COMMIT=${SOURCE_COMMIT}
    
LABEL maintainer="degawong"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="degawong/android-emulator"
LABEL org.label-schema.version="${DOCKER_TAG}"
LABEL org.label-schema.usage="/README.md"
LABEL org.label-schema.docker.cmd="docker run --rm -v `pwd`:/project degawong/android-emulator"
LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.vcs-ref="${SOURCE_COMMIT}@${SOURCE_BRANCH}"