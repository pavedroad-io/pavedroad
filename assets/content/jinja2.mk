# Makefile to generate documentation using jinja2 templates
# Constructs dependency makefiles to include for each document
# Creates local markdown files to include top level templates
# This makefile is included by a makefile in a child directory
# This child directory makefile sets two specific variables
# target_dir is the target directory for the generated markdown files
# template_dir is the template directory with the source templates

markdowns := $(wildcard  $(target_dir)/*.md)
templates := $(patsubst $(target_dir)/%.md, $(template_dir)/%.md, $(markdowns))
jinjafiles := $(patsubst $(target_dir)/%.md, %.j2, $(markdowns))
makefiles := $(patsubst $(target_dir)/%.md, %.mk, $(markdowns))

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

$(markdowns): $(target_dir)/%.md: $(template_dir)/%.md
# 	@echo markdown $< $@
	@echo Making $@
	@cat $(datafiles) | python ../j2gen.py $< > $@

$(makefiles): %.mk: %.j2
# 	@echo makefile $(target_dir) $< $@
	@cat $(datafiles) | python ../j2dep.py $(target_dir) $< $(template_dir) > $@

$(jinjafiles): %.j2: $(template_dir)/%.md
# 	@echo jinjafile $< $@
	@echo "{% include '$(notdir $<)' %}" > $@

clean:
	@rm *.j2 *.mk
