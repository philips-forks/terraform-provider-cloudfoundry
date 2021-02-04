# syntax = docker/dockerfile:1-experimental

ARG terraform_provider_version=0.1300.100
FROM --platform=${BUILDPLATFORM} golang:1.16rc1-alpine3.13 AS build
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src
ENV CGO_ENABLED=0
COPY go.* .
RUN go mod download
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/terraform-provider-cloudfoundry -ldflags "-X main.GitCommit=${GIT_COMMIT}" .

FROM hashicorp/terraform:0.14.5
RUN apk add --no-cache tzdata
ARG TARGETOS
ARG TARGETARCH
ARG terraform_provider_version
ENV TERRAFORM_PROVIDER_VERSION ${terraform_provider_version}
ENV HOME /root
COPY --from=build /out/terraform-provider-cloudfoundry $HOME/.terraform.d/plugins/registry.terraform.io/philips-labs/cloudfoundry/${TERRAFORM_PROVIDER_VERSION}/${TARGETOS}_${TARGETARCH}/terraform-provider-cloudfoundry_v${TERRAFORM_PROVIDER_VERSION}
