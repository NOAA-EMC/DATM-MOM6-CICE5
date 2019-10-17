   pro conv_cfsr2datm
   
   loadct,6   ; prism
   
;-------------------------------   
;  outdir ='/gpfs/dell2/emc/modeling/noscrub/Hyun-Chul.Lee/CFSR/Tmp'
   outname = 'csfr_output'
;-------------------------------   
    imp=1152  & jmp=576  & lmp=1
    im=imp-1 & jm=jmp-1 & lm=lmp-1
;--
;--
;   varcm  =fltarr(imp,jmp,12)
;   varcmt =fltarr(imp,jmp,1,lmp)

     lon = fltarr(imp)
     lat = fltarr(jmp)
     time = fltarr(lmp)
     DLWRF = fltarr(imp,jmp,lmp)
     ULWRF = fltarr(imp,jmp,lmp)
     DSWRF = fltarr(imp,jmp,lmp)
     vbdsf_ave = fltarr(imp,jmp,lmp)
     vddsf_ave = fltarr(imp,jmp,lmp)
     nbdsf_ave = fltarr(imp,jmp,lmp)
     nddsf_ave = fltarr(imp,jmp,lmp)
     dusfc = fltarr(imp,jmp,lmp)
     dvsfc = fltarr(imp,jmp,lmp)
     shtfl_ave = fltarr(imp,jmp,lmp)
     lhtfl_ave = fltarr(imp,jmp,lmp)
     totprcp_ave = fltarr(imp,jmp,lmp)
     u10m = fltarr(imp,jmp,lmp)
     v10m = fltarr(imp,jmp,lmp)
     hgt_hyblev1 = fltarr(imp,jmp,lmp)
     psurf = fltarr(imp,jmp,lmp)
     tmp_hyblev1 = fltarr(imp,jmp,lmp)
     spfh_hyblev1 = fltarr(imp,jmp,lmp)
     ugrd_hyblev1 = fltarr(imp,jmp,lmp)
     vgrd_hyblev1 = fltarr(imp,jmp,lmp)
     q2m = fltarr(imp,jmp,lmp)
     t2m = fltarr(imp,jmp,lmp)
     slmsksfc = fltarr(imp,jmp,lmp)
     pres_hyblev1 = fltarr(imp,jmp,lmp)
     precp = fltarr(imp,jmp,lmp)
     fprecp = fltarr(imp,jmp,lmp)
     icecsfc = fltarr(imp,jmp,lmp)
;--
@csfr_input.idl
;--
     lon(*) = longitude(*)
     lat(*) = latitude(*)
;    time(*) = time(*)
     DLWRF(*,*,0) = DLWRF_surface(*,*)
     ULWRF(*,*,0) = ULWRF_surface(*,*)
     DSWRF(*,*,0) = DSWRF_surface(*,*)
     vbdsf_ave(*,*,0) = DSWRF_surface(*,*)*0.285
     vddsf_ave(*,*,0) = DSWRF_surface(*,*)*0.285
     nbdsf_ave(*,*,0) = DSWRF_surface(*,*)*0.215
     nddsf_ave(*,*,0) = DSWRF_surface(*,*)*0.215
     dusfc(*,*,0) = UFLX_surface(*,*)
     dvsfc(*,*,0) = VFLX_surface(*,*)
     shtfl_ave(*,*,0) = SHTFL_surface(*,*)
     lhtfl_ave(*,*,0) = LHTFL_surface(*,*)
     totprcp_ave(*,*,0) = PRATE_surface(*,*)
     u10m(*,*,0) = UGRD_10maboveground(*,*)
     v10m(*,*,0) = VGRD_10maboveground(*,*)
     hgt_hyblev1(*,*,0) = HGT_1hybridlevel(*,*)
     psurf(*,*,0) = PRES_surface(*,*)
     tmp_hyblev1(*,*,0) = TMP_1hybridlevel(*,*)
     spfh_hyblev1(*,*,0) = SPFH_1hybridlevel(*,*)
     ugrd_hyblev1(*,*,0) = UGRD_1hybridlevel(*,*)
     vgrd_hyblev1(*,*,0) = VGRD_1hybridlevel(*,*)
     q2m(*,*,0) = SPFH_2maboveground(*,*)
     t2m(*,*,0) = TMP_2maboveground(*,*)
     slmsksfc(*,*,0) = LAND_surface(*,*)
     icecsfc(*,*,0) = ICEC_surface(*,*)

;    pres_hyblev1(*,*,*) = (*,*,*)
;--
     print, "TIME: ", time/3600.0
