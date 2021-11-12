
declare FD_PROP 

local
   MODMAN = {New Module.manager init}
%   FD_PROP_O
   FD_PROP_1 = {MODMAN	link(url: 'tilt.so{native}' $)}
   FD_PROP_2 = {MODMAN	link(url: 'azim.so{native}' $)}
  % FD_PROP_3 = {MODMAN	link(url: 'activeSetProp.so{native}' $)}
in
%   FD_PROP = fd(init: FD_PROP_O.init add: FD_PROP_O.add)
   FD_PROP = fd(tilt: FD_PROP_1.tilt azim:FD_PROP_2.azim )%activeSet:FD_PROP_3.activeSet)
%   FD_PROP = fd(activeSet:FD_PROP_3.activeSet)
   fun{PruebaRes}
      proc{$ S}
	 RBCobPto
	 Obj
	 Min = 2
	 Max = 3
	 NumPtos = 15
	 S1
	 Delta
	 TiltAnt
	 GroupTilt
	 Salto=5
      in
	 TiltAnt={FD.tuple 't' 5 0#90}
	 GroupTilt={FD.tuple 't' 5 1#19}
	%  if {Bool.'and' (({Int.'div' 100 NumPtos}) > 1) (({Int.'mod' 100 NumPtos}) == 0)} then
% 	    Delta = {Int.'div' 100 NumPtos}
% 	    Obj = {FD.int {Loop.forThread 0 100 Delta fun {$ Is I} I|Is end nil }}
% 	 else
% 	    Obj = {FD.int 0#100}
% 	 end
	 	 
% 	 RBCobPto = {FD.tuple cob NumPtos 0#4}
% 	 %Obj>:20
% 	 %Obj<:40

% 	 for I in 1..NumPtos do
% 	    RBCobPto.I=:{Int.'mod' I 5}
% 	 end

	 %% S= r(rb:RBCobPto obj:Obj)
	 S=r(ta:TiltAnt  gt:GroupTilt)
	% {FD_PROP.activeSet RBCobPto Obj Min Max NumPtos}	 
	 %S= r(obj:Obj)
	 
	 %{FD_PROP.azim GroupAz Antenna AzimAntPpal XRB XPTO YRB YPTO Salto}
	 for I in 1..5 do
	    {FD_PROP.tilt TiltAnt.I GroupTilt.I 2 50 100 Salto}
	 end
	% {FD.distribute ff TiltAnt}	
	
	 %{Browser.browse grupo#GroupAz#ant#Antenna#angle#AngleAnt}
      end
   end
   {ExploreOne {PruebaRes}}% proc{$ O N } N.obj >: O.obj end }
end