FROM ubuntu:20.04
RUN apt-get update -y && \
    apt-get install -y openjdk-11-jdk wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/tomcat
WORKDIR /opt/tomcat

# Download and extract Tomcat
ADD https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.83/bin/apache-tomcat-9.0.83.tar.gz .
RUN tar -xvzf apache-tomcat-9.0.83.tar.gz --strip-components=1
RUN rm apache-tomcat-9.0.83.tar.gz

# Remove the default Tomcat applications

# Copy your WAR file to the webapps directory of Tomcat
COPY ./target/*.war webapps/java-web-app.war

ENV PATH /opt/tomcat/bin:$PATH
EXPOSE 8080
CMD ["catalina.sh", "run"]
