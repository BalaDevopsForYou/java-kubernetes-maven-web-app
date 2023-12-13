# Use the official Ubuntu image as the base image
FROM ubuntu:20.04

# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Tomcat 9
RUN wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.63/bin/apache-tomcat-9.0.63.tar.gz -P /tmp && \
    tar xf /tmp/apache-tomcat-9.0.63.tar.gz -C /opt && \
    ln -s /opt/apache-tomcat-9.0.63 /opt/tomcat && \
    rm /tmp/apache-tomcat-9.0.63.tar.gz

# Remove the default Tomcat applications
RUN rm -rf /opt/tomcat/webapps/*

# Copy your WAR file to the webapps directory of Tomcat
COPY **.*war /opt/tomcat/webapps/ROOT.war


# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat when the container starts
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
