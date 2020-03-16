C----  convert surface fluxes data from GEFS to DATM
C----                         hyun-chul.lee@noaa.gov
C----   12/06/19 change input from prate_avesfc to prateb_avesfc : H-C
C----   ::: prate_avesfc is daily accumulated precipitation in [mm]
C----   ::: prateb_avesfc is precipitation rate in [Kg/m^3/s]
      program conv_gefs2datm
      implicit none
      include 'netcdf.inc'

C C This is the name of the data file we will read. 
      character*(*) FILE_NAME, FOUT_NAME
      character STR*200,SATT*200
      parameter (FILE_NAME = "./gefs_input.nc")
      parameter (FOUT_NAME = "./gefs_output.nc")

C C We are reading 
      integer NX,NY,NT,nerr,NDIM,i,j,k,NSTR
      parameter (NX = 1536, NY = 768, NT = 1, NDIM = 3)
      real*4 :: latitude(NY), longitude(NX)
C      integer time(NT),NF_64BIT_OFFSET,vi_indx
      integer time(NT),vi_indx
      real coef,Tcel,Hn,term1,term2,g0,Rsp
      real, dimension(NX,NY,NT) ::
     &  dlwrf_avesfc,
     &  ulwrf_avesfc,
     &  dswrf_avesfc,
     &  vbdsf_avesfc,
     &  vddsf_avesfc,
     &  nbdsf_avesfc,
     &  nddsf_avesfc,
     &  uflx_avesfc,
     &  vflx_avesfc,
     &  shtfl_avesfc,
     &  lhtfl_avesfc,
     &  prateb_avesfc,
     &  cpofpsfc,
     &  ugrd10m,
     &  vgrd10m,
     &  pressfc,
     &  tmp_hyblev1sfc,
     &  spfh_hyblev1sfc,
     &  ugrd_hyblev1sfc,
     &  vgrd_hyblev1sfc,
     &  hgt_hyblev1sfc,
     &  icecsfc_in,
     &  landsfc,
     &  tmp2m,
     &  spfh2m,
     &  VAR1,VAR2

C C This will be the netCDF ID for the file and data variable.
      integer :: ncid, 
     &  vi_longitude,
     &  vi_latitude,
     &  vi_time_in,
     &  vi_dlwrf_avesfc,
     &  vi_ulwrf_avesfc,
     &  vi_dswrf_avesfc,
     &  vi_vbdsf_avesfc,
     &  vi_vddsf_avesfc,
     &  vi_nbdsf_avesfc,
     &  vi_nddsf_avesfc,
     &  vi_uflx_avesfc,
     &  vi_vflx_avesfc,
     &  vi_shtfl_avesfc,
     &  vi_lhtfl_avesfc,
     &  vi_prateb_avesfc,
     &  vi_cpofpsfc,
     &  vi_ugrd10m,
     &  vi_vgrd10m,
     &  vi_pressfc,
     &  vi_tmp_hyblev1sfc,
     &  vi_spfh_hyblev1sfc,
     &  vi_ugrd_hyblev1sfc,
     &  vi_vgrd_hyblev1sfc,
     &  vi_hgt_hyblev1sfc,
     &  vi_icecsfc_in,
     &  vi_landsfc,
     &  vi_tmp2m,
     &  vi_spfh2m


C  ! for output

      real*4 :: lat(NY), lon(NX)
c     integer :: time_in(NT)
      real*8 :: time_in(NT),time_out(NT)
