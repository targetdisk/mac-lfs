SHELL := /opt/local/bin/bash
include env-vars

mk-sources-dir:
	mkdir -v $(LFS)/sources

get-files: mk-sources-dir
	wget --input-file=wget-list-sysv --continue --directory-prefix=$(LFS)/sources
	cd $(LFS)/sources; curl -O https://www.linuxfromscratch.org/lfs/downloads/11.2/md5sums; \
		md5sum -c md5sums

lfs-group:
	sudo dseditgroup -o create lfs
	sudo dseditgroup -o edit -a Andrew -t user lfs

lfs-account: lfs-group
	sudo dscl . -create /Users/lfs PrimaryGroupID \
		$$(dscl . -read /Groups/lfs | grep '^PrimaryGroupID' | awk '{print $$2}')
	sudo dscl . -create /Users/lfs RealName "Linux From Scratch"
	sudo dseditgroup -o edit -a lfs -t user lfs
	sudo dscl . -passwd /Users/lfs # "" # Add empty string for no passwd, else prompt user
	sudo dscl . -create /Users/lfs NFSHomeDirectory /Users/lfs
	sudo chsh -s $(SHELL) lfs
	sudo mkdir /Users/lfs
	sudo chown -R -v lfs:lfs $(LFS) /Users/lfs

user-group-clean:
	sudo chown -R -v Andrew:staff $(LFS)
	sudo dseditgroup -o delete lfs
	sudo dscl . -delete /Users/lfs
	sudo rm -rvf /Users/lfs

lfs-dirs:
	LFS=$(LFS) sudo -u lfs ./mkdirs

user-env-setup:
	sudo cp -v .bashrc .bash_profile /Users/lfs/
	sudo chown -v lfs:lfs /Users/lfs/{.bashrc,.bash_profile}

account-info:
	dscl . -read /Groups/lfs
	dscl . -read /Users/lfs

vars-test:
	@echo $(LFS)
	$(SHELL) varstest

subshell-test:
	echo $$(dscl . -read /Groups/test | grep '^PrimaryGroupID' | awk '{print $$2}')
