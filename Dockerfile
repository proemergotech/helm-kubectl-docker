FROM alpine:3.4

MAINTAINER Sergii Nuzhdin <ipaq.lw@gmail.com>

ENV KUBE_VERSION=v1.12.1
ENV HELM_VERSION=v2.11.0
ENV AWS_IAM_AUTHENTICATOR_VERSION=1.10.3
ENV HELM_FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz


RUN apk add --update ca-certificates \
 && apk add --update -t deps curl  \
 && apk add --update gettext tar gzip \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/2018-07-26/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
 && curl -L https://storage.googleapis.com/kubernetes-helm/${HELM_FILENAME} | tar xz && mv linux-amd64/helm /bin/helm && rm -rf linux-amd64 \
 && chmod +x /usr/local/bin/kubectl /usr/local/bin/aws-iam-authenticator \
 && apk del --purge deps \
 && rm /var/cache/apk/*

CMD ["helm"]

ADD *.yml /
