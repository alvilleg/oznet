
declare FD_PROP 

local
   MODMAN = {New Module.manager init}
   %%   FD_PROP_O
   FD_PROP_1 = {MODMAN	link(url: 'tilt.so{native}' $)}
   FD_PROP_2 = {MODMAN	link(url: 'azim.so{native}' $)}
in
   %%FD_PROP = fd(init: FD_PROP_O.init add: FD_PROP_O.add)
   FD_PROP = fd(tilt: FD_PROP_1.tilt azim:FD_PROP_2.azim)
   fun{PruebaRes}
      proc{$ S}
	 GroupTilt
	 GroupAz
	 TiltAnt
	 AngleAnt
	 Antenna1
	 Antenna2
	 Antenna3
	 
	 AzimAntPpal
	 XRB
	 YRB
	 XPTO1
	 YPTO1
	 XPTO2
	 YPTO2
	 XPTO3
	 YPTO3
	 HRB
	 HAnt
	 DistRbPto
	 GroupAz
	 GroupTilt
	 TiltAnt
	 Salto 
	 GroupAz1
	 GroupAz2
	 GroupAz3
      in
	 XRB=100
	 YRB=100

	 XPTO1=150
	 YPTO1=100

	 XPTO2=50
	 YPTO2=100
	 
	 XPTO3=100
	 YPTO3=50
	 
	 Salto=5
	 HRB=50
	 HAnt=2
	 DistRbPto=250
	 	 
	 GroupTilt= {FD.int 0#19}

	 GroupAz1    = {FD.int 0#23}	 
	 GroupAz2    = {FD.int 0#23}
	 GroupAz3    = {FD.int 0#23}
	 
	 Antenna1  = {FD.int 1#3}
	 Antenna2  = {FD.int 1#3}
	 Antenna3  = {FD.int 1#3}

	 
	 AzimAntPpal= {FD.int {Loop.forThread 0 360 5 fun {$ Is I} I|Is end nil}  }
	 AzimAntPpal =: 0
	 %AzimAntPpal<:300
	 %TiltAnt = {FD.int 0#90}
	% TiltAnt =: 0
	 
	 S= azimuth#AzimAntPpal#tilt#TiltAnt#grupoTilt#GroupTilt#grupoAzimuth#GroupAz#antenna#Antenna1#a2#Antenna2#a3#Antenna3
	 
	 {FD_PROP.azim GroupAz1 Antenna1 AzimAntPpal XRB XPTO1 YRB YPTO1 Salto}
	 {FD_PROP.azim GroupAz2 Antenna2 AzimAntPpal XRB XPTO2 YRB YPTO2 Salto}
	 {FD_PROP.azim GroupAz3 Antenna3 AzimAntPpal XRB XPTO3 YRB YPTO3 Salto}
	 
	 %{FD_PROP.tilt TiltAnt GroupTilt HAnt HRB DistRbPto Salto}	 
	 {FD.distribute split [AzimAntPpal]}	 
	 %{Browser.browse grupo#GroupAz#ant#Antenna#angle#AngleAnt}
      end
   end
   {ExploreOne {PruebaRes}}
end