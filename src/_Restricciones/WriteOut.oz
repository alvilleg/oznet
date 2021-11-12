functor
import
   Open
   System
   Search
export
   writeOut:WriteOut
define
   F
   F1
   proc{WriteOut Datos NomArchivoSalida NombArchXML Solucion Costo}      
      F={New Open.file  
	 init(name:  NomArchivoSalida 
	      flags: [write create]
	      mode:  mode(owner: [read write]  
			  group: [read write]))
	}
      F1={New Open.file  
	 init(name:  NombArchXML
	      flags: [write create]
	      mode:  mode(owner: [read write]  
			  group: [read write]))
	}
      
      {F1 write(vs: {GenerarXML Datos Solucion})}
      {F write(vs: {GenerarSalida Datos Solucion Costo})}
      {F close()}
   end

   fun{Aplanar S}
      case S of
	 nil then nil
      [] X|Xr then
	 case X of
	    Y|Yr then
	    {List.append Y|{Aplanar Yr} {Aplanar Xr}}
	 else
	    X|{Aplanar Xr}	    
	 end
      end
   end  
      
   fun{GenerarSalida Datos Solucion Costo}      
      fun {GenSalidaIte Salida I}
	 %{System.show sal#Salida#i#I}
	 if I > 0 then
	    {GenSalidaIte Solucion.puntos.I.ind#" "#(Solucion.puntos.I.lSin.(Solucion.puntos.I.indRb))#"\n"#Salida (I-1)}
	 else
	    Salida
	 end	 
      end
   in 
      %{System.show def#{GenSalidaIte nil Datos.numPtos}}
      {GenSalidaIte nil Datos.numPtos}
   end

   fun {GenerarXML Datos Solucion}
      fun{GenXMLIte Solucion Salida I J}	 
	 if I >0 then	    
	    if J==1 then
	       {GenXMLIte Solucion  "\t<estacionBase trafico=\""#Solucion.pobRb.I#"\" probBloqueo=\""#0#"\">\n\t\t<antena tilt=\""#Solucion.conf.I.J.tilt#"\" azimut=\""#Solucion.conf.I.J.az#"\" potencia=\"" #Solucion.conf.I.J.pot#"\"></antena>\n"#Salida (I-1) 3}
	       
	    else if J==2 then 
		    {GenXMLIte Solucion "\t\t<antena tilt=\""#Solucion.conf.I.J.tilt#"\" azimut=\""#Solucion.conf.I.J.az#"\" potencia =\"" #Solucion.conf.I.J.pot#"\"></antena>\n"#Salida I (J-1)}
		    
		 else	    
		    {GenXMLIte Solucion "\t\t<antena tilt=\""#Solucion.conf.I.J.tilt#"\" azimut=\""#Solucion.conf.I.J.az#"\" potencia=\"" #Solucion.conf.I.J.pot#"\"></antena>\n\t</estacionBase>\n"#Salida I (J-1)}		    
		 end
	    end
	 else
	    "<?xml version=\"1.0\" ?>\n<red nombre =\"nombreRed\" sec = \"1\" cobertura=\""#Solucion.cap#"\">\n"#Salida#"\n</red>"
	 end
      end   
   in
      {GenXMLIte Solucion nil Datos.numRB 3}
   end   
end

  