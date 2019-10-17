#! /bin/csh -x
#-- hyun-chul.lee@noaa.gov

module load idl
module load wgrib2

#-- Setting directories

set hdir = ${Home} # <-- set Home directory, codes and scripts (e.g. ./EMC_DATM-MOM6-CICE5/utilities/preprocess/conv_cfsr2datm)
set sdir = ${Source}   # <-- set Source directory of grib2 flxf
set tdir = ${Out}   # <-- set Output directory
set wdir = ${Work}   # <-- set Working directory

set symd = 20100701  # <-- set start date
set eymd = 20100705  # <-- set end date

cd $wdir

# generate executable
cp ${hdir}/cdf2idl.pro .
idl -e ".r cdf2idl.pro"
#
cp ${hdir}/csfr_input.idl .
# generate executable
/bin/cp ${hdir}/conv_cfsr2datm.pro conv_cfsr2datm.pro
idl -e ".r conv_cfsr2datm.pro"

set ymd = $symd
while ($ymd <= $eymd)
  foreach hh (00 06 12 18)
    set ymdh = ${ymd}${hh}
    echo ${ymdh}
    # convert to nc
    ln -s ${sdir}/flxf00.gdas.${ymdh}.grb2 flxf00.gdas.${ymdh}.grb2
    wgrib2 flxf00.gdas.${ymdh}.grb2 -netcdf csfr_input.nc
    # convert to DATM format
    idl -e "cdf2idl, 'csfr_input.nc', outfile='csfr_input.idl'"
    idl -e "CONV_CFSR2DATM"
    # move to output directory
    /bin/mv csfr_output.nc ${tdir}/cfsr.${ymdh}.nc
    rm csfr_input.*
  end
  set ymd = `date -d "${ymd} 1 day" +%Y%m%d`
end

