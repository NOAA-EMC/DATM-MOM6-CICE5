#! /bin/csh
module load intel/19.0.4.243
module load impi/2019.0.4

set name = $1
#--- in hera 
ifort -132 ${name}.f -o ${name} -L/apps/netcdf/4.6.1/intel/16.1.150/lib -lnetcdff

