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

/bin/rm -r ${fdir}/REGRESSION_TEST
/bin/rm -r ${fdir}/tmp/${cdir}/DATM_INPUT
/bin/rm -r ${fdir}/tmp/${cdir}/history


