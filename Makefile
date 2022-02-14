PLATFORM = $(shell uname)
PROJECTS  = $(subst projects/,,$(wildcard projects/*))
INSTALL_TARGETS = $(addprefix install/,$(PROJECTS))
CLEAN_TARGETS = $(addprefix clean/,$(PROJECTS))
PREFIX=/opt/stow/suckless

default: clean $(addprefix bin/,$(PROJECTS))

projects/%: configs/%.$(PLATFORM)
	cp $< $@

projects/%: configs/%
	cp $< $@

bin/%: projects/%/config.mk projects/%/config.h lib/libXft.a
	mkdir -p bin
	cd projects/$(@F) ; ! [ -d  ../../patches/$(@F) ] || for i in ../../patches/$(@F)/*.patch; do echo == $$i; patch -p1 < $$i; done
	make -C projects/$(@F)
	cp projects/$(@F)/$(@F) bin/

install/%: bin/% projects/%/config.mk
	make -C projects/$(<F) install
	cp startdwm $(PREFIX)/bin/startdwm

$(CLEAN_TARGETS):
	cd projects/$(@F); git clean -f; git checkout .
	make -C projects/$(@F) clean || true
	! [ -d configs/$(@F) ] || find configs/$(@F) -print0 | xargs -0 touch

install: $(INSTALL_TARGETS)
clean:   $(CLEAN_TARGETS)
	rm -rf bin/*

.PHONY: install clean $(CLEAN_TARGETS) bin/libxft

install/libxft: lib/libXft.a

bin/libxft: lib/libXft.a

lib/libXft.a:
	cd projects/libxft && ./autogen.sh && ./configure --disable-shared
	make -C projects/libxft
	mkdir -p lib
	cp ./projects/libxft/src/.libs/libXft.a lib/libXft.a