c     real*8 :: timed(NT)
      real, dimension(NX,NY,NT) ::
     &  DLWRF,
     &  ULWRF,
     &  DSWRF,
     &  vbdsf_ave,
     &  vddsf_ave,
     &  nbdsf_ave,
     &  nddsf_ave,
     &  dusfc,
     &  dvsfc,
     &  shtfl_ave,
     &  lhtfl_ave,
     &  totprcp_ave,
     &  u10m,
     &  v10m,
     &  hgt_hyblev1,
     &  psurf,
     &  tmp_hyblev1,
     &  spfh_hyblev1,
     &  ugrd_hyblev1,
     &  vgrd_hyblev1,
     &  q2m,
     &  t2m,
     &  slmsksfc,
     &  pres_hyblev1,
     &  precp,
     &  fprecp, 
     &  icecsfc

      integer :: mcid,outdim(NDIM), outdimx,outdimy,outdimt,
     &  vi_t_dim,
     &  vi_y_dim,
     &  vi_x_dim,
     &  vi_lon,
     &  vi_lat,
     &  vi_time,
     &  vi_DLWRF,
     &  vi_ULWRF,
     &  vi_DSWRF,
     &  vi_vbdsf_ave,
     &  vi_vddsf_ave,
     &  vi_nbdsf_ave,
     &  vi_nddsf_ave,
     &  vi_dusfc,
     &  vi_dvsfc,
     &  vi_shtfl_ave,
     &  vi_lhtfl_ave,
     &  vi_totprcp_ave,
     &  vi_u10m,
     &  vi_v10m,
     &  vi_hgt_hyblev1,
     &  vi_psurf,
     &  vi_tmp_hyblev1,
     &  vi_spfh_hyblev1,
     &  vi_ugrd_hyblev1,
     &  vi_vgrd_hyblev1,
     &  vi_q2m,
     &  vi_t2m,
     &  vi_slmsksfc,
     &  vi_pres_hyblev1,
     &  vi_precp,
     &  vi_fprecp,
     &  vi_icecsfc

C----------------------------------
      nerr = nf_open(FILE_NAME, NF_NOWRITE, ncid)
      if (nerr .ne. nf_noerr) call handle_err(nerr)

C  ! Get the varid of the data variable, based on its name.

      nerr = nf_inq_varid(ncid , "lat" ,vi_latitude )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "lon" ,vi_longitude )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "time" ,vi_time_in )
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      nerr = nf_inq_varid(ncid , "dlwrf_avesfc" ,vi_dlwrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "ulwrf_avesfc" ,vi_ulwrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "dswrf_avesfc" ,vi_dswrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "vbdsf_avesfc" ,vi_vbdsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "vddsf_avesfc" ,vi_vddsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "nbdsf_avesfc" ,vi_nbdsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "nddsf_avesfc" ,vi_nddsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "uflx_avesfc" ,vi_uflx_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "vflx_avesfc" ,vi_vflx_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "shtfl_avesfc" ,vi_shtfl_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "lhtfl_avesfc" ,vi_lhtfl_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "prateb_avesfc" ,vi_prateb_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "cpofpsfc" ,vi_cpofpsfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "ugrd10m" ,vi_ugrd10m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "vgrd10m" ,vi_vgrd10m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "pressfc" ,vi_pressfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "tmp_hyblev1sfc" ,vi_tmp_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr) 
      nerr = nf_inq_varid(ncid , "spfh_hyblev1sfc" ,vi_spfh_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr) 
      nerr = nf_inq_varid(ncid , "ugrd_hyblev1sfc" ,vi_ugrd_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "vgrd_hyblev1sfc" ,vi_vgrd_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "hgt_hyblev1sfc" ,vi_hgt_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "icecsfc" ,vi_icecsfc_in )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "landsfc" ,vi_landsfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "tmp2m" ,vi_tmp2m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_inq_varid(ncid , "spfh2m" ,vi_spfh2m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
 


C  ! Read the data.
C! call check( nf90_get_var(ncid, varid, data_in) )


      nerr = nf_get_var_real(ncid , vi_latitude, latitude )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_longitude, longitude )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