;--
    coef = 1.0
    ll = 0
    g0 = 9.80665    ; m/s^2
    Rsp = 287.058   ; J/Kg/K
    for j = 0, jm do begin
       for i = 0, im do begin
;--
          TCel = TMP_surface(i,j)-273.15
          if (TCel ge 0.0) then begin
             coef = 1.0
          endif else if (TCel lt -15.0) then begin
             coef = 0.0
          endif else begin
             coef = (TCel + 15.0)/15.0
          endelse
             precp(i,j,ll) = coef * PRATE_surface(i,j)
             fprecp(i,j,ll) = (1.0 - coef) * PRATE_surface(i,j)
;--
          if (abs(HGT_1HYBRIDLEVEL(i,j)) lt 1.0e3 and LAND_surface(i,j) eq 1) then begin
             Hn = HGT_1HYBRIDLEVEL(i,j)
          endif else begin
             Hn = 20.0
          endelse
          hgt_hyblev1(i,j,ll) = Hn
;--         
          term1 = -1.0*g0*Hn/(Rsp*TMP_1HYBRIDLEVEL(i,j))
          term2 = exp(term1)
          pres_hyblev1(i,j,ll)=PRES_SURFACE(i,j)*term2
          if (pres_hyblev1(i,j,ll) eq 0.0) then begin
             print, PRES_SURFACE(i,j),term1,term2,TMP_1HYBRIDLEVEL(i,j),Hn
          endif
;--
       endfor
    endfor
;--
;)==============================
;-- creat netcdf file

   cdfid = ncdf_create(outname+'.nc', /clobber)

;--
   lmp=1
   xid = ncdf_dimdef(cdfid, 'lon', imp)
   yid = ncdf_dimdef(cdfid, 'lat', jmp)
   lid = ncdf_dimdef(cdfid, 'time', /UNLIMITED)
;--
   vi_lon = ncdf_vardef(cdfid, "lon", [xid], /float)
   vi_lat = ncdf_vardef(cdfid, "lat", [yid], /float)
   vi_time = ncdf_vardef(cdfid, "time", [lid], /double)
   vi_DLWRF = ncdf_vardef(cdfid, "DLWRF", [xid,yid,lid], /float)
   vi_ULWRF = ncdf_vardef(cdfid, "ULWRF", [xid,yid,lid], /float)
   vi_DSWRF = ncdf_vardef(cdfid, "DSWRF", [xid,yid,lid], /float)
   vi_vbdsf_ave = ncdf_vardef(cdfid, "vbdsf_ave", [xid,yid,lid], /float)
   vi_vddsf_ave = ncdf_vardef(cdfid, "vddsf_ave", [xid,yid,lid], /float)
   vi_nbdsf_ave = ncdf_vardef(cdfid, "nbdsf_ave", [xid,yid,lid], /float)
   vi_nddsf_ave = ncdf_vardef(cdfid, "nddsf_ave", [xid,yid,lid], /float)
   vi_dusfc = ncdf_vardef(cdfid, "dusfc", [xid,yid,lid], /float)
   vi_dvsfc = ncdf_vardef(cdfid, "dvsfc", [xid,yid,lid], /float)
   vi_shtfl_ave = ncdf_vardef(cdfid, "shtfl_ave", [xid,yid,lid], /float)
   vi_lhtfl_ave = ncdf_vardef(cdfid, "lhtfl_ave", [xid,yid,lid], /float)
   vi_totprcp_ave = ncdf_vardef(cdfid, "totprcp_ave", [xid,yid,lid], /float)
   vi_u10m = ncdf_vardef(cdfid, "u10m", [xid,yid,lid], /float)
   vi_v10m = ncdf_vardef(cdfid, "v10m", [xid,yid,lid], /float)
   vi_hgt_hyblev1 = ncdf_vardef(cdfid, "hgt_hyblev1", [xid,yid,lid], /float)
   vi_psurf = ncdf_vardef(cdfid, "psurf", [xid,yid,lid], /float)
   vi_tmp_hyblev1 = ncdf_vardef(cdfid, "tmp_hyblev1", [xid,yid,lid], /float)
   vi_spfh_hyblev1 = ncdf_vardef(cdfid, "spfh_hyblev1", [xid,yid,lid], /float)
   vi_ugrd_hyblev1 = ncdf_vardef(cdfid, "ugrd_hyblev1", [xid,yid,lid], /float)
   vi_vgrd_hyblev1 = ncdf_vardef(cdfid, "vgrd_hyblev1", [xid,yid,lid], /float)
   vi_q2m = ncdf_vardef(cdfid, "q2m", [xid,yid,lid], /float)
   vi_t2m = ncdf_vardef(cdfid, "t2m", [xid,yid,lid], /float)
   vi_slmsksfc = ncdf_vardef(cdfid, "slmsksfc", [xid,yid,lid], /float)
   vi_pres_hyblev1 = ncdf_vardef(cdfid, "pres_hyblev1", [xid,yid,lid], /float)
   vi_precp = ncdf_vardef(cdfid, "precp", [xid,yid,lid], /float)
   vi_fprecp = ncdf_vardef(cdfid, "fprecp", [xid,yid,lid], /float)
   vi_icecsfc = ncdf_vardef(cdfid, "icecsfc", [xid,yid,lid], /float)
  
