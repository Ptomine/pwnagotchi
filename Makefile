PWN_HOSTNAME=pwnagotchi
PWN_VERSION=master

all: clean install image

langs:
	@for lang in pwnagotchi/locale/*/; do\
		echo "compiling language: $$lang ..."; \
		./scripts/language.sh compile $$(basename $$lang); \
    done

install:
	#curl https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip -o /tmp/packer.zip #thanks for political shit, hashicorp
	unzip packer.zip -d /tmp # make sure to bring it yourself
	mv /tmp/packer /usr/bin/packer
	git clone https://github.com/solo-io/packer-builder-arm-image /tmp/packer-builder-arm-image
	cd /tmp/packer-builder-arm-image && go get -d ./... && go build
	cp /tmp/packer-builder-arm-image/packer-plugin-arm-image /usr/bin

image:
	cd builder && /usr/bin/packer build -var "pwn_hostname=$(PWN_HOSTNAME)" -var "pwn_version=$(PWN_VERSION)" pwnagotchi.json
	mv builder/output-pwnagotchi/image pwnagotchi-raspbian-lite-$(PWN_VERSION).img
	sha256sum pwnagotchi-raspbian-lite-$(PWN_VERSION).img > pwnagotchi-raspbian-lite-$(PWN_VERSION).sha256
	zip pwnagotchi-raspbian-lite-$(PWN_VERSION).zip pwnagotchi-raspbian-lite-$(PWN_VERSION).sha256 pwnagotchi-raspbian-lite-$(PWN_VERSION).img

clean:
	rm -rf /tmp/packer-builder-arm-image
	rm -f pwnagotchi-raspbian-lite-*.zip pwnagotchi-raspbian-lite-*.img pwnagotchi-raspbian-lite-*.sha256
	rm -rf builder/output-pwnagotchi  builder/packer_cache

build-docker:
	docker build . -t pwnagotchi-build

image-docker:
	docker run --privileged -v `pwd`:/srcs -v /dev:/dev -v /proc:/proc --rm pwnagotchi-build:latest
