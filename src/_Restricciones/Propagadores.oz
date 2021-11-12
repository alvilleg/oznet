functor
import
   Module
export
   azimProp:PropAzim
   tiltProp:PropTilt
define
   fun{PropAzim}
      local
	 FD_PROP_2
      in
	 FD_PROP_2 = {Module.link '../propagadores/azim.so{native}' $}
	 FD_PROP_2.azim
      end      
   end
   
   fun{PropTilt}
      local
	 FD_PROP_2
      in
	 FD_PROP_2 = {Module.link '../propagadores/tilt.so{native}' $}
	 FD_PROP_2.tilt
      end      
   end
end