;--
    ncdf_attput, cdfid, vi_lon, "units",  "degrees_east"
    ncdf_attput, cdfid, vi_lon, "long_name",  "Longitude"
    ncdf_attput, cdfid, vi_lon, "modulo",  " "
 
    ncdf_attput, cdfid, vi_lat, "units",  "degrees_north"
    ncdf_attput, cdfid, vi_lat, "long_name",  "Latitude"
 
    ncdf_attput, cdfid, vi_time, "units",  "hours since 1970-01-01 00.00.00"
    ncdf_attput, cdfid, vi_time, "calendar",  "gregorian"
    ncdf_attput, cdfid, vi_time, "axis",  "T"
 
    ncdf_attput, cdfid, vi_DLWRF, "units",  "W/m**2"
    ncdf_attput, cdfid, vi_DLWRF, "long_name",  "surface downward longwave flux"
 
    ncdf_attput, cdfid, vi_ULWRF, "units",  "W/m**2"
    ncdf_attput, cdfid, vi_ULWRF, "long_name",  "surface upward longwave flux"
 
    ncdf_attput, cdfid, vi_DSWRF, "units",  "W/m**2"
    ncdf_attput, cdfid, vi_DSWRF, "long_name",  "averaged surface downward shortwave flux"
 
    ncdf_attput, cdfid, vi_vbdsf_ave, "units",  "W/m**2"
    ncdf_attput, cdfid, vi_vbdsf_ave, "long_name",  "Visible Beam Downward Solar Flux"
 
    ncdf_attput, cdfid, vi_vddsf_ave, "units",  "W/m**2"
    ncdf_attput, cdfid, vi_vddsf_ave, "long_name",  "Visible Diffuse Downward Solar Flux"
 
    ncdf_attput, cdfid, vi_nbdsf_ave, "units",  "W/m**2"
    ncdf_attput, cdfid, vi_nbdsf_ave, "long_name",  "Near IR Beam Downward Solar Flux"
 
    ncdf_attput, cdfid, vi_nddsf_ave, "units",  "W/m**2"
    ncdf_attput, cdfid, vi_nddsf_ave, "long_name",  "Near IR Diffuse Downward Solar Flux"
 
    ncdf_attput, cdfid, vi_dusfc, "units",  "N/m**2"
    ncdf_attput, cdfid, vi_dusfc, "long_name",  "surface zonal momentum flux"
 
    ncdf_attput, cdfid, vi_dvsfc, "units",  "N/m**2"
    ncdf_attput, cdfid, vi_dvsfc, "long_name",  "surface meridional momentum flux"
 
    ncdf_attput, cdfid, vi_shtfl_ave, "units",  "w/m**2"
    ncdf_attput, cdfid, vi_shtfl_ave, "long_name",  "surface sensible heat flux"
 
    ncdf_attput, cdfid, vi_lhtfl_ave, "units",  "w/m**2"
    ncdf_attput, cdfid, vi_lhtfl_ave, "long_name",  "surface latent heat flux"
 
    ncdf_attput, cdfid, vi_totprcp_ave, "units",  "kg/m**2/s"
    ncdf_attput, cdfid, vi_totprcp_ave, "long_name",  "surface precipitation rate"
 
    ncdf_attput, cdfid, vi_u10m, "units",  "m/s"
    ncdf_attput, cdfid, vi_u10m, "long_name",  "10 meter u wind"
 
    ncdf_attput, cdfid, vi_v10m, "units",  "m/s"
    ncdf_attput, cdfid, vi_v10m, "long_name",  "10 meter v wind"
 
    ncdf_attput, cdfid, vi_hgt_hyblev1, "units",  "m"
    ncdf_attput, cdfid, vi_hgt_hyblev1, "long_name",  "layer 1 height"
 
    ncdf_attput, cdfid, vi_psurf, "units",  "Pa"
    ncdf_attput, cdfid, vi_psurf, "long_name",  "surface pressure"
 
    ncdf_attput, cdfid, vi_tmp_hyblev1, "units",  "K"
    ncdf_attput, cdfid, vi_tmp_hyblev1, "long_name",  "layer 1 temperature"
 
    ncdf_attput, cdfid, vi_spfh_hyblev1, "units",  "kg/kg"
    ncdf_attput, cdfid, vi_spfh_hyblev1, "long_name",  "layer 1 specific humidity"
 
    ncdf_attput, cdfid, vi_ugrd_hyblev1, "units",  "m/s"
    ncdf_attput, cdfid, vi_ugrd_hyblev1, "long_name",  "layer 1 zonal wind"
 
    ncdf_attput, cdfid, vi_vgrd_hyblev1, "units",  "m/s"
    ncdf_attput, cdfid, vi_vgrd_hyblev1, "long_name",  "layer 1 meridional wind"
 
    ncdf_attput, cdfid, vi_q2m, "units",  "kg/kg"
    ncdf_attput, cdfid, vi_q2m, "long_name",  "2m specific humidity"
 
    ncdf_attput, cdfid, vi_t2m, "units",  "K"
    ncdf_attput, cdfid, vi_t2m, "long_name",  "2m temperature"
 
    ncdf_attput, cdfid, vi_slmsksfc, "units",  "numerical"
    ncdf_attput, cdfid, vi_slmsksfc, "long_name",  "sea-land-ice mask (0-sea, 1-land, 2-ice)"
 
    ncdf_attput, cdfid, vi_pres_hyblev1, "units",  "Pa"
    ncdf_attput, cdfid, vi_pres_hyblev1, "long_name",  "layer 1 pressure"
 
    ncdf_attput, cdfid, vi_precp, "units",  "kg/m**2/s"
    ncdf_attput, cdfid, vi_precp, "long_name",  "surface rain precipitation rate"
 
    ncdf_attput, cdfid, vi_fprecp, "units",  "kg/m**2/s"
    ncdf_attput, cdfid, vi_fprecp, "long_name",  "surface snow precipitation rate"
 
    ncdf_attput, cdfid, vi_icecsfc, "units",  "numerical"
    ncdf_attput, cdfid, vi_icecsfc, "long_name",  "sea-ice coverage/fraction, proportion"
 
