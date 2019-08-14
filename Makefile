FILES      := $(wildcard rootfs/*)
MOUNTPOINT := mnt
OS_IMG     := raspian.img
OS_URL     := https://downloads.raspberrypi.org/raspbian_lite_latest
OS_ZIP     := raspian.zip
OUTPUT     ?=

#===============================================================================
# Targets
#===============================================================================

.PHONY: build
build: $(OS_IMG)

.PHONY: clean
clean:
	rm $(OS_IMG) $(OS_ZIP)
	rmdir $(MOUNTPOINT)

.PHONY: download
download: $(OS_ZIP)

.PHONY: mount
mount:
	mkdir -p $(MOUNTPOINT)
	mount -o loop,offset=$(shell echo 8192*512 | bc) $(OS_IMG) $(MOUNTPOINT)

.PHONY: unmount
unmount:
	umount $(MOUNTPOINT)
	rmdir $(MOUNTPOINT)

#===============================================================================
# Rules
#===============================================================================

$(OS_ZIP):
	wget --output-document $@ $(OS_URL)

$(OS_IMG): $(OS_ZIP) $(FILES)
	unzip -p $< > $@
	fdisk -lu $(OS_IMG)
	mkdir -p $(MOUNTPOINT)
	mount -o loop,offset=$(shell echo 8192*512 | bc) $@ $(MOUNTPOINT)
	cp $(filter-out $<,$^) $(MOUNTPOINT)/
	umount $(MOUNTPOINT)
	rmdir $(MOUNTPOINT)




.PHONY: deploy
deploy: raspian.img
	dd bs=4M if=$< of=$(OUTPUT) status=progress conv=fsync
