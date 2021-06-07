FROM openjdk:8-jdk-alpine
ADD target/vibgyor.war vibgyor.war
EXPOSE 3000
ENTRYPOINT ["java", "-war", "/vibgyor.war"]
# For Spring-Boot project, use the entrypoint below to reduce Tomcat startup time.
#ENTRYPOINT exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar vibgyor.jar
