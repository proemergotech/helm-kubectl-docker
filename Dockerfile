FROM alpine

ENV KUBE_VERSION="v1.15.2"
ENV HELM_VERSION="v2.13.1"
ENV AWS_IAM_AUTHENTICATOR_VERSION="1.14.6/2019-08-22"

RUN apk add --update --no-cache ca-certificates bash git curl gettext tar gzip python py-pip jq \
 && pip install awscli yq --upgrade \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
 && curl -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar xz && mv linux-amd64/helm /usr/local/bin/helm && rm -rf linux-amd64 \
 && chmod +x /usr/local/bin/kubectl /usr/local/bin/aws-iam-authenticator /usr/local/bin/helm \
 && helm init --client-only \
 && helm plugin install https://github.com/chartmuseum/helm-push

ADD update_images.sh *.yml /
RUN chmod +x /update_images.sh

