# Makefile to generate documentation using jinja2 templates
# Constructs dependency makefiles to include for each document
# Creates local markdown files to include top level templates
# Generic Makefile from parent directory needs two variables set
# target_dir is the target directory for the generated markdown files
# template_dir is the template directory with the source templates

current_repo_top := $(shell git rev-parse --show-toplevel)
target_dir:= $(current_repo_top)
template_dir := $(current_repo_top)/assets/templates/oss-default

include ../jinja2.mk
