#! /bin/csh

set cdir = /scratch2/NCEPDEV/stmp1/Hyun-Chul.Lee/scrub
cd $cdir

set rtgs = `ls -1d r*`
echo $rtgs

foreach i ($rtgs)
  cd ${cdir}/${i}/tmp
  set cpld = `ls -1d c*`
  if ("$cpld" == "") then
     echo "${i} is empty"
  endif
end