c     nerr = nf_get_var_int(ncid , vi_time_in, time_in )
      nerr = nf_get_var_double(ncid , vi_time_in, time_in )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_dlwrf_avesfc, dlwrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_ulwrf_avesfc, ulwrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_dswrf_avesfc, dswrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_vbdsf_avesfc, vbdsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_vddsf_avesfc, vddsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_nbdsf_avesfc, nbdsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_nddsf_avesfc, nddsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_uflx_avesfc, uflx_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_vflx_avesfc, vflx_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_shtfl_avesfc, shtfl_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_lhtfl_avesfc, lhtfl_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_prateb_avesfc, prateb_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_cpofpsfc, cpofpsfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_ugrd10m, ugrd10m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_vgrd10m, vgrd10m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_pressfc, pressfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_tmp_hyblev1sfc, tmp_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_spfh_hyblev1sfc, spfh_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_ugrd_hyblev1sfc, ugrd_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_vgrd_hyblev1sfc, vgrd_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_hgt_hyblev1sfc, hgt_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_icecsfc_in, icecsfc_in )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_landsfc, landsfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_tmp2m, tmp2m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_get_var_real(ncid , vi_spfh2m, spfh2m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
 
C------------------------------ 
      nerr = nf_close(ncid)
      if (nerr .ne. nf_noerr) call handle_err(nerr)
C------------------------------ 

      print *, "TIME= ", time_in
c     print *, "Longitude= ", longitude
      print *,"*** SUCCESS reading file ", FILE_NAME, "! "

      nerr = nf_create(FOUT_NAME, NF_CLOBBER, mcid)
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      time_out = time_in + 12.0

      print *, "TIME_OUT= ", time_out

C: set dim
      nerr = nf_def_dim(mcid, "lon", NX, vi_x_dim)
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_dim(mcid, "lat", NY, vi_y_dim)
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_dim(mcid, "time",NT,vi_t_dim)
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      outdim(3) = vi_t_dim
      outdim(2) = vi_y_dim
      outdim(1) = vi_x_dim
      outdimt = vi_t_dim
      outdimy = vi_y_dim
      outdimx = vi_x_dim

C: define variables

      nerr = nf_def_var(mcid , "lon" ,NF_REAL, 1, vi_x_dim, vi_lon )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "lat" ,NF_REAL, 1, vi_y_dim, vi_lat )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "time" ,NF_DOUBLE, 1, vi_t_dim, vi_time )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "DLWRF" ,NF_REAL, NDIM, outdim, vi_DLWRF )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "ULWRF" ,NF_REAL, NDIM, outdim, vi_ULWRF )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "DSWRF" ,NF_REAL, NDIM, outdim, vi_DSWRF )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "vbdsf_ave" ,NF_REAL, NDIM, outdim, vi_vbdsf_ave )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "vddsf_ave" ,NF_REAL, NDIM, outdim, vi_vddsf_ave )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "nbdsf_ave" ,NF_REAL, NDIM, outdim, vi_nbdsf_ave )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "nddsf_ave" ,NF_REAL, NDIM, outdim, vi_nddsf_ave )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "dusfc" ,NF_REAL, NDIM, outdim, vi_dusfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "dvsfc" ,NF_REAL, NDIM, outdim, vi_dvsfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "shtfl_ave" ,NF_REAL, NDIM, outdim, vi_shtfl_ave )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "lhtfl_ave" ,NF_REAL, NDIM, outdim, vi_lhtfl_ave )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "totprcp_ave" ,NF_REAL, NDIM, outdim, vi_totprcp_ave )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "u10m" ,NF_REAL, NDIM, outdim, vi_u10m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "v10m" ,NF_REAL, NDIM, outdim, vi_v10m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "hgt_hyblev1" ,NF_REAL, NDIM, outdim, vi_hgt_hyblev1 )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "psurf" ,NF_REAL, NDIM, outdim, vi_psurf )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "tmp_hyblev1" ,NF_REAL, NDIM, outdim, vi_tmp_hyblev1 )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "spfh_hyblev1" ,NF_REAL, NDIM, outdim, vi_spfh_hyblev1 )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "ugrd_hyblev1" ,NF_REAL, NDIM, outdim, vi_ugrd_hyblev1 )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "vgrd_hyblev1" ,NF_REAL, NDIM, outdim, vi_vgrd_hyblev1 )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "q2m" ,NF_REAL, NDIM, outdim, vi_q2m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "t2m" ,NF_REAL, NDIM, outdim, vi_t2m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "slmsksfc" ,NF_REAL, NDIM, outdim, vi_slmsksfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "pres_hyblev1" ,NF_REAL, NDIM, outdim, vi_pres_hyblev1 )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "precp" ,NF_REAL, NDIM, outdim, vi_precp )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "fprecp" ,NF_REAL, NDIM, outdim, vi_fprecp )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_def_var(mcid , "icecsfc" ,NF_REAL, NDIM, outdim, vi_icecsfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
  
C: put attribute
      vi_indx = vi_lon
      STR = "degrees_east"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_lon
      STR = "Longitude"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_lon
      nerr = nf_put_att_text(mcid, vi_indx, "modulo",1," ")
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_lat
      STR = "degrees_north"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_lat
      STR = "Latitude"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_time
C     STR = "seconds since 1970-01-01 00.00.00"
      STR = "hours since 1-1-1 00:00:00"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_time
      STR = "gregorian"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"calendar",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_time
      STR = "T"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"axis",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_DLWRF
      STR = "W/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_DLWRF
      STR = "surface downward longwave flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_ULWRF 
      STR = "W/m**2" 
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_ULWRF
      STR = "surface upward longwave flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_DSWRF
      STR = "W/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_DSWRF
      STR = "averaged surface downward shortwave flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_vbdsf_ave
      STR = "W/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_vbdsf_ave
      STR = "Visible Beam Downward Solar Flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_vddsf_ave
      STR = "W/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_vddsf_ave
      STR = "Visible Diffuse Downward Solar Flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_nbdsf_ave
      STR = "W/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_nbdsf_ave
      STR = "Near IR Beam Downward Solar Flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_nddsf_ave
      STR = "W/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_nddsf_ave
      STR = "Near IR Diffuse Downward Solar Flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_dusfc
      STR = "N/m**2" 
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_dusfc
      STR = "surface zonal momentum flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_dvsfc
      STR = "N/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_dvsfc
      STR = "surface meridional momentum flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_shtfl_ave
      STR = "w/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_shtfl_ave
      STR = "surface sensible heat flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_lhtfl_ave
      STR = "w/m**2"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_lhtfl_ave
      STR = "surface latent heat flux"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_totprcp_ave
      STR = "kg/m**2/s"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_totprcp_ave
      STR = "surface precipitationrate"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_u10m
      STR = "m/s"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_u10m
      STR = "10 meter u wind"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_v10m
      STR = "m/s"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_v10m
      STR = "10 meter v wind"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_hgt_hyblev1
      STR = "m"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_hgt_hyblev1 
      STR = "layer 1 height"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_psurf
      STR = "Pa"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_psurf
      STR = "surface pressure"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_tmp_hyblev1
      STR = "K"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_tmp_hyblev1 
      STR = "layer 1 temperature"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_spfh_hyblev1
      STR = "kg/kg"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_spfh_hyblev1
      STR = "layer 1 specific humidity"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_ugrd_hyblev1
      STR = "m/s"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_ugrd_hyblev1
      STR = "layer 1 zonal wind"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_vgrd_hyblev1
      STR = "m/s" 
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_vgrd_hyblev1
      STR = "layer 1 meridional wind"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_q2m
      STR = "kg/kg"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_q2m
      STR = "2m specific humidity"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_t2m
      STR = "K"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_t2m 
      STR = "2m temperature"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_slmsksfc
      STR = "numerical"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_slmsksfc
      STR = "sea-land-ice mask (0-sea, 1-land, 2-ice)"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_pres_hyblev1
      STR = "Pa"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_pres_hyblev1
      STR = "layer 1 pressure"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_precp
      STR = "kg/m**2/s"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_precp
      STR = "surface rain precipitation rate"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_fprecp
      STR = "kg/m**2/s"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_fprecp
      STR = "surface snow precipitation rate"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_icecsfc
      STR = "numerical"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"units",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      vi_indx = vi_icecsfc
      STR = "sea-ice coverage/fraction, proportion"
      NSTR = len_trim(STR)
      nerr = nf_put_att_text(mcid, vi_indx,"long_name",NSTR,trim(STR))
      if (nerr .ne. nf_noerr) call handle_err(nerr)

C----------------
      nerr = nf_enddef(mcid)
      if (nerr .ne. nf_noerr) call handle_err(nerr)   
C----------------

 
C: put vaiables

      nerr = nf_put_var_real(mcid , vi_lon, longitude )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_lat, latitude )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_double(mcid , vi_time, time_out )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_DLWRF, dlwrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_ULWRF, ulwrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_DSWRF, dswrf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_vbdsf_ave, vbdsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_vddsf_ave, vddsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_nbdsf_ave, nbdsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_nddsf_ave, nddsf_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_dusfc, uflx_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_dvsfc, vflx_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_shtfl_ave, shtfl_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_lhtfl_ave, lhtfl_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_totprcp_ave, prateb_avesfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_u10m, ugrd10m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_v10m, vgrd10m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_psurf, pressfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_tmp_hyblev1, tmp_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_spfh_hyblev1, spfh_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_ugrd_hyblev1, ugrd_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_vgrd_hyblev1, vgrd_hyblev1sfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_q2m, spfh2m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_t2m, tmp2m )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_slmsksfc, landsfc )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
