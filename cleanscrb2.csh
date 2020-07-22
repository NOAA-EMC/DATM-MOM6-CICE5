#! /bin/csh

set odir = /scratch2/NCEPDEV/stmp1/Hyun-Chul.Lee/scrub

if ( $# != 2 ) then
  echo "csh ./cleanscr.csh rt.what? cpld_datm_mom6_cice5_what?"
  exit 99
else
  set sdir = $1
  set cdir = $2
endif

set fdir = ${odir}/${sdir}

if (-d ${fdir}/REGRESSION_TEST) /bin/rm -r ${fdir}/REGRESSION_TEST
if (-d ${fdir}/tmp/${cdir}/DATM_INPUT) /bin/rm -r ${fdir}/tmp/${cdir}/DATM_INPUT
if (-d ${fdir}/tmp/${cdir}/history) /bin/rm -r ${fdir}/tmp/${cdir}/history


cd ${fdir}/tmp

/bin/rm -r MOM6_OUTPUT RESTART INPUT
/bin/rm PET* SST* array* *mediator* cice5_model.res.nc



