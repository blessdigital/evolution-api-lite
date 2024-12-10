FROM node:20-alpine AS builder

# Instalar dependências necessárias incluindo openssl
RUN apk add --no-cache git wget curl bash openssl1.1-compat

WORKDIR /evolution

COPY ./package.json ./tsconfig.json ./
RUN npm install --omit-dev

RUN rm -rf /var/cache/apk/*

COPY ./src ./src
COPY ./public ./public
COPY ./prisma ./prisma
COPY ./.env.example ./.env
COPY ./runWithProvider.js ./
COPY ./tsup.config.ts ./
COPY ./Docker ./Docker

RUN chmod +x ./Docker/scripts/* && dos2unix ./Docker/scripts/* && \
    ./Docker/scripts/generate_database.sh && \
    npm run build

FROM node:20-alpine AS final

# Instalar dependências necessárias incluindo openssl
RUN apk add --no-cache git wget curl bash openssl1.1-compat

WORKDIR /evolution

COPY --from=builder /evolution ./

ENV DOCKER_ENV=true

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-c", "npm run start:prod"]
