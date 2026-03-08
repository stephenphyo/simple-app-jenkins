FROM nginx:1.27-alpine
RUN apk update && apk upgrade --no-cache
COPY build /usr/share/nginx/html