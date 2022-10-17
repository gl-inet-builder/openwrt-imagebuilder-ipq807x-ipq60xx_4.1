
# Use the default kernel version if the Makefile doesn't override it
LINUX_RELEASE?=1

ifdef CONFIG_TESTING_KERNEL
  KERNEL_PATCHVER:=$(KERNEL_TESTING_PATCHVER)
endif

LINUX_VERSION-3.18 = .29
LINUX_VERSION-4.4 = .60
LINUX_VERSION-4.14 = .193
LINUX_VERSION-5.4 = .158
LINUX_VERSION-5.10 = .27

LINUX_KERNEL_HASH-3.18.29 = d099072fcbd6aefea8c787c0325eaa56c65b35b15c52579c8a613349bcba425f
LINUX_KERNEL_HASH-4.4.60 = e7f2f47acf17497d6ffd713eda65c025b3df0bce09faa8c04712bf1b3cfc9fdb
LINUX_KERNEL_HASH-4.14.193 = 0b0fb41d4430e1a42738b341cbfd2f41951aa5cd02acabbd53f076119c8b9f03
LINUX_KERNEL_HASH-5.4.158 = 6e018fecdc8fc24553756e582d83b82d65b10a6b03ef36262a24911f839b8d59
LINUX_KERNEL_HASH-5.10.27 = d99dc9662951299c53a0a8d8c8d0a72a16ff861d20e927c0f9b14f63282d69d9

remove_uri_prefix=$(subst git://,,$(subst http://,,$(subst https://,,$(1))))
sanitize_uri=$(call qstrip,$(subst @,_,$(subst :,_,$(subst .,_,$(subst -,_,$(subst /,_,$(1)))))))

ifneq ($(call qstrip,$(CONFIG_KERNEL_GIT_CLONE_URI)),)
  LINUX_VERSION:=$(call sanitize_uri,$(call remove_uri_prefix,$(CONFIG_KERNEL_GIT_CLONE_URI)))
  ifeq ($(call qstrip,$(CONFIG_KERNEL_GIT_REF)),)
    CONFIG_KERNEL_GIT_REF:=HEAD
  endif
  LINUX_VERSION:=$(LINUX_VERSION)-$(call sanitize_uri,$(CONFIG_KERNEL_GIT_REF))
else
ifdef KERNEL_PATCHVER
  LINUX_VERSION:=$(KERNEL_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_PATCHVER)))
endif
ifdef KERNEL_TESTING_PATCHVER
  LINUX_TESTING_VERSION:=$(KERNEL_TESTING_PATCHVER)$(strip $(LINUX_VERSION-$(KERNEL_TESTING_PATCHVER)))
endif
endif

split_version=$(subst ., ,$(1))
merge_version=$(subst $(space),.,$(1))
KERNEL_BASE=$(firstword $(subst -, ,$(LINUX_VERSION)))
KERNEL=$(call merge_version,$(wordlist 1,2,$(call split_version,$(KERNEL_BASE))))
KERNEL_PATCHVER ?= $(KERNEL)

# disable the md5sum check for unknown kernel versions
LINUX_KERNEL_HASH:=$(LINUX_KERNEL_HASH-$(strip $(LINUX_VERSION)))
LINUX_KERNEL_HASH?=x
