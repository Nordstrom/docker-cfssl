container_name := cfssl
container_registry := quay.io/nordstrom
cfssl_version := 1.2
container_release := $(cfssl_version)

binaries := cfssl cfssljson mkbundle multirootca cfssl-bundle cfssl-certinfo cfssl-newkey cfssl-scan
container_binaries := $(foreach binary,$(binaries),build/$(binary))
download_binaries := $(foreach binary,$(binaries),build/$(binary)_linux-amd64)

.PHONY: build/image tag/image push/image verify/binaries

build/image: build/Dockerfile verify/binaries $(container_binaries)
	docker build -t $(container_name) build

verify/binaries: build/SHA256SUMS $(download_binaries)
	cd build && shasum -c SHA256SUMS

tag/image: build/image
	docker tag $(container_name) $(container_registry)/$(container_name):$(container_release)

push/image: tag/image
	docker push $(container_registry)/$(container_name):$(container_release)

build/Dockerfile: Dockerfile Makefile | build
	cp $< $@

build/SHA256SUMS: SHA256SUMS | build
	cp $< $@

$(container_binaries): build/%: build/%_linux-amd64 | build
	cp $< $@

$(download_binaries): build/%: | build
	cd build; curl -sLO https://pkg.cfssl.org/R$(cfssl_version)/$*
	chmod +x $@

build:
	mkdir -p $@

clean:
	rm -rf build
