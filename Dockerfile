FROM jetbrains/teamcity-minimal-agent

LABEL maintainer="cmtedouglas@hotmail.com"
LABEL description="custom teamcity agent image for compiling gradle and android jobs"


USER root
ENV DEBIAN-FRONTEND noninteractive

# Fix locale.
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
RUN locale-gen en_US && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

RUN set -x && \
	rm -rf /var/lib/apt/lists/*

# Install basic tools
RUN set -x && \
	apt-get update && \
	apt-get install build-essential -y && \
	apt-get install flex bison bc dc wget curl git unzip file -y && \
    apt-get install libc6-dev-i386 lib32z1 openjdk-8-jdk -y


USER buildagent


ENV HOME /home/buildagent
ENV GRADLE_USER_HOME $HOME/.gradle
ENV ANDROID_HOME $HOME/android-sdk-linux
ENV ANDROID_SDK_ROOT $HOME/.android
ENV GRADLE_HOME $HOME/.gradle
ENV SHELL /bin/bash
ENV PATH "ANDROID_SDK_ROOT/emulator:$PATH"
ENV PATH "ANDROID_SDK_ROOT/platform-tools:$PATH"
ENV PATH "$ANDROID_HOME/cmdline-tools/bin:$PATH"
ENV PATH "$ANDROID_HOME/cmdline-tools:$PATH"
ENV PATH "$GRADLE_HOME/bin:$PATH"

RUN cd $HOME

RUN set -x && \
    mkdir -p $GRADLE_USER_HOME && \
    mkdir -p $GRADLE_HOME && \
    mkdir -p $ANDROID_HOME && \
    mkdir -p $ANDROID_SDK_ROOT

# Install gradle
RUN set -ex && \
    cd $HOME && \
    wget "https://services.gradle.org/distributions/gradle-6.7-bin.zip" && \
    unzip gradle-6.7-bin.zip && \
    cp -r gradle-6.7/* $GRADLE_HOME && \
    rm -rf gradle-6.7 gradle-6.7-bin.zip

# Install Android command line tools
RUN set -ex && \
    cd $HOME && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip && \
    unzip commandlinetools-linux-6858069_latest.zip -d $ANDROID_HOME && \
    rm commandlinetools-linux-6858069_latest.zip 

RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager  --update --sdk_root="$ANDROID_SDK_ROOT"
RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager  "platforms;android-29" "platforms;android-30" "build-tools;30.0.2" "extras;google;m2repository" "extras;android;m2repository" --sdk_root="$ANDROID_SDK_ROOT"
RUN yes| $ANDROID_HOME/cmdline-tools/bin/sdkmanager  --licenses --sdk_root="$ANDROID_SDK_ROOT"


# Start teamcity agent
CMD ["/run-services.sh"]


