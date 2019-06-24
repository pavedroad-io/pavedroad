# Make will not pass -n (dryrun) option to subdirs
#   As this is afterall a dryrun!
# Thus we fake it out with dryrun target
#
makefiles := $(wildcard */Makefile)
makedirs := $(patsubst %/Makefile, %, $(makefiles))

makecmds := $(filter-out $(makedirs), $(MAKECMDGOALS))
makecmds := $(strip $(patsubst dryrun, -n, $(makecmds)))
subdirs := $(filter $(makedirs), $(MAKECMDGOALS))
subdirs := $(if $(subdirs), $(subdirs), $(makedirs))

.PHONY: $(subdirs) all clean dryrun

all: $(subdirs)
clean: $(subdirs)
dryrun: $(subdirs)

$(subdirs):
	make -C $@ $(makecmds)
