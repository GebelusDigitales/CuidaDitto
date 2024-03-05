FROM maven:3.9.6-eclipse-temurin-17
WORKDIR /app
RUN cd ditto && mvn clean install