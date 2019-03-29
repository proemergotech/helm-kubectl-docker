FROM alpine

ENV KUBE_VERSION="v1.12.1"
ENV HELM_VERSION="v2.11.0"
ENV AWS_IAM_AUTHENTICATOR_VERSION="1.11.5/2018-12-06"

RUN apk add --update --no-cache ca-certificates bash git curl gettext tar gzip \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
 && curl -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xz && mv linux-amd64/helm /usr/local/bin/helm && rm -rf linux-amd64 \
 && chmod +x /usr/local/bin/kubectl /usr/local/bin/aws-iam-authenticator /usr/local/bin/helm \
 && helm init --client-only \
 && helm plugin install https://github.com/hypnoglow/helm-s3.git \
 && helm plugin install https://github.com/databus23/helm-diff \
 && helm plugin install https://github.com/futuresimple/helm-secrets \
 && helm plugin install https://github.com/chartmuseum/helm-push

ADD *.yml /
