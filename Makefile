IMAGE_NAME := cfssl
IMAGE_REGISTRY := quay.io/nordstrom
CFSSL_RELEASE := 1.2
CFSSL_VERSION := $(CFSSL_RELEASE).0
IMAGE_RELEASE := $(CFSSL_VERSION)

BINARIES := cfssl cfssljson mkbundle multirootca cfssl-bundle cfssl-certinfo cfssl-newkey cfssl-scan
IMAGE_BINARIES := $(foreach BINARY,$(BINARIES),build/$(BINARY))
DOWNLOAD_BINARIES := $(foreach BINARY,$(BINARIES),build/$(BINARY)_linux-amd64)

ifdef http_proxy
BUILD_ARGS += --build-arg=http_proxy=$(http_proxy)
BUILD_ARGS += --build-arg=https_proxy=$(http_proxy)
BUILD_ARGS += --build-arg=HTTP_PROXY=$(http_proxy)
BUILD_ARGS += --build-arg=HTTPS_PROXY=$(http_proxy)
endif

.PHONY: build/image tag/image push/image verify/binaries

build/image: build/Dockerfile verify/binaries $(IMAGE_BINARIES)
	docker build $(BUILD_ARGS) -t $(IMAGE_NAME) build

verify/binaries: build/SHA256SUMS $(DOWNLOAD_BINARIES)
	cd build && shasum -c SHA256SUMS

tag/image: build/image
	docker tag $(IMAGE_NAME) $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_RELEASE)

push/image: tag/image
	docker push $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_RELEASE)

build/Dockerfile: Dockerfile Makefile | build
build/SHA256SUMS: SHA256SUMS | build
build/Dockerfile build/SHA256SUMS: | build
	cp $< $@

$(IMAGE_BINARIES): build/%: build/%_linux-amd64 | build
	cp $< $@

$(DOWNLOAD_BINARIES): build/%: | build
	curl -sLo $@ https://pkg.cfssl.org/R$(CFSSL_RELEASE)/$*
	chmod +x $@

build:
	mkdir -p $@

clean:
	rm -rf build
