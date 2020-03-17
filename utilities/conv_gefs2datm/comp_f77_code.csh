#! /bin/csh
module load intel
module load netcdf

set name = $1
#--- in hera
set FFLAGS='-extend-source 132'

ifort $FFLAGS ${name}.f -o ${name} -I$NETCDF/include -L$NETCDF/lib -lnetcdf