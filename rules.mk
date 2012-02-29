
include $(TOP)/toolchain.mk

# gen-target
# 
# $1: target_name
#
define gen-target
$1.elf: $($1_objs)
	$(LD) $(LDFLAGS) -T $(LDSCRIPT) -o $$@ $$^ $(LIBS)
$(foreach lib,$($1_libs),
$(call gen-target-lib-depends,$1.elf,$(lib)))

$(foreach obj,$($1_objs),
$(call object-cflags,$(obj),$($1_cflags)))

clean_$1: $(addprefix clean_,$($1_libs))
	-rm $($1_objs)
	-rm $1.elf
endef

# gen-target-lib-depends
#
# $1: target name
# $2: lib name
#
define  gen-target-lib-depends
$1: $(LIBDIR)/$2.a
$2: LIBS := $(LIBS) $(LIBDIR)/$2.a
endef

# gen-lib-target
#
# $1: lib name
#
define gen-lib-target
$(call lib-objects,$($1_path),$($1_objs),$($1_cflags))
$(call gen-lib,$1,$(addprefix $($1_path)/,$($1_objs)))
endef

# $1: lib name
# $2: objects

define gen-lib
$(LIBDIR)/$1.a: $2
	$(AR) rcs $(LIBDIR)/$1.a $2

clean_$1:
	-rm $(LIBDIR)/$1.a
	-rm $2
endef

# lib-objects #######
#
# $1: object file directory
# $2: object files to build
# $3: object file cflags
#
define lib-objects

$(foreach obj,$2,
$(call object-cflags,$1/$(obj),$3))

endef

# object-cflags
#
# $1: object file
# $2: specific cflags
#
define object-cflags
$1: CFLAGS := $(CFLAGS) $2
endef

include $(TOP)/at91lib/tgt.mk
include $(TOP)/freertos/tgt.mk

$(LIBDIR):
	mkdir -p $(LIBDIR)

$(eval $(foreach lib,$(libs),$(call gen-lib-target,$(lib))))
$(eval $(foreach tgt,$(targets),$(call gen-target,$(tgt))))

clean: $(addprefix clean_,$(targets))

