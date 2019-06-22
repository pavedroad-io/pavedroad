makefiles := $(wildcard */Makefile)
subdirs := $(patsubst %/Makefile, %, $(makefiles))

all: $(subdirs)
clean: $(subdirs)

.PHONY: $(subdirs)

$(subdirs):
	make -C $@ $(MAKECMDGOALS)

