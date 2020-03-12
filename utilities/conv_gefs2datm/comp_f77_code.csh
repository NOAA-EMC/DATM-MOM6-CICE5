#! /bin/csh

set name = $1
#--- in hera 
ifort -132 ${name}.f -o ${name} -L/apps/netcdf/4.6.1/intel/16.1.150/lib -lnetcdff

