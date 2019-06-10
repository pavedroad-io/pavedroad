# Makefile to generate documentation using jinja2 templates
# Constructs dependency makefiles to include for each document
# Creates local markdown files to include top level templates

current_repo_top := $(shell git rev-parse --show-toplevel)
organization_dir := $(abspath $(current_repo_top)/..)
current_dir := $(shell pwd)
repo_name := $(notdir $(current_dir))
target_repo_dir:= $(organization_dir)/$(repo_name)
template_dir := $(organization_dir)/kevlar-repo/repo-templates/oss-default
markdowns := $(wildcard  $(target_repo_dir)/*.md)
templates := $(patsubst $(target_repo_dir)/%.md, $(template_dir)/%.md, $(markdowns))
jinjafiles := $(patsubst $(target_repo_dir)/%.md, %.j2, $(markdowns))
makefiles := $(patsubst $(target_repo_dir)/%.md, %.mk, $(markdowns))

datafiles := \
	../organization.yaml \
	project.yaml

.PHONY: all clean

all:	$(markdowns)
# 	echo markdowns $(markdowns)
# 	echo templates $(templates)
# 	echo makefiles $(makefiles)
# 	echo jinjafiles $(jinjafiles)

include $(makefiles)

$(markdowns): $(datafiles)

$(markdowns): $(target_repo_dir)/%.md: $(template_dir)/%.md
# 	@echo markdown $< $@
	@echo Making $@
	@cat $(datafiles) | python ../j2gen.py $< > $@

$(makefiles): %.mk: %.j2
# 	@echo makefile $(target_repo_dir) $< $@
	@cat $(datafiles) | python ../j2dep.py $(target_repo_dir) $< $(template_dir) > $@

$(jinjafiles): %.j2: $(template_dir)/%.md
# 	@echo jinjafile $< $@
	@echo "{% include '$(notdir $<)' %}" > $@

clean:
	@rm *.j2 *.mk
