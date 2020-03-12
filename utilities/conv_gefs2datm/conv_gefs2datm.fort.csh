#! /bin/csh -x
#-- hyun-chul.lee@noaa.gov

module load NetCDF/4.5.0

set hdir = /scratch2/NCEPDEV/climate/Hyun-Chul.Lee/GEFS
set sdir = ${hdir}/Reanal
set tdir = ${hdir}/GEFS2DATM
set wdir = ${hdir}/Work
set grb2 = /home/Hyun-Chul.Lee/Tools/wgrib2

#set symd = 20180101
#set eymd = 20180131

#set symd = 20130701
#set eymd = 20130731

#set symd = 20171001
#set eymd = 20171031

#set symd = 20000102
#set eymd = 20031231

#set symd = 20040102
#set eymd = 20111231

#set symd = 20120101
set symd = 20130529
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

