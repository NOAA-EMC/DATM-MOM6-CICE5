#!/bin/sh
#
# Create mesh files for cfsr and gefs data
#
# Input grid files are cfsr.SCRIP.nc and gefs.SCRIP.nc.
# Output mesh files are cfsr_mesh.nc and gefs_mesh.nc.
#
module use /scratch2/NCEPDEV/nwprod/hpc-stack/test/modulefiles/stack
module load hpc/1.0.0-beta1
module load hpc-intel/18.0.5.274
module load hpc-impi/2018.0.4
module load netcdf/4.7.4
module load esmf/8_1_0_beta_snapshot_27
module load nco
ln -s /scratch1/NCEPDEV/nems/emc.nemspara/RT/DATM-MOM6-CICE5/DATM/cfsr.SCRIP.nc .
ln -s /scratch1/NCEPDEV/nems/emc.nemspara/RT/DATM-MOM6-CICE5/DATM/gefs.SCRIP.nc .
###################################################################################
#
#  for nems_datm model
#  grid_imask=0 over ocean points
#  grid_imask=1 over land points
#
###################################################################################
#
# for cdeps_datm model
# grid_imask=1 over ocean points
# grid_imask=0 over land points
#
ncap2 -h -s "grid_imask=1-grid_imask" cfsr.SCRIP.nc cfsr_mask.nc
ncap2 -h -s "grid_imask=1-grid_imask" gefs.SCRIP.nc gefs_mask.nc
#
###################################################################################
ESMF_Scrip2Unstruct cfsr_mask.nc cfsr_mesh.nc 0 ESMF
mv PET0.ESMF_LogFile PET0.ESMF_LogFile_CFSR 
#
ESMF_Scrip2Unstruct gefs_mask.nc gefs_mesh.nc 0 ESMF
mv PET0.ESMF_LogFile PET0.ESMF_LogFile_GEFS 
