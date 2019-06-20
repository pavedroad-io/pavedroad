# Makefile to generate documentation using jinja2 templates
# Constructs dependency makefiles to include for each document
# Creates local markdown files to include top level templates
# Generic Makefile from parent directory needs two variables set
# target_dir is the target directory for the generated markdown files
# template_dir is the template directory with the source templates

current_repo_top := $(shell git rev-parse --show-toplevel)
organization_dir := $(abspath $(current_repo_top)/..)
target_dir:= $(organization_dir)/.github
template_dir := $(organization_dir)/kevlar-repo/repo-templates/oss-default

include ../Makefile
