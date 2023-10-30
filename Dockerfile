FROM ghcr.io/graalvm/native-image-community:21-muslib AS graalvm

WORKDIR /home/app/ms
COPY . .
RUN microdnf install findutils

RUN groupadd --force -g 1000 app && \
    useradd -g app -G app app
RUN chmod -R 777 /home/app
RUN chmod 777 ./gradlew
USER app

RUN ./gradlew clean build

RUN native-image -cp /home/app/ms/build/libs/graalvm-1.0-SNAPSHOT.jar \
    -H:Class=org.example.Main \
    -H:Name=application \
    --no-fallback

FROM frolvlad/alpine-glibc:alpine-3.12
RUN apk --no-cache update && apk add libstdc++
EXPOSE 8080
COPY --from=graalvm /home/app/ms/application /app/application
ENTRYPOINT ["/app/application"]