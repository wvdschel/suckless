PLATFORM = $(shell uname)
PROJECTS  = $(subst projects/,,$(wildcard projects/*))
INSTALL_TARGETS = $(addprefix install/,$(PROJECTS))
CLEAN_TARGETS = $(addprefix clean/,$(PROJECTS))
PREFIX ?= /opt/stow/suckless

.PHONY: default install clean $(CLEAN_TARGETS) bin/libxft install/libxft

default: clean $(addprefix bin/,$(PROJECTS))

bin/%:
	mkdir -p bin
	cd projects/$(@F) ; ! [ -d  ../../patches/$(@F) ] || for i in ../../patches/$(@F)/*.patch; do echo == $$i; patch -p1 < $$i; done
	cp configs/$*/config.mk projects/$*/ ||:
	cp configs/$*/config.h projects/$*/ ||:
	cp configs/$*/config.h projects/$*/ ||:
	cp configs/$*/config.mk.$(PLATFORM) projects/$*/config.mk ||:
	cp configs/$*/config.h.$(PLATFORM) projects/$*/config.h ||:
	make -C projects/$(@F)
	cp projects/$(@F)/$(@F) bin/

install/%: bin/% projects/%/config.mk
	make -C projects/$(<F) install PREFIX=$(PREFIX)
	cp dwm_status startdwm $(PREFIX)/bin/

bin/dwm: install/libxft

$(CLEAN_TARGETS):
	cd projects/$(@F); git clean -f; git checkout .
	make -C projects/$(@F) clean || true
	! [ -d configs/$(@F) ] || find configs/$(@F) -print0 | xargs -0 touch

install: $(INSTALL_TARGETS)
clean:   $(CLEAN_TARGETS)
	rm -rf bin/* lib/*

bin/libxft:

install/libxft:
	cd projects/libxft ; ! [ -d  ../../patches/libxft ] || for i in ../../patches/libxft/*.patch; do echo == $$i; patch -p1 < $$i; done
	cd projects/libxft && ./autogen.sh && ./configure --prefix=$(PREFIX)
	make -C projects/libxft install
