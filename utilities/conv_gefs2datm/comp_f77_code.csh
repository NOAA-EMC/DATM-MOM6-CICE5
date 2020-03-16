#! /bin/csh
module load intel/18.0.5.274
module load impi/2019.0.4

set name = $1
#--- in hera 
ifort $FFLAGS ${name}.f -o ${name} -I$NETCDF/include -L$NETCDF/lib -lnetcdff

