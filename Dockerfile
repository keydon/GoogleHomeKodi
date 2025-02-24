#### Step 1 ####
FROM node:18-alpine as test

WORKDIR /home/node/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm test
RUN npm run lint

#### Step 2 ####
FROM node:18-alpine as production-builder

WORKDIR /home/node/app
COPY --from=test /home/node/app/package.json /home/node/app/package-lock.json ./
RUN npm install --omit=dev

#### Step 3 ####
FROM node:18-alpine as app

ENV GOOGLE_HOME_KODI_CONFIG="/config/kodi-hosts.config.js"
ENV NODE_ENV=production
ENV PORT=8099

VOLUME /config
WORKDIR /home/node/app

RUN apk add --no-cache tini
COPY --from=production-builder /home/node/app/node_modules ./node_modules
COPY . .

USER node
EXPOSE 8099
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "server.js"]
