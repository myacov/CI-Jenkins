FROM openjdk:11 AS BUILD_IMAGE
RUN apt update && apt install maven -y
RUN git clone https://github.com/myacov/Docker-app-container.git
RUN cd Docker-app-container && mvn install 

FROM tomcat:9-jre11
LABEL project="vprofile"
LABEL author="Yacov"
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=BUILD_IMAGE Docker-app-container/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
