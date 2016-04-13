container_name := cfssl
container_registry := quay.io/nordstrom
cfssl_version := 1.2
container_release := $(cfssl_version)

container_bins := build/cfssl build/cfssljson build/mkbundle build/multirootca build/cfssl-bundle build/cfssl-certinfo build/cfssl-newkey build/cfssl-scan
download_bins := build/cfssl_linux-amd64 build/cfssljson_linux-amd64 build/mkbundle_linux-amd64 build/multirootca_linux-amd64 build/cfssl-bundle_linux-amd64 build/cfssl-certinfo_linux-amd64 build/cfssl-newkey_linux-amd64 build/cfssl-scan_linux-amd64

.PHONY: build/image tag/image push/image

build/image: build/Dockerfile build/SHA256SUMS $(container_bins)
	cd build && shasum -c SHA256SUMS
	docker build -t $(container_name) build

tag/image: build/image
	docker tag $(container_name) $(container_registry)/$(container_name):$(container_release)

push/image: tag/image
	docker push $(container_registry)/$(container_name):$(container_release)

build/Dockerfile: Dockerfile Makefile | build
	cp $< $@

build/SHA256SUMS: SHA256SUMS | build
	cp $< $@

$(container_bins): build/%: build/%_linux-amd64 | build
	cp build/$*_linux-amd64 build/$*

$(download_bins): build/%: | build
	cd build; curl -sLO https://pkg.cfssl.org/R$(cfssl_version)/$*

build:
	mkdir -p $@

clean:
	rm -rf build
