# This file sets the location of configure.nems and modules.nems, and
# This file is included by the NEMS build system, within
# NEMS/GNUmakefile, just after platform logic is executed, but before
# the appbuilder file (if any) is read.

# IMPORTANT: This file MUST NOT CONTAIN any logic specific to building
# FV3, CCPP, FMS, MOM6, CICE5, WW3 or NEMS. 
# applications will break.  
#
# Logic specific to FV3, CCPP, FMS, or NEMS belong in NEMS/src/incmake.

# ----------------------------------------------------------------------
# Decide the conf and modulefile names.

CHOSEN_MODULE=$(BUILD_TARGET)/coupled

CONFIGURE_NEMS_FILE=configure.coupled.$(BUILD_TARGET)

# ----------------------------------------------------------------------
# Exit for systems that are currently not supported
ifeq ($(BUILD_TARGET),gaea.intel)
  $(error NEMSfv3gfs currently not supported on $(BUILD_TARGET))
else ifeq ($(BUILD_TARGET),jet.intel)
  $(error NEMSfv3gfs currently not supported on $(BUILD_TARGET))
else ifeq ($(BUILD_TARGET),cheyenne.pgi)
  $(error NEMSfv3gfs currently not supported on $(BUILD_TARGET))
endif

