load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

rootdir="/data/waccm"
case="b40.1955-2005.2deg.wcm.avg"

;rootdir="/data/ccsm4"
;case="b40.1955-2005.2deg.wset.avg"

;season="DJF"
season="JJA"

dir1="h0zm.seasavg.1960-1979"
dir2="h0zm.seasavg.1986-2005"
infile=case+".cam2.h0zm."+season+".nc"

file1=addfile(rootdir+"/"+case+"/"+dir1+"/"+infile,"r")
file2=addfile(rootdir+"/"+case+"/"+dir2+"/"+infile,"r")

U1=file1->U
U2=file2->U
lev=U1&lev
lev@units="hPa"
lev@long_name="Pressure"
U1&lev=lev
U2&lev=lev
Udiff=U2 ; get metadata
Udiff=Udiff-U1
;Udiff!0=U1!0
;Udiff!1=U1!1

  res = True
  res@gsnDraw               = False
  res@gsnFrame              = False
  res@cnLinesOn             = False
  res@cnFillOn              = True                  ; turn on color fill
  res@gsnSpreadColors     = True ; spread out color table
  res@cnLevelSelectionMode  = "ManualLevels" 
; Contours by 10 up to 200:
  res@cnLevelSpacingF       = 1.0                  ; contour interval
  res@cnMinLevelValF        = -10.0                  ; contour interval
  res@cnMaxLevelValF        = 10.0                 ; contour interval
;  res@lbLabelAngleF         = 45
  res@lbLabelStride         = 2
  
  res@tmYLMode      = "Explicit" ; Define own tick mark labels.
;  res@tmYLLabelFont = 25         ; Change the font.
  res@tmYLValues    = (/1000,300,100,30,10,3,1,0.3,0.1, 0.01, 0.001, 0.0001/)
  res@tmYLLabels    = (/"1000","300","100","30","10","3","1","0.3","0.1", "0.01", "0.001", "0.0001"/)
  res@tmYLMinorOn   = True        ; No minor tick marks
  
  res2 = True
  res2@gsnDraw               = False
  res2@gsnFrame              = False
  res2@cnLinesOn             = True
  res2@cnFillOn              = False

  imagefile="$IMAGE_PATH/"+case+"_Ujet_"+season
  wks = gsn_open_wks("ps",imagefile)
  gsn_define_colormap(wks,"blwhre")                ; choose colormap
  
  minP = 0.1
  maxP = 1013.
  
  plot1 = gsn_csm_pres_hgt(wks, Udiff({minP:maxP}, {-90.0:90.0}), res)
  plot2 = gsn_csm_pres_hgt(wks, U1   ({minP:maxP}, {-90.0:90.0}), res2)
  overlay(plot1, plot2)
  draw(plot1)
  frame(wks)
  delete(wks)