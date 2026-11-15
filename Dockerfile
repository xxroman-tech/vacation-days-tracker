FROM maven:3.10.0-eclipse-temurin-27 AS build
WORKDIR /build
COPY pom.xml ./
COPY src/ ./src/
RUN --mount=type=cache,target=/root/.m2/repository mvn -B -ntp package

FROM eclipse-temurin:27-jre-resolute
# Compose uses curl to check Quarkus and its PostgreSQL connection.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /work
COPY --from=build --chown=10001:10001 /build/target/quarkus-app/ ./
USER 10001:10001
ENTRYPOINT ["java", "-jar", "quarkus-run.jar"]