C--------------------------------------------------
      coef = 1.0
      g0 = 9.80665
C--------- J/Kg/K
      Rsp = 287.058
      do k=1,NT
        do j=1,NY
          do i=1,NX
C           TCel = tmp2m(i,j,k)-273.15
C           if (TCel >= 0.0) then
C             coef = 1.0
C           else if (TCel < -15.0) then
C             coef = 0.0
C           else
C             coef = (TCel + 15.0)/15.0
C           endif
C           precp(i,j,k) = coef * prateb_avesfc(i,j,k)
C           fprecp(i,j,k) = (1.0 - coef) * prateb_avesfc(i,j,k)
C
C           cpofpsfc(i,j,k) is the ratio of ice precipitation/total precipitation
            coef = cpofpsfc(i,j,k)
            if (coef < 0.0) then
               coef = 0.0
            else if (coef > 1.0) then
               coef = 1.0
            endif
            fprecp(i,j,k) = coef * prateb_avesfc(i,j,k)
            precp(i,j,k) = (1.0 - coef) * prateb_avesfc(i,j,k)
C------------
            Hn = hgt_hyblev1sfc(i,j,k)
            hgt_hyblev1(i,j,k) = Hn
C------------
            term1 = -1.0*g0*Hn/(Rsp*tmp_hyblev1sfc(i,j,k))
            term2 = exp(term1)
            pres_hyblev1(i,j,k)=pressfc(i,j,k)*term2  
          enddo
        enddo
      enddo
C--------------------------------------------------
      nerr = nf_put_var_real(mcid , vi_hgt_hyblev1, hgt_hyblev1 )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_pres_hyblev1, pres_hyblev1)
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_precp, precp)
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_fprecp, fprecp)
      if (nerr .ne. nf_noerr) call handle_err(nerr)
      nerr = nf_put_var_real(mcid , vi_icecsfc, icecsfc_in )
      if (nerr .ne. nf_noerr) call handle_err(nerr)
C: close 
      nerr = nf_close(mcid)
      if (nerr .ne. nf_noerr) call handle_err(nerr)

      end

C=======================================================
      subroutine handle_err(errcode)
      implicit none
      include 'netcdf.inc'
      integer errcode

      print *, 'Error: ', nf_strerror(errcode)
      stop 2
      end


C=======================================================
      subroutine convolt(NX,NY,NT,invar,outvar,conmuti)
      implicit none
      integer I,J,K,NX,NY,NT
      real conmuti
      real  :: invar(NT,NY,NX), outvar(NX,NY,NT)
C: set output variables

      do k=1,NT
        do j=1,NY
          do i=1,NX
            outvar(i,j,k) = invar(k,j,i) * conmuti
          enddo
        enddo
      enddo
      return
      end


