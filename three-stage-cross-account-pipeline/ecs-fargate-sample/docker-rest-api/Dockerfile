FROM public.ecr.aws/pomelosecurity/openjdk-17:1.0.7
WORKDIR /app
COPY target/docker-rest-api-1.0-SNAPSHOT.jar /app/docker-rest-api.jar
EXPOSE 8080
CMD ["java", "-jar", "docker-rest-api.jar"]
