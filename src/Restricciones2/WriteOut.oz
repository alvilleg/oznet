functor
import
   Open
%   System

export
   writeOut:WriteOut
define
   
   
   proc{WriteOut Datos NomArchivoSalida NombArchXML Solucion Costo}
      F
      F1
   in      
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
      fun{GenOutput Rc Index Acum}
	 if Index >{Width Rc} then
	    Acum
	 else
	    {GenOutput Rc (Index+1) Solucion.puntos.(Rc.Index).ind#'\n'#Acum}
	 end
      end   
      fun {GenSalidaIte Salida I}
	 %{System.show sal#Salida#i#I}
	 if I > 0 then
	    {GenSalidaIte Solucion.puntos.I.ind#" "#((Solucion.puntos.I.lSignTot.(Solucion.puntos.I.indRb))+Datos.offset)#" "#(Solucion.flgInterf.I)#"\n"#Salida (I-1)	     
	    }
	 else
	    Salida
	 end	 
      end
   in 
      %{System.show def#{GenSalidaIte nil Datos.numPtos}}
      {GenSalidaIte nil Datos.numPtos}
      %#{GenOutput Datos.forHandoff 1 nil}
   end

   fun {GenerarXML Datos Solucion}
      fun{GenXMLIte Solucion Salida I J}	 
	 if I >0 then	    
	    if J==1 then
	       {GenXMLIte Solucion
		"\t<estacionBase trafico=\""#Solucion.pobRb.I#"\" probBloqueo=\""#0#
		"\">\n\t\t <antena tilt=\""#Solucion.conf.I.J.tilt.dom#"\" azimut=\""#Solucion.conf.I.J.az.dom#"\" potencia=\"" #Solucion.conf.I.J.pot.dom#"\" rango =\""#Datos.radioBases.I.rang.(Solucion.conf.I.J.rang.dom)#"\"></antena>\n"#Salida (I-1) 3}
	       
	    else if J==2 then 
		    {GenXMLIte Solucion "\t\t<antena tilt=\""#Solucion.conf.I.J.tilt.dom#"\" azimut=\""#Solucion.conf.I.J.az.dom#"\" potencia =\"" #Solucion.conf.I.J.pot.dom# "\" rango =\""#Datos.radioBases.I.rang.(Solucion.conf.I.J.rang.dom)#"\"></antena>\n"#Salida I (J-1)}
		    
		 else	    
		    {GenXMLIte Solucion "\t\t<antena tilt=\""#Solucion.conf.I.J.tilt.dom#"\" azimut=\""#Solucion.conf.I.J.az.dom#"\" potencia=\"" #Solucion.conf.I.J.pot.dom#"\" rango =\""#Datos.radioBases.I.rang.(Solucion.conf.I.J.rang.dom)#"\"></antena>\n\t</estacionBase>\n"#Salida I (J-1)}		    
		 end
	    end
	 else
	    local
	       
	       Objetivos = "<objetivos interferencia=\""#Solucion.obj.1.dom#"\" actSet=\""#Solucion.obj.2.dom#"\" capacidad=\""#Solucion.obj.3.dom#"\" trafico=\""#Solucion.obj.4.dom#"\" ></objetivos>"#nil
	    in	       
	       "<?xml version=\"1.0\" ?>\n<red nombre =\"nombreRed\" sec = \"1\" cobertura=\""#Solucion.cap#"\">\n"#Salida#"\n"#Objetivos#"\n</red>"
	    end
	 end
      end   
   in
      {GenXMLIte Solucion nil Datos.numRB 3}
   end   
end

  