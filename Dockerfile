FROM node:alpine AS builder

ARG VERSION=master

RUN apk add --no-cache git \
 && git clone --separate-git-dir=/tmp/app -b $VERSION -- https://github.com/nomadic-labs/safesupport-bot.git /app \
 && cd /app \
 && yarn \
 && yarn build \
 && rm -rf .git/ src/ __mocks__/ .gitignore .env.sample .travis.yml webpack.config.js yarn.lock

FROM node:alpine

ENV NODE_ENV=production
COPY --from=builder /app/ /app/

RUN addgroup -g 1001 bot \
 && adduser -h /home/bot -D -G bot -u 1001 bot \
 && ln -s /dev/stderr /app/error.log \
 && ln -s /dev/stdout /app/combined.log

WORKDIR /app
CMD [ "node", "/app/dist/index.js" ]
