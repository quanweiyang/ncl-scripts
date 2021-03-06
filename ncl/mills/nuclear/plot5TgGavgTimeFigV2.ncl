; This script creates Figure 3 for 2013 paper "Multi-decadal global cooling 
; and unprecedented ozone loss following a regional nuclear conflict" by 
; Mills, Toon, Lee-Taylor, and Robock. 

; Figure 3 caption: The monthly global mean time evolution is shown for 
; (a) the mass burden of black carbon (Tg), (b) the shortwave net flux 
; anomaly at the surface (W m-2), (c) the surface temperature (K), and 
; (d) the precipitation anomaly (mm/day). The dark blue line and light 
; blue shading shows the ensemble average and range for this study. 
; The dark red line and pink shading shows the ensemble average and 
; range for Robock et al. [2007] (data courtesy L. Oman). The grey and 
; green lines show results from two 5 Tg BC simulations from Stenke et 
; al. [2013] (data courtesy A. Stenke), with assumed aerosol radii of 
; 50 nm and 100 nm, respectively. Ensemble anomalies are calculated with 
; respect to the mean of the respective control simulation ensembles. 
; Time 0 corresponds to the date of the BC injection (January 1 in this 
; study, May 15 in the other studies).

; Script written by Mike Mills
; Modified September 24, 2013

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

host   = systemfunc("hostname")
ostype = systemfunc("echo $OSTYPE")
MODEL_PATH=getenv("MODEL_PATH")
IMAGE_PATH=getenv("IMG_PATH")

if (ostype.eq."darwin") then
  path="$MODEL_PATH/cesm/runs/cesm1_0/"
  stenkepath="$DATA_PATH/stenke/monthly/"
else if (host.eq."modeling1") then
    path="/data4/mmills/"
    stenkepath=""
  else if (isStrSubset(host,"caldera").or.isStrSubset(host,"geyser").or.isStrSubset(host,"yslogin")) then
      path=MODEL_PATH+"/"
      stenkepath="/glade/p/cesm/wawg/mmills/stenke/monthly/"
    else
      path=MODEL_PATH+"/cesm/case/"  
      stenkepath=""
    end if
  end if
end if

;path="~/csm/"
print("path="+path)
print("stenkepath="+stenkepath)

root="b40.rcp4_5.2deg.wcm.carma."
sub="h0gm"

test1="bc5tgIP"
cntl1="bc0tg"

massfilepath=path+root+test1+".avg/proc/"

massfile=root+test1+".mass.avg.nc"
print("reading "+massfilepath+massfile)
mfileid = addfile(massfilepath+massfile, "r")
dmass = mfileid->SOOT01
delete(mfileid)
nTimes = dimsizes(dmass)
print("nTimes="+nTimes)

dmass_range = new((/2,nTimes/), typeof(dmass))

massfile=root+test1+".mass.max.nc"
print("reading "+massfilepath+massfile)
mfileid = addfile(massfilepath+massfile, "r")
dmass_range(0,0:nTimes-1) = mfileid->SOOT01(0:nTimes-1)
delete(mfileid)

massfile=root+test1+".mass.min.nc"
print("reading "+massfilepath+massfile)
mfileid = addfile(massfilepath+massfile, "r")
dmass_range(1,0:nTimes-1) = mfileid->SOOT01(0:nTimes-1)
delete(mfileid)

; New run with 30-minute time step
massfile="/glade/scratch/mmills/archive/b40.rcp4_5.2deg.wcm.carma.bc5tgIP.008"+ \
 "/proc/b40.rcp4_5.2deg.wcm.carma.bc5tgIP.008.mass.nc"
print("reading "+massfile)
mfileid = addfile(massfile, "r")
dmass2 = mfileid->SOOT01
nTimes2 = dimsizes(dmass2)
print("nTimes2="+nTimes2)
nTimes2=84
delete(mfileid)
      
avgfile=path+root+test1+".avg/"+sub+"/"+test1+"-"+cntl1+".cam.h0.avg.nc"
maxfile=path+root+test1+".avg/"+sub+"/"+test1+"-"+cntl1+".cam.h0.max.nc"
minfile=path+root+test1+".avg/"+sub+"/"+test1+"-"+cntl1+".cam.h0.min.nc"
print("adding avg file: "+avgfile)
avgfileh=addfile(avgfile,"r")
print("adding max file: "+maxfile)
maxfileh=addfile(maxfile,"r")
print("adding min file: "+minfile)
minfileh=addfile(minfile,"r")

avgfile2="/glade/scratch/mmills/archive/b40.rcp4_5.2deg.wcm.carma.bc5tgIP.008"+\
  "/atm/proc/h0gm/b40.rcp4_5.2deg.wcm.carma.bc5tgIP-bc0tg.cam.h0.avg.nc"
print("adding avg file2: "+avgfile2)
avgfileh2=addfile(avgfile2,"r")

