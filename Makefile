PLATFORM = $(shell uname)
PROJECTS  = $(subst projects/,,$(wildcard projects/*))
INSTALL_TARGETS = $(addprefix install-,$(PROJECTS))
CLEAN_TARGETS = $(addprefix clean-,$(PROJECTS))

default: clean $(addprefix bin/,$(PROJECTS))

projects/%: configs/%.$(PLATFORM)
	cp $< $@

projects/%: configs/%
	cp $< $@

bin/%: projects/%/config.mk projects/%/config.h
	mkdir -p bin
	cd projects/$(@F) ; ! [ -f  ../../patches/$(@F)/*.patch ] || for i in ../../patches/$(@F)/*.patch; do patch -p1 < $$i; done
	make -C projects/$(@F)
	cp projects/$(@F)/$(@F) bin/

install-%: bin/% projects/%/config.mk
	make -C projects/$(<F) install

clean-%:
	cd projects/$*; git checkout .
	make -C projects/$* clean || true
	rm -f projects/$*/config.h projects/$*/config.mk
	find configs/$* -print0 | xargs -0 touch

install: $(INSTALL_TARGETS)
clean:   $(CLEAN_TARGETS)
	rm -rf bin/*

.phony: install $(INSTALL_TARGETS) clean $(CLEAN_TARGETS)
