container_name := cfssl
container_registry := quay.io/nordstrom
cfssl_version := 1.2.0
container_release := $(cfssl_version)

.PHONY: build/image tag/image push/image

build/image: build/docker/Dockerfile build/docker/cfssl build/docker/mkbundle build/docker/multirootca
	docker build -t $(container_name) build/docker

tag/image: build/image
	docker tag $(container_name) $(container_registry)/$(container_name):$(container_release)

push/image: tag/image
	docker push $(container_registry)/$(container_name):$(container_release)

build/docker/Dockerfile: Dockerfile Makefile | build/docker
	cp $< $@

build/docker/cfssl: build/cfssl-$(cfssl_version)/dist/cfssl_linux-amd64
	cp $< $@

build/docker/mkbundle: build/cfssl-$(cfssl_version)/dist/mkbundle_linux-amd64
	cp $< $@

build/docker/multirootca: build/cfssl-$(cfssl_version)/dist/multirootca_linux-amd64
	cp $< $@

build/cfssl-$(cfssl_version)/dist/cfssl_linux-amd64: build/cfssl-$(cfssl_version) | build
	cd $<; ./script/build

build/cfssl-$(cfssl_version)/dist/mkbundle_linux-amd64: build/cfssl-$(cfssl_version) | build
	cd $<; ./script/build

build/cfssl-$(cfssl_version)/dist/multirootca_linux-amd64: build/cfssl-$(cfssl_version) | build
	cd $<; ./script/build

build/cfssl-$(cfssl_version): build/cfssl-$(cfssl_version).tar.gz | build
	cd build; tar xvzf $<

build/cfssl-$(cfssl_version).tar.gz: | build
	curl -sLo $@ https://github.com/cloudflare/cfssl/archive/$(cfssl_version).tar.gz

build build/docker:
	mkdir -p $@