massfile=stenkepath+"5Tg_100nm_soot_burden.nc"
print("reading "+massfile)
mfileid = addfile(massfile, "r")
; Stenke war starts on May 15
stenke_year=mfileid->time-120./365.  ; Set May 1 to day 1 match other parameters
nTimes_stenke=dimsizes(stenke_year)
stenke_mass=new((/2,nTimes_stenke/),"float")
stenke_mass(1,:)=mfileid->TotSoot
delete(mfileid)

massfile=stenkepath+"5Tg_200nm_soot_burden.nc"
print("reading "+massfile)
mfileid = addfile(massfile, "r")
stenke_mass(0,:)=mfileid->TotSoot
delete(mfileid)

gw   = avgfileh->gw
lat  = avgfileh->lat
time = avgfileh->time

time   = time/365.0
nLats  = dimsizes(lat)
nTimes = dimsizes(time)
print("nTimes="+nTimes)

; Net shortwave flux at the surface
FSNS_range = new((/9,nTimes/), float)
print("reading FSNS_max")
FSNS_range(2,0:nTimes-1) = maxfileh->FSNS(0:nTimes-1)
print("reading FSNS_min")
FSNS_range(3,0:nTimes-1) = minfileh->FSNS(0:nTimes-1)
print("reading FSNS_diff")
FSNS_range(7,0:nTimes-1) = avgfileh->FSNS(0:nTimes-1)
print("reading FSNS_diff2")
FSNS_range(8,0:nTimes2-1) = avgfileh2->FSNS(0:nTimes2-1)
stenkefileh=addfile(stenkepath+"5Tg_100nm_monthly_global_shortwave_radiation.nc","r")
stenkefilec=addfile(stenkepath+"CTRL_monthly_global_shortwave_radiation.nc","r")
delete(nTimes_stenke)
nTimes_stenke=dimsizes(stenkefileh->time)
print("nTimes_stenke="+nTimes_stenke)
FSNS_range(5,0:nTimes_stenke-1) = stenkefileh->srads(0:nTimes_stenke-1,0,0) - \
                                  stenkefilec->srads(0:nTimes_stenke-1,0,0)
delete(stenkefileh)
stenkefileh=addfile(stenkepath+"5Tg_200nm_monthly_global_shortwave_radiation.nc","r")
FSNS_range(4,0:nTimes_stenke-1) = stenkefileh->srads(0:nTimes_stenke-1,0,0) - \
                                  stenkefilec->srads(0:nTimes_stenke-1,0,0)
delete(stenkefileh)
delete(stenkefilec)

; Surface temperature
TS_range = new((/9,nTimes/), float)
print("reading TS_max")
TS_range(2,0:nTimes-1) = maxfileh->TS(0:nTimes-1)
print("reading TS_min")
TS_range(3,0:nTimes-1) = minfileh->TS(0:nTimes-1)
print("reading TS_diff")
TS_range(7,0:nTimes-1) = avgfileh->TS(0:nTimes-1)
print("reading TS_diff2")
TS_range(8,0:nTimes2-1) = avgfileh2->TS(0:nTimes2-1)
stenkefileh=addfile(stenkepath+"5Tg_100nm_monthly_global_surface_temperature.nc","r")
stenkefilec=addfile(stenkepath+"CTRL_monthly_global_surface_temperature.nc","r")
delete(nTimes_stenke)
nTimes_stenke=dimsizes(stenkefileh->time)
print("nTimes_stenke="+nTimes_stenke)
TS_range(5,0:nTimes_stenke-1) = stenkefileh->tsurf(0:nTimes_stenke-1,0,0) - \
                                  stenkefilec->tsurf(0:nTimes_stenke-1,0,0)
delete(stenkefileh)
stenkefileh=addfile(stenkepath+"5Tg_200nm_monthly_global_surface_temperature.nc","r")
TS_range(4,0:nTimes_stenke-1) = stenkefileh->tsurf(0:nTimes_stenke-1,0,0) - \
                                  stenkefilec->tsurf(0:nTimes_stenke-1,0,0)
delete(stenkefileh)
delete(stenkefilec)

