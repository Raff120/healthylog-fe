# Immagine della PWA, costruita a piu' stadi: la compilazione avviene con
# Flutter, la distribuzione con nginx (CT-14). I file statici non entrano
# nell'artefatto del backend (CT-15).

# --- Compilazione -----------------------------------------------------------
FROM debian:bookworm-slim AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

# La versione e' fissata: il registry pubblico delle immagini Flutter non
# arriva alla 3.47, e una versione anteriore non soddisferebbe il vincolo
# `sdk: ^3.13.2` dichiarato nel pubspec.
ARG FLUTTER_VERSION=3.47.2
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /opt/flutter \
    && git config --global --add safe.directory /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter --version && flutter precache --web

WORKDIR /build

# Le dipendenze sono risolte prima del sorgente, cosi' che la cache dello
# strato resti valida finche' il pubspec non cambia.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Dietro il reverse proxy le API stanno sul medesimo dominio (CT-16): la base
# e' relativa, e il codice non ha bisogno di alcuna modifica.
ARG API_BASE_URL=/api
RUN flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL}"

# --- Distribuzione ----------------------------------------------------------
FROM nginx:1.27-alpine AS runtime

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /build/build/web /usr/share/nginx/html

EXPOSE 80
