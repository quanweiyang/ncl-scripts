; Program checks solar lean netCDF file that integral of spectrum
; equals TSI, and that TSI is same as for file
; spectral_irradiance_Lean_1950-2140_daily_c100803.nc

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
datapath="$MODEL_PATH/ccsm/inputdata/atm/waccm/solar/"
imagepath="$IMAGE_PATH/solar/"

ncf = addfile(datapath+"spectral_irradiance_Lean_1950-2140_daily_c100804.nc","r")

;print("reading ncf->ssi")
;ssi=ncf->ssi
print("reading ncf->tsi")
tsi=ncf->tsi
print("dimsizes(tsi)="+dimsizes(tsi))
print("reading ncf->band_width")
band_width=ncf->band_width
print("reading ncf->time")
time=ncf->time
print("reading ncf->date")
date=ncf->date

;print("calculating tsi_sum")
;tsi_sum = ssi # band_width
;print("converting mW to W")
;tsi_sum = tsi_sum/1000.d0 ; Convert mW to W
;tsi_sum!0="time"
;tsi_sum&time=time
;print("calculating tsi_diff")
;tsi_diff=tsi-tsi_sum

;print("calculating tsi_sum2")
;tsi_sum2 = ssi(:,1:) # band_width(1:)
;print("converting mW to W")
;tsi_sum2 = tsi_sum2/1000.d0 ; Convert mW to W
;tsi_sum2!0="time"
;tsi_sum2&time=time
;print("calculating tsi_diff3")
;tsi_diff3=tsi-tsi_sum2

ncf2 = addfile(datapath+"spectral_irradiance_Lean_1950-2009_daily_c100507.nc","r")
print("reading ncf2->tsi")
tsi2= ncf2->tsi
print("dimsizes(tsi2)="+dimsizes(tsi2))

print("calculating tsi_diff2")
tsi_diff2=tsi(0:dimsizes(tsi2)-1)-tsi2


print("calculating year")
year=time/365.d0

;wks = gsn_open_wks("pdf", imagepath+"tsi_diff_1950-2140")

;  res                   = True                      ; plot mods desired
;  res@gsnDraw           = False
;  res@gsnFrame          = False
;  res@vpHeightF             = 0.5              ; change aspect ratio
;  res@vpWidthF              = 1.0

;  res@trXMinF = 1950.d0
;  res@trXMaxF = 2141.d0
;  res@tmXBLabelFontHeightF  = 0.02
;;  res@tiXAxisString="Time (years)"
;  res@tiYAxisString="TSI - SSI sum (W/m~S~2~N~)"
  
;  plot = new(2, graphic)
;  data=new((/2,dimsizes(tsi)/),double)
;  data(0,:)=tsi_diff
;  data(1,:)=tsi_diff3
;  plot(0) = gsn_xy(wks, year, tsi_diff, res)
  
;  res@tiYAxisString="TSI new - TSI old (W/m~S~2~N~)"
;  plot(1) = gsn_xy(wks, year, tsi_diff2, res)

;  resP                      = True
;  resP@gsnMaximize          = True
;;  resP@gsnPanelLabelBar     = True
;;  resP@lbTitleOn            =  True                ; turn on title
;;  resP@lbTitlePosition      = "Right"              ; title position
;;  resP@lbTitleFontHeightF   = .015                ; make title smaller
;;  resP@lbTitleDirection     = "Across"             ; title direction
;  resP@gsnPanelXWhiteSpacePercent = 5
;  gsn_panel(wks, plot, (/ 2, 1 /), resP)
  
;delete(wks)
;delete(res)
  
wks = gsn_open_wks("pdf", imagepath+"tsi_vs_ssi_1950-2140")
  res                   = True                      ; plot mods desired
;  res@gsnDraw           = False
;  res@gsnFrame          = False
;  res@vpHeightF             = 0.5              ; change aspect ratio
;  res@vpWidthF              = 1.0
  res@trXMinF = 1950.d0
;  res@trXMaxF = 2010.d0
  res@trXMaxF = 2141.d0


;  res@trXMinF = 1830.d0
;  res@trXMaxF = 1870.d0
;  res@trYMinF = 1360.4
;  res@trYMaxF = 1361.6
  res@tmXBLabelFontHeightF  = 0.015
  res@gsnMaximize          = True
  res@gsnPaperOrientation = "landscape"
  res@tmXBMinorPerMajor = 10

;  res@tmYBLabelFontHeightF  = 0.01
  res@tiYAxisFontThicknessF = 0.1
;  res@tiXAxisString="Time (years)"
  res@tiYAxisString="TSI (W/m~S~2~N~)"
  res@xyLineColors      = (/"blue","red","green"/)
  res@xyDashPatterns      = (/0,0,1/)
  
;  delete(data)
  data=new((/2,dimsizes(tsi)/),double)
  data(0,:)=tsi
  data(1,0:dimsizes(tsi2)-1)=tsi2
;;  data(2,:)=tsi_sum2
  plot1 = gsn_xy(wks, year, data, res)
;  plot1 = gsn_xy(wks, year, tsi, res)
delete(wks)
delete(res)
  