; Total precipitation
PRECT_range = new((/9,nTimes/), float)
print("reading PRECT_max")
PRECT_range(2,0:nTimes-1) = maxfileh->PRECT(0:nTimes-1) * 24. * 3600. * 1000.; convert m/s to mm/day
print("reading PRECT_min")
PRECT_range(3,0:nTimes-1) = minfileh->PRECT(0:nTimes-1) * 24. * 3600. * 1000.; convert m/s to mm/day
print("reading PRECT_diff")
PRECT_range(7,0:nTimes-1) = avgfileh->PRECT(0:nTimes-1) * 24. * 3600. * 1000.; convert m/s to mm/day
print("reading PRECT_diff2")
PRECT_range(8,0:nTimes2-1) = avgfileh2->PRECT(0:nTimes2-1) * 24. * 3600. * 1000.; convert m/s to mm/day
stenkefileh=addfile(stenkepath+"5Tg_100nm_monthly_global_precipitation.nc","r")
stenkefilec=addfile(stenkepath+"CTRL_monthly_global_precipitation.nc","r")
delete(nTimes_stenke)
nTimes_stenke=dimsizes(stenkefileh->time)
print("nTimes_stenke="+nTimes_stenke)
apr=stenkefileh->aprl-stenkefilec->aprl
apr=apr+stenkefileh->aprc-stenkefilec->aprc
apr=apr*3600.*24.; convert kg/m2/s to mm/day
;print("100 nm:)
;print(apr(:,0,0))
PRECT_range(5,0:nTimes_stenke-1) = (/apr(:,0,0)/)
delete(stenkefileh)
stenkefileh=addfile(stenkepath+"5Tg_200nm_monthly_global_precipitation.nc","r")
apr=stenkefileh->aprl-stenkefilec->aprl
apr=apr+stenkefileh->aprc-stenkefilec->aprc
apr=apr*3600.*24.; convert kg/m2/s to mm/day
;print("100 nm:)
;print(apr(:,0,0))
PRECT_range(4,0:nTimes_stenke-1) = (/apr(:,0,0)/)

print("max PRECT 200:"+max(PRECT_range(4,0:nTimes_stenke-1)))
print("min PRECT 200:"+min(PRECT_range(4,0:nTimes_stenke-1)))
print("max PRECT 100:"+max(PRECT_range(5,0:nTimes_stenke-1)))
print("min PRECT 100:"+min(PRECT_range(5,0:nTimes_stenke-1)))

delete(stenkefileh)
delete(stenkefilec)

; convert m/s to mm/day
;PRECT_range = PRECT_range * 24. * 3600. * 1000.

; Global mass burden from Robock 5Tg study
robock = (/ (/0.353, 4.948/), (/0.409, 4.892/), (/0.465, 4.837/), (/0.539, 4.795/), (/0.613, 4.768/), \
            (/0.687, 4.754/), (/0.761, 4.740/), (/0.873, 4.698/), (/0.984, 4.657/), (/1.188, 4.587/), \
            (/1.410, 4.504/), (/1.707, 4.421/), (/2.115, 4.310/), (/2.486, 4.129/), (/2.764, 4.005/), \
            (/3.060, 3.880/), (/3.468, 3.616/), (/3.783, 3.422/), (/4.099, 3.283/), (/4.358, 3.075/), \
            (/4.803, 2.798/), (/5.063, 2.673/), (/5.359, 2.493/), (/5.749, 2.243/), (/6.027, 2.118/), \
            (/6.305, 1.938/), (/6.583, 1.771/), (/6.787, 1.660/), (/7.139, 1.535/), (/7.510, 1.341/), \
            (/7.862, 1.202/), (/8.103, 1.119/), (/8.363, 0.994/), (/8.789, 0.856/), (/9.067, 0.772/), \
            (/9.364, 0.689/), (/9.568, 0.634/), (/9.791, 0.578/), (/9.939, 0.550/), (/10.050, 0.537/) /)

;robock(:,0)=robock(:,0)-134./365. ; Robock starts May 15, vs Jan 1
robock(:,0)=robock(:,0)-120./365.  ; Set to May 1 to match other parameters

; (Time(y), TS change(K)) from Robock 5Tg study
; Array from Robock/Oman 2007 5Tg study of monthly average anomaly from control ensemble mean for 3 test runs
;   TSavg, TSmax, TSmin, PRECavg, PRECmax, PRECmin, SWFavg, SWFmax, SWFmin
Oman =(/ (/-0.543988,0.254766,-0.142107,-0.043993,0.021839,-0.013398,-6.918393,0.22944,-0.240563/), \
     (/-0.989681,0.172442,-0.08677,-0.154685,0.018563,-0.024915,-16.059452,0.028982,-0.046958/), \
     (/-1.127242,0.135241,-0.094554,-0.172171,0.020677,-0.029771,-14.629964,0.164833,-0.147062/), \
     (/-1.108988,0.035094,-0.058177,-0.234959,0.022806,-0.027936,-14.079357,0.373286,-0.315516/), \
     (/-1.103879,0.04285,-0.070849,-0.233686,0.016508,-0.019237,-13.775683,0.383747,-0.403491/), \
     (/-0.967355,0.053822,-0.237916,-0.21982,0.014719,-0.024768,-13.792356,0.108271,-0.169448/), \
     (/-0.970586,0.116826,-0.175355,-0.225187,0.011144,-0.011333,-13.776426,0.318291,-0.427421/), \
     (/-0.970377,0.113429,-0.123564,-0.255844,0.002507,-0.002881,-13.380506,0.276397,-0.387708/), \
     (/-0.925923,0.097117,-0.104499,-0.204275,0.012369,-0.016503,-12.943589,0.314097,-0.463603/), \
     (/-0.904207,0.121322,-0.21378,-0.215947,0.038238,-0.0223,-12.833835,0.371071,-0.419465/), \
     (/-1.143699,0.061314,-0.064881,-0.24136,0.012637,-0.010938,-13.134545,0.580928,-0.856258/), \
     (/-1.284063,0.046559,-0.023345,-0.227617,0.016377,-0.008636,-13.281872,0.584739,-0.9961/), \
     (/-1.319868,0.136394,-0.072597,-0.274289,0.01377,-0.01237,-12.925157,0.380793,-0.698635/), \
     (/-1.318998,0.103119,-0.121192,-0.2681,0.034652,-0.019409,-12.688376,0.302365,-0.582314/), \
     (/-1.361664,0.098061,-0.132108,-0.239175,0.030295,-0.016408,-12.593501,0.469501,-0.799135/), \
     (/-1.318472,0.026412,-0.025563,-0.255207,0.021213,-0.010863,-12.670967,0.571898,-0.951677/), \
     (/-1.2932,0.062217,-0.066026,-0.246384,0.015999,-0.02279,-12.689613,0.476025,-0.68023/), \
     (/-1.278399,0.073128,-0.041011,-0.24085,0.005208,-0.008608,-12.899745,0.466826,-0.732588/), \
     (/-1.233607,0.032478,-0.064104,-0.288842,0.009466,-0.010593,-12.948718,0.474632,-0.746377/), \
     (/-1.148168,0.088347,-0.145214,-0.278744,0.015429,-0.018298,-12.804638,0.347789,-0.526698/), \
     (/-1.09622,0.126072,-0.14257,-0.258272,0.019821,-0.013495,-12.608978,0.398494,-0.726723/), \
     (/-1.079978,0.143615,-0.086021,-0.248201,0.013762,-0.011617,-12.376957,0.505562,-0.904848/), \
     (/-1.223043,0.102415,-0.097378,-0.273975,0.00559,-0.009255,-12.230507,0.396779,-0.776585/), \
     (/-1.28803,0.075131,-0.111769,-0.268572,0.006925,-0.006653,-12.128177,0.534072,-0.951413/), \
     (/-1.261071,0.008332,-0.011811,-0.284566,0.015513,-0.026847,-11.701964,0.402812,-0.792786/), \
     (/-1.27035,0.067115,-0.086399,-0.291098,0.012072,-0.010229,-11.41023,0.409999,-0.763114/), \
     (/-1.26159,0.098642,-0.057021,-0.289182,0.007907,-0.015111,-11.448977,0.521228,-0.978029/), \
     (/-1.266134,0.110456,-0.072125,-0.277676,0.009538,-0.012861,-11.492804,0.359844,-0.70759/), \
     (/-1.310362,0.094376,-0.139821,-0.26424,0.015006,-0.007603,-11.677275,0.332888,-0.660645/), \
     (/-1.383367,0.053659,-0.106759,-0.249333,0.035335,-0.030335,-11.830307,0.355971,-0.631089/), \
     (/-1.437367,0.112658,-0.147953,-0.291053,0.017196,-0.029873,-11.836659,0.307415,-0.530272/), \
     (/-1.34204,0.150142,-0.122442,-0.303237,0.015439,-0.030116,-11.714654,0.304289,-0.581024/), \
     (/-1.117678,0.055399,-0.043207,-0.280375,0.006443,-0.010634,-11.637853,0.526439,-0.940969/), \
     (/-1.107465,0.084011,-0.052353,-0.263172,0.011231,-0.022038,-11.272078,0.426155,-0.781069/), \
     (/-1.229242,0.176111,-0.231571,-0.277971,0.002878,-0.005418,-11.003351,0.380958,-0.733047/), \
     (/-1.330848,0.122941,-0.220795,-0.272743,0.014704,-0.012268,-10.770151,0.490151,-0.912478/), \
     (/-1.289318,0.19161,-0.172618,-0.283504,0.011,-0.007239,-10.320748,0.522735,-1.011807/), \
     (/-1.16932,0.07874,-0.0686,-0.285769,0.007594,-0.006338,-10.060582,0.536889,-1.060428/), \
     (/-1.142818,0.076112,-0.138104,-0.292446,0.016615,-0.030393,-10.047524,0.55432,-1.00098/), \
     (/-1.110615,0.080322,-0.094776,-0.270688,0.008885,-0.006445,-10.15002,0.516278,-0.945745/), \
     (/-1.219843,0.142439,-0.158843,-0.250523,0.004284,-0.004473,-10.304677,0.451975,-0.842053/), \
     (/-1.277861,0.072252,-0.108762,-0.259954,0.022565,-0.017982,-10.424299,0.423483,-0.783844/), \
     (/-1.270287,0.143241,-0.183751,-0.26594,0.028702,-0.027105,-10.483229,0.534632,-0.991813/), \
     (/-1.198481,0.158666,-0.151775,-0.308147,0.019957,-0.028198,-10.366719,0.536112,-0.961353/), \
     (/-0.995963,0.241519,-0.296941,-0.265856,0.007704,-0.006911,-10.119186,0.622749,-1.106515/), \
     (/-0.975694,0.110002,-0.155418,-0.261115,0.007312,-0.004414,-9.73069,0.499657,-0.924904/), \
     (/-1.224256,0.112922,-0.154206,-0.265936,0.020049,-0.030048,-9.522309,0.527738,-0.987417/), \
     (/-1.189097,0.183908,-0.230972,-0.251856,0.002422,-0.002761,-9.199143,0.55085,-1.012085/), \
     (/-1.09132,0.159585,-0.145034,-0.256564,0.007491,-0.01137,-8.760459,0.489921,-0.916844/), \
     (/-0.977042,0.099528,-0.075814,-0.240939,0.003837,-0.005505,-8.518035,0.51282,-1.020944/), \
     (/-0.937411,0.110605,-0.128712,-0.233931,0.028092,-0.022364,-8.455838,0.480355,-0.954063/), \
     (/-0.897769,0.10964,-0.156725,-0.252734,0.002123,-0.003573,-8.592256,0.540326,-1.023231/), \
     (/-0.957033,0.056415,-0.1095,-0.215854,0.020356,-0.038666,-8.738852,0.52385,-0.986291002/), \
     (/-1.089812,0.047175,-0.069915,-0.225331,0.015941,-0.018697,-8.765736,0.504343,-0.941308/), \
     (/-1.255638,0.05389,-0.076088,-0.246077,0.004588,-0.003051,-8.753013,0.511808,-0.932562/), \
     (/-1.163507,0.080427,-0.105204,-0.249252,0.016834,-0.019357,-8.635093,0.531616,-0.931772/), \
     (/-1.056285,0.122947,-0.172394,-0.229735,0.027717,-0.021659,-8.308819,0.517154,-0.876274/), \
     (/-0.958655,0.04886,-0.054239,-0.210789,0.021694,-0.010937,-8.057881,0.564493,-1.05172098/), \
     (/-0.972372,0.05655,-0.050458,-0.217342,0.014524,-0.01143,-7.784416,0.485534,-0.898705/), \
     (/-1.058316,0.036789,-0.046666,-0.205865,0.025519,-0.025224,-7.507892,0.505623,-0.953003/), \
     (/-0.933297,0.108182,-0.171902,-0.225652,0.009157,-0.015772,-7.124063,0.449174,-0.898164/), \
     (/-0.881844,0.12076,-0.207197,-0.202529,0.019484,-0.01063,-6.847378,0.413701,-0.791339/), \
     (/-0.765062,0.124421,-0.137147,-0.207354,0.018723,-0.022793,-6.818264,0.399727,-0.789657/), \
     (/-0.746294,0.051961,-0.088803,-0.214317,0.010877,-0.010613,-6.907829,0.479367,-0.9443/), \
     (/-0.868588,0.106028,-0.148213,-0.197431,0.01614,-0.018022,-6.98955,0.460685,-0.89561/), \
     (/-1.007195,0.101279,-0.157139,-0.193994,0.003441,-0.006078,-7.019014,0.455573,-0.890124/), \
     (/-1.106412,0.076889,-0.101636,-0.21146,0.030789,-0.022447,-6.941778,0.373244,-0.743254/), \
     (/-0.978549,0.132806,-0.138603,-0.198021,0.007872,-0.014472,-6.904068,0.477007,-0.933814/), \
     (/-0.683678,0.146768,-0.190977,-0.184184,0.012523,-0.014564,-6.636591,0.496337,-0.957988/), \
     (/-0.758307,0.129607,-0.094321,-0.162222,0.021079,-0.021392,-6.368376,0.499072,-0.965639/), \
     (/-0.890944,0.141814,-0.171414,-0.156867,0.032865,-0.031142,-6.139165,0.467788,-0.846912/), \
     (/-0.950114,0.123081,-0.203977,-0.156627,0.013433,-0.01767,-5.917229,0.51731,-0.999234/), \
     (/-0.808697,0.098827,-0.161032,-0.177273,0.033386,-0.022051,-5.606612,0.505243,-0.975244/), \
     (/-0.674888,0.068523,-0.102666,-0.157705,0.035454,-0.02189,-5.422952,0.466303,-0.925178/), \
     (/-0.628563,0.095994,-0.071073,-0.166349,0.028207,-0.023238,-5.339671,0.461886,-0.860108/), \
     (/-0.627557,0.06346,-0.062699,-0.17689,0.005619,-0.005779,-5.390133,0.470746,-0.940291/), \
     (/-0.698537,0.114975,-0.149813,-0.137617,0.005385,-0.0077,-5.418512,0.433896,-0.861436/), \
     (/-0.809198,0.047173,-0.079165,-0.145421,0.001541,-0.00171,-5.427972,0.483946,-0.935916/), \
     (/-1.006936,0.035126,-0.022485,-0.159111,0.030331,-0.024167,-5.422744,0.493058,-0.958767/), \
     (/-0.990819,0.030859,-0.027118,-0.174825,0.00858,-0.012623,-5.371613,0.552591,-1.092961/), \
     (/-0.870846,0.110423,-0.108988,-0.129686,0.012358,-0.016665,-5.109903,0.480047,-0.956394/), \
     (/-0.833119,0.175903,-0.098783,-0.113346,0.01595,-0.018119,-4.877809,0.471713,-0.927432/), \
     (/-0.841846,0.097598,-0.061513,-0.121305,0.024983,-0.027918,-4.693472,0.461341,-0.901322/), \
     (/-0.798082,0.017649,-0.034122,-0.124643,0.021716,-0.033053,-4.445476,0.394494,-0.75353298/), \
     (/-0.646709,0.037194,-0.058197,-0.127824,0.014146,-0.011049,-4.226208,0.398502,-0.783836/), \
     (/-0.576587,0.048726,-0.072734,-0.115773,0.013055,-0.01679,-4.087667,0.383374,-0.765543/), \
     (/-0.497216,0.086253,-0.16553,-0.122961,0.003435,-0.00559,-4.042731,0.405527,-0.768721/), \
     (/-0.537579,0.0841,-0.073123,-0.125245,0.017573,-0.01441,-3.983839,0.350683,-0.680896/), \
     (/-0.572568,0.083954,-0.10863,-0.106143,0.009699,-0.005357,-3.986619,0.345527,-0.684718/), \
     (/-0.678091,0.055237,-0.061235,-0.099764,0.025364,-0.022233,-4.004303,0.3683,-0.719825/), \
     (/-0.774029,0.198564,-0.122568,-0.121696,0.008813,-0.01214,-3.936969,0.346468,-0.68556/), \
     (/-0.764574,0.180484,-0.162219,-0.120182,0.011795,-0.010798,-3.846294,0.344345,-0.684492/), \
     (/-0.587831,0.100132,-0.053359,-0.0754,0.036427,-0.02238,-3.68828,0.382982,-0.729107/), \
     (/-0.677684,0.006663,-0.007013,-0.09438,0.021714,-0.018689,-3.497822,0.316271,-0.626366/), \
     (/-0.820327,0.049643,-0.032919,-0.099666,0.008497,-0.008344,-3.362529,0.30217,-0.603702/), \
     (/-0.740963,0.021076,-0.028878,-0.073459,0.010327,-0.018688,-3.227238,0.326382,-0.6383/), \
     (/-0.620656,0.020566,-0.023213,-0.103446,0.015532,-0.018248,-3.05085,0.308972,-0.603193/), \
     (/-0.47196,0.107918,-0.119234,-0.09791,0.010921,-0.010481,-2.941883,0.286795,-0.56847/), \
     (/-0.418931,0.034946,-0.060733,-0.077081,0.025684,-0.02405,-2.88165,0.272495,-0.522855/), \
     (/-0.424943,0.073355,-0.100917,-0.089577,0.028612,-0.025656,-2.852954,0.283558,-0.545238/), \
     (/-0.508279,0.051874,-0.089014,-0.07359,0.027186,-0.018928,-2.841274,0.275744,-0.537929/), \
     (/-0.617162,0.060748,-0.061594,-0.071388,0.010372,-0.013847,-2.824814,0.293664,-0.577752/), \
     (/-0.692439,0.027669,-0.052605,-0.071866,0.004692,-0.004487,-2.80992,0.319772,-0.623087/), \
     (/-0.731604,0.112219,-0.06555,-0.096311,0.040999,-0.022798,-2.744521,0.324052,-0.63192/), \
     (/-0.60581,0.134686,-0.138094,-0.0447,0.005198,-0.005652,-2.59358,0.304302,-0.58039/), \
     (/-0.546998,0.127125,-0.161949,-0.071759,0.023854,-0.024507,-2.474766,0.30151,-0.563284/), \
     (/-0.669961,0.118409,-0.194545,-0.050431,0.003703,-0.006599,-2.344762,0.262097,-0.492774/), \
     (/-0.623455,0.084389,-0.153072,-0.05386,0.016023,-0.028441,-2.235016,0.253298,-0.471023998/), \
     (/-0.469813,0.120605,-0.073101,-0.074389,0.011116,-0.010933,-2.102658,0.205372,-0.395873/), \
     (/-0.345724,0.042582,-0.05477,-0.069178,0.004692,-0.006818,-2.041823,0.217787,-0.392465/), \
     (/-0.31774,0.072218,-0.037524,-0.064736,0.012142,-0.020497,-1.980605,0.196067,-0.358849/), \
     (/-0.279706,0.031861,-0.054845,-0.077974,0.015651,-0.01878,-1.95814,0.197156,-0.363372/), \
     (/-0.388097,0.060632,-0.108995,-0.074927,0.030227,-0.022044,-1.939778,0.207461,-0.388266/), \
     (/-0.465076,0.040151,-0.068295,-0.031249,0.009957,-0.01688,-1.929043,0.215213,-0.421016/), \
     (/-0.587725,0.096799,-0.126023,-0.069884,0.008671,-0.007498,-1.905781,0.24883,-0.468676/), \
     (/-0.562733,0.144662,-0.085024,-0.054587,0.016403,-0.01961,-1.847426,0.247986,-0.463407/), \
     (/-0.512878,0.171086,-0.105409,-0.031264,0.020064,-0.031244,-1.756368,0.227304,-0.448131/), \
     (/-0.531481,0.132299,-0.126206,-0.030323,0.016718,-0.017939,-1.66342,0.229344,-0.429214/), \
     (/-0.511821,0.111754,-0.14639,-0.03814,0.015754,-0.030886,-1.567494,0.194337,-0.356066/), \
     (/-0.532316,0.125181,-0.077855,-0.041082,0.045695,-0.049916,-1.490693,0.176347,-0.331354/), \
     (/-0.381294,0.116301,-0.140613,-0.030736,0.022915,-0.025988,-1.406556,0.177426,-0.322976/) /)
 
  Oman!0="time"
  Oman!1="var"
  
  printVarSummary(Oman)
  FSNS_range(0,0:120) = Oman(0:120,6)+Oman(0:120,7) ; max
  FSNS_range(1,0:120) = Oman(0:120,6)+Oman(0:120,8) ; min
  FSNS_range(6,0:120) = (/Oman(0:120,6)/)           ; avg

  TS_range(0,0:120) = Oman(0:120,0)+Oman(0:120,1) ; max
  TS_range(1,0:120) = Oman(0:120,0)+Oman(0:120,2) ; min
  TS_range(6,0:120) = (/Oman(0:120,0)/)           ; avg

  pdffile="Fig03_5TgGaveRobockStenkeFigV2."+test1+"-"+cntl1
  PRECT_range(0,0:120) = Oman(0:120,3)+Oman(0:120,4) ; max
  PRECT_range(1,0:120) = Oman(0:120,3)+Oman(0:120,5) ; min
  PRECT_range(6,0:120) = (/Oman(0:120,3)/)           ; avg
  
;  print("PRECT_range(4:7,0:36):")
;  print(PRECT_range(4,0:36)+" "+PRECT_range(5,0:36)+" "+PRECT_range(6,0:36)+" "+PRECT_range(7,0:36))

;  wks   = gsn_open_wks ("eps",IMAGE_PATH+"/nuclear/"+pdffile) ; open workstation
  wks   = gsn_open_wks ("pdf",IMAGE_PATH+"/nuclear/"+pdffile) ; open workstation

  nl = integertochar(10)  ; newline character

  ; Create a panel plot
  resP = True
  nPanel=3
  plot = new(nPanel, graphic)
  
  resP@txString = "Time (years)"
  resP@gsnAttachPlotsXAxis =True
  resP@gsnPaperOrientation = "landscape"
  resP@gsnMaximize         = True          ; expand plot size to maximum
  resP@tmYMajorGrid = True
 
  
  res                   = True                      ; plot mods desired
  res@tmYMajorGrid = True
  res@tmYMajorGridLineDashPattern = 2
  res@vpWidthF            = 1.3           ; change aspect ratio of plot
  res@vpHeightF           = 0.3
  res@gsnDraw = False
  res@gsnFrame     = False                        ; don't advance frame yet
  res@xyLineThicknessF = 5.0
;  res@vpWidthF=0.85

  res@xyLineColor       = "red"          ; change line color
  res@xyMonoLineColor   = True            ; same color for all lines

  res@tmXBMaxTicks     = 15
  res@tmXTMaxTicks     = 15
  res@tmXBMinorPerMajor= 1
  res@tmXTMinorPerMajor= 1
  res@tmXBAutoPrecision= False
  res@tmXBPrecision    = 2
  
  res@trXMinF = 0.0
  res@trXMaxF = max(time)
  res@trYMinF = 0.0
  res@trYMaxF = 5.0
  res@tiXAxisString = "Time (years since BC injection)"
;  res@tmXTLabelsOn = True
;  res@tmYRLabelsOn = True

  res@trYMinF = -0.01
;  res@trYMaxF = 5.0
  res@tmYLPrecision = 1
  res@tmYLAutoPrecision = False
  res@tiYAxisString = "Mass burden (Tg)"
  
  res2=res
  res2@xyLineThicknessF = 0.5
  res2@xyMonoDashPattern = True
  res2@xyLineColor       = "lightblue"
  res2@gsnXYFillColors = (/"lightblue"/)

  res3=res
  res3@xyLineThicknessF = 4.0
  res3@xyLineColor       = "midnightblue"

  res4=res
  res4@xyLineThicknessF   = 4.0
  res4@xyMonoLineColor    = False   ; different colors for different lines
  res4@xyMonoDashPattern  = True 
  res4@xyLineColors       = (/"green3","grey30"/)
  
  res5=res3
;  res5@xyDashPattern = 1
  res5@xyLineColor       = "orange"
  res5@xyLineThicknessF = 2.0
  
  baseplot = gsn_csm_xy (wks, dmass&time/365., dmass_range/1e9,res2) ; draw plot
  overlay(baseplot, gsn_csm_xy (wks, stenke_year, stenke_mass,res4)) ; draw  plot
  overlay(baseplot, gsn_csm_xy (wks, robock(:,0), robock(:,1), res)) ; draw  plot
  overlay(baseplot, gsn_csm_xy (wks, dmass&time/365., dmass/1e9,res3)) ; draw  plot
  overlay(baseplot, gsn_csm_xy (wks, dmass2&time/365., dmass2/1e9,res5)) ; draw  plot
  
  res2=res
  res2@tiYAxisString = "SW Flux (W m~S~-2~N~)"
  res2@trYMaxF = 2.0
  res2@trYMinF = -17.0
  res2@tmYLPrecision=2
  res2@tmYLMode = "Manual"
  res2@tmYLTickStartF = -20.0
  res2@tmYLTickSpacingF = 5.0
  res2@tmYLMinorPerMajor = 4
  
  res2@xyMonoLineThickness = False
  res2@xyLineThicknesses = (/0.5,0.5,0.5,0.5,3.0,3.0,3.0,3.0/)
  res2@xyMonoDashPattern = True
  res2@xyMonoLineColor   = False            ; different colors for different lines
  res2@xyLineColors       = (/"pink","pink","lightblue","lightblue","green3","grey30", \
                              "red","midnightblue","orange"/)
  delete(res2@gsnXYFillColors)
  res2@gsnXYFillColors = (/"pink","transparent","lightblue","transparent","transparent", \
                           "transparent","transparent","transparent"/)
  
  plot(0) = gsn_csm_xy (wks,time,FSNS_range,res2) ; draw plot
  
  res2@tiYAxisString = "Temperature (K)"
  res2@trYMaxF = 0.1
  res2@trYMinF = -1.9
  res2@tmYLMode = "Manual"
  res2@tmYLTickStartF = -2.0
  res2@tmYLTickSpacingF = 0.5

  plot(1) = gsn_csm_xy (wks,time,TS_range,res2) ; draw plot  
  
  res2@trYMaxF = 0.05
  res2@trYMinF = -0.32
  res2@tmYLPrecision = 1
  res2@tiYAxisString = "Precipitation (mm d~S~-1~N~)"
  res2@tmYLMode = "Automatic"

  plot(2) = gsn_csm_xy (wks,time,PRECT_range,res2) ; draw plot
  
  resP@tiYAxisFontHeightF=0.015
  newplot = gsn_attach_plots(baseplot,plot,res,resP)
  draw(baseplot)
  
  txres = True
  txres@txFontHeightF = 0.02
  txres@txFontColor="midnightblue"
  gsn_text_ndc(wks,"CESM1(WACCM)",0.75,0.897,txres)
  txres@txFontColor="red"
  gsn_text_ndc(wks,"GISS ModelE",0.75,0.861,txres)
  txres@txFontColor="grey30"
  gsn_text_ndc(wks,"SOCOL3, r=50 nm",0.75,0.822,txres)
  txres@txFontColor="green3"
  gsn_text_ndc(wks,"SOCOL3, r=100 nm",0.75,0.783,txres)
    
  delete(wks)
  
  if (host.eq."modeling1") then
    muttcmd="mutt mikejmills@mac.com -a "+IMAGE_PATH+"/"+pdffile+".pdf -s "+pdffile+" < /dev/null"
    print(muttcmd)
    mutter=systemfunc(muttcmd)
    print(mutter)
  end if

  if (ostype.eq."darwin") then
    opencmd="open "+IMAGE_PATH+"/"+pdffile+".pdf"
    print(opencmd)
    open=systemfunc(opencmd)
    print(open)
  end if
  
;  print(PRECT_diff+" "+PRECT_range(0,:)+" "+PRECT_range(1,:))