;--
    ncdf_control, cdfid, /endef
;--

    ncdf_varput, cdfid, vi_lon, lon
    ncdf_varput, cdfid, vi_lat, lat
    ncdf_varput, cdfid, vi_time, time/3600.
    ncdf_varput, cdfid, vi_DLWRF, DLWRF
    ncdf_varput, cdfid, vi_ULWRF, ULWRF
    ncdf_varput, cdfid, vi_DSWRF, DSWRF
    ncdf_varput, cdfid, vi_vbdsf_ave, vbdsf_ave
    ncdf_varput, cdfid, vi_vddsf_ave, vddsf_ave
    ncdf_varput, cdfid, vi_nbdsf_ave, nbdsf_ave
    ncdf_varput, cdfid, vi_nddsf_ave, nddsf_ave
    ncdf_varput, cdfid, vi_dusfc, dusfc
    ncdf_varput, cdfid, vi_dvsfc, dvsfc
    ncdf_varput, cdfid, vi_shtfl_ave, shtfl_ave
    ncdf_varput, cdfid, vi_lhtfl_ave, lhtfl_ave
    ncdf_varput, cdfid, vi_totprcp_ave, totprcp_ave
    ncdf_varput, cdfid, vi_u10m, u10m
    ncdf_varput, cdfid, vi_v10m, v10m
    ncdf_varput, cdfid, vi_hgt_hyblev1, hgt_hyblev1
    ncdf_varput, cdfid, vi_psurf, psurf
    ncdf_varput, cdfid, vi_tmp_hyblev1, tmp_hyblev1
    ncdf_varput, cdfid, vi_spfh_hyblev1, spfh_hyblev1
    ncdf_varput, cdfid, vi_ugrd_hyblev1, ugrd_hyblev1
    ncdf_varput, cdfid, vi_vgrd_hyblev1, vgrd_hyblev1
    ncdf_varput, cdfid, vi_q2m, q2m
    ncdf_varput, cdfid, vi_t2m, t2m
    ncdf_varput, cdfid, vi_slmsksfc, slmsksfc
    ncdf_varput, cdfid, vi_pres_hyblev1, pres_hyblev1
    ncdf_varput, cdfid, vi_precp, precp
    ncdf_varput, cdfid, vi_fprecp, fprecp
    ncdf_varput, cdfid, vi_icecsfc, icecsfc
   
   ncdf_close, cdfid
;)==============================


stop
end


