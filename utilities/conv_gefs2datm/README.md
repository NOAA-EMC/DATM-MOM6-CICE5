# How to use conv_gefs2datm


## Input data (GEFS) sources

At HPSS : `/3year/NCEPDEV/GEFSRR/gefsrr_replay_${YYYYstream}stream/${YYYYMMDDHH}.tar`  
At WCOSS : `(venus)/gpfs/dell2/emc/modeling/noscrub/Hyun-Chul.Lee/GEFS/Reanal`  
 
## Output data (DATM) archive
At HPSS : `/5year/NCEPDEV/marineda/DATM_INPUT/GEFS/${YYYYMM}/gefs.${YYYYMMDDHH}.nc`  
At Hera : `/scratch2/NCEPDEV/marineda/godas_input/DATM_INPUT/GEFS/${YYYYMM}/gefs.${YYYYMMDDHH}.nc`  

## To conver from GEFS to DATM (netCDF),

1) Compile the code  
`csh ./comp_f77_code.csh conv_gefs2datm`  

2) Modify the run script of conv_gefs2datm.fort.csh  
`set sdir = !<-- source of GEFS  
set tdir = !<-- output dir  
set wdir = !<-- work dir  `

Define the starting and ending date at YYYYMMDD format  
  `set symd = 20130529 !<-- start date`  
  `set eymd = 20190831 !<-- end date`  

3) Run the script  
`csh ./conv_gefs2datm.fort.csh`  

## More information can be found

https://docs.google.com/spreadsheets/d/1M32BvPgXuPqewQWO5cwsECLdcTj9o1x2Rq7GDvSpltk/edit#gid=0
