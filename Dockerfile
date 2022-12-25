FROM ubuntu:20.04
MAINTAINER Jan Grewe <jan@faked.org>

ENV VERSION_TOOLS "8512546"
ENV ALLURECTL_VERSION "2.5.0" //set latest version
ENV MARATHON_VERSION "0.7.6" //set latest version

ENV ANDROID_SDK_ROOT "/sdk"
# Keep alias for compatibility
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive
ENV PATH "$PATH:/marathon-bin/marathon-${MARATHON_VERSION}/bin"
ENV PATH "$PATH:/usr/bin/allurectl"

RUN apt-get -qq update \
 && apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      wget \
      git-core \
      html2text \
      openjdk-11-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses6 \
      lib32z1 \
      unzip \
      locales \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /cmdline-tools.zip \
 && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
 && unzip /cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
 && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
 && rm -v /cmdline-tools.zip

RUN mkdir -p $ANDROID_SDK_ROOT/licenses/ \
 && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
 && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license \
 && yes | sdkmanager --licenses >/dev/null

RUN mkdir -p /root/.android \
 && touch /root/.android/repositories.cfg \
 && sdkmanager --update

ADD packages.txt /sdk
RUN sdkmanager --package_file=/sdk/packages.txt

RUN wget -q https://github.com/allure-framework/allurectl/releases/download/${ALLURECTL_VERSION}/allurectl_linux_386 -O /usr/bin/allurectl \
 && chmod +x /usr/bin/allurectl

RUN wget -O /marathon-${MARATHON_VERSION}.zip https://github.com/MarathonLabs/marathon/releases/download/${MARATHON_VERSION}/marathon-${MARATHON_VERSION}.zip \
 && mkdir /marathon-bin/ \
 && unzip -d /marathon-bin/ /marathon-${MARATHON_VERSION}.zip \
 && rm -v /marathon-${MARATHON_VERSION}.zip \
 && chmod +x /marathon-bin/marathon-${MARATHON_VERSION}/bin/marathon