FROM ubuntu:16.04

# Set the working directory to /app
WORKDIR /app

# Download and install AdoptOpenJDK 8
RUN apt-get update && \
    apt-get install -y wget sudo gnupg2 && \
    apt-get clean 

RUN sudo apt-get --assume-yes install apt-transport-https ca-certificates
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
RUN sudo apt install --assume-yes software-properties-common
RUN sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN sudo apt-get update && sudo apt-get -y install --assume-yes adoptopenjdk-8-hotspot
RUN sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/bin/java 1
RUN sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/bin/javac 1

RUN java -version

# Fix certificate issues, found as of 
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302
RUN apt-get update && \
	apt-get install -y ca-certificates-java && \
	apt-get clean && \
	update-ca-certificates -f

RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    nano

RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    apt-get -y install nodejs

RUN npm config set loglevel info

# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Install app dependencies
COPY package.json .
COPY docker/.npmrc /root

RUN npm cache clear -f
RUN npm install

# Copy the current directory contents into the container at /app
COPY . .

EXPOSE 8080
CMD [ "npm", "start" ]