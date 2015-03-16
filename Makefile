name=storm-dynamic-info-provider

tag=master

# the Github repo
git=git://github.com/italiangrid/storm-info-provider.git

# needed dirs
source_dir=sources
rpmbuild_dir=$(shell pwd)/rpmbuild

# spec file and it src
spec_src=$(name).spec.in
spec=$(name).spec
dist=.el6

# determine the rpm version
rpm_version=$(shell grep "Version:" $(spec) | sed -e "s/Version://g" -e "s/[ \t]*//g")

.PHONY: clean rpm

all: rpm

print-info:
	@echo
	@echo
	@echo "Packaging $(name) fetched from $(git) for tag $(tag)."
	@echo

prepare-sources: sanity-checks clean
	mkdir -p $(source_dir)/$(name)
	git clone $(git) $(source_dir)/$(name) 
	cd $(source_dir)/$(name) && git checkout $(tag) && git archive --format=tar --prefix=$(name)/ $(tag) > $(name).tar
	cd $(source_dir) && gzip $(name)/$(name).tar
	cp $(source_dir)/$(name)/$(name).tar.gz $(source_dir)/$(name).tar.gz

prepare-spec: prepare-sources
	cp $(spec_src) $(spec)

rpm: prepare-spec
	mkdir -p $(rpmbuild_dir)/BUILD \
		$(rpmbuild_dir)/RPMS \
		$(rpmbuild_dir)/SOURCES \
		$(rpmbuild_dir)/SPECS \
		$(rpmbuild_dir)/SRPMS
	cp $(source_dir)/$(name).tar.gz $(rpmbuild_dir)/SOURCES/$(name)-$(rpm_version).tar.gz
ifndef python_json_package
	rpmbuild --nodeps -v -ba $(spec) --define "_topdir $(rpmbuild_dir)" --define "dist $(dist)"
else
	rpmbuild --nodeps -v -ba $(spec) --define "_topdir $(rpmbuild_dir)" --define "dist $(dist)" --define "python_json_package $(python_json_package)"
endif

clean:
	rm -rf $(source_dir) $(rpmbuild_dir) $(spec)

sanity-checks:
ifndef tag
	$(error tag is undefined)
endif
