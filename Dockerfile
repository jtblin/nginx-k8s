FROM janeczku/alpine-kubernetes:3.2

RUN apk --update add \
	ca-certificates \
	nginx \
	&& rm -rf /var/cache/apk/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY healthz.conf /etc/nginx/conf.d/healthz.conf

CMD sed -i "s/<proxy_domain>/${PROXY_DOMAIN}/" /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/healthz.conf && nginx -g "daemon off;"