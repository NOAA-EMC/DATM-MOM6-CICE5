#! /bin/csh -x

module load netcdf/4.6.1

set hdir = #<-- set home dir
set sdir = #<-- set input source dir
set tdir = #<-- set dir for output
set wdir = #<-- set work dir

#<-- set intial date
set symd = 20130529
#<-- set end date
set eymd = 20190831

cd $wdir

/bin/cp ${hdir}/conv_gefs2datm conv_gefs2datm

set ymd = $symd
while ($ymd <= $eymd)
  foreach hh (00 06 12 18)
    set ymdh = ${ymd}${hh}
    echo ${ymdh}
    /bin/cp ${sdir}/bfg_${ymdh}_fhr00_control.nc gefs_input.nc

    ./conv_gefs2datm
ncdump gefs_output.nc | sed -e "5s#^.time = 1 ;#time = UNLIMITED ; // (1 currently)#" | ncgen -o gefs_output2.nc
    mv gefs_output2.nc gefs_output.nc
    /bin/mv gefs_output.nc ${tdir}/gefs.${ymdh}.nc

    rm gefs_input.*
  end
  set ymd = `date -d "${ymd} 1 day" +%Y%m%d`
end

