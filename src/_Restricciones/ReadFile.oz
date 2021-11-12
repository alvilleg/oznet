
functor
 import
    Open
%    Browser
    System
 export
    leerArchivo:LeerArchivo
    leerGain:LeerArchivoGain
 define
%declare
    proc {Read A ?L}
       F={New Open.file init(name:A flags:[read])}
    in
       {F read(list:L size:all)}
       {F close}
    end
    
    fun {ReemplazarC List C1 C2}
       case List of
	  nil then nil
	  [] P|Lc then
	  if  P==C1 then
	     C2|{ReemplazarC Lc C1 C2}
	  else
	     P|{ReemplazarC Lc C1 C2}
	  end
       end
    end
    fun {EliminaC List C}
       case List of
	  nil then nil
       [] P|Lc then
	  if  P==C then
	     {EliminaC Lc C}
	  else
	     P|{EliminaC Lc C}
	  end
       end
    end
    fun {Get Rec I J K Ni Nj Nk Salto}
       Rec.(Salto + ((I-1)*(Nj*Nk)+((J-1)*Nk)+K))
    end
    proc {LeerArchivoGain Nombre Gain}
       Rec={List.toTuple 'es' {String.tokens {ReemplazarC {Read Nombre} 10 32} & }}
       Dists
       Tilts
       Azims
    in
       
       Dists={String.toInt Rec.1}
       Tilts={String.toInt Rec.2}
       Azims={String.toInt Rec.3}
       %{System.show dist#Dists#tilts#Tilts#azims#Azims#total#{Width Rec}}
       Gain = {MakeTuple 'gain' Dists}
       for I in 1..Dists do
	  Gain.I={MakeTuple 't' Tilts}
	  for J in 1..Tilts do
	     Gain.I.J = {MakeTuple 'a' Azims}
	     for K in 1..Azims do
		Gain.I.J.K = {String.toInt {Get Rec I J K Dists Tilts Azims 3}}
		%{System.show  posi#(((I-1)*(Tilts*Azims)+((J-1)*Azims)+K))#value#{String.toInt {Get R I J K Dists Tilts Azims 3}} }
	     end
	  end
       end
    end
    proc {LeerArchivo Nombre Datos}
       R %
       N %nro de radiobases
       M %nro de Puntos
       UmbralSign % Umbral de señal
       UmbralInterf % Umbral de interferencia
       MinSol %Mínimo solapamiento permitido
       MaxSol %Máximo solapamiento permitido
       MaxPot
       MinPot
       MaxTilt
       MinTilt
       Ptos   % Toda la información de los puntos
       Rbs    %Toda la información de las radiobases
       DistRbPto %distancia de la radiobase al punto
 %      DistRbPtoT % distancia de la base de la torre al punto
       DistTipo   %Tipo de distanci entre una radiobase y un punto
       Cocanal    %Antenas cocanal
       RbPosCobPto %Radio base puede cubrir punto
       Pos %Posición que se va leyendo en el archivo
  %     DatosPuntos
     %  CuantasAnt
       Poblacion %Población por celda de la grilla
       Canales   %cantidad de canales por Radiobase
       UmbralTrafico %Umbral de trafico en Erlangs
       %{System.show nombre#Nombre}
       TotPtos
       NetName 
       PathFileWrite
       GainFile 
       proc{ArmarEstructuras }
	  Pos={Cell.new 0}
	  MinPot={String.toInt R.1}
	  MaxPot={String.toInt R.2}
	  MinSol={String.toInt R.3}
	  MaxSol={String.toInt R.4}
	  MinTilt={String.toInt R.5}
	  MaxTilt={String.toInt R.6}
	  UmbralInterf={String.toInt R.7}
	  UmbralSign={String.toInt R.8}
	  UmbralTrafico={String.toInt R.9}
	  N={String.toInt R.10}
	  
	  %Actualiza la posición en la lectura del archivo
	  {Cell.assign Pos 10}
	  Rbs={MakeTuple 'rbs' N }
	  Canales={MakeTuple 'channels' N }

	  for I in 1..N do	    
	     Rbs.I = rb(x:{String.toInt R.(1+{Cell.access Pos})}
			y: {String.toInt R.(2+{Cell.access Pos})}
			hrb:{String.toInt R.(3+{Cell.access Pos})}		
			angle:_
			antenas:_		
		       )	     
	     Canales.I={String.toInt R.(4+{Cell.access Pos})}
	     {Cell.assign Pos  ({Cell.access Pos}+4)}
	     Rbs.I.antenas= ants(1:ant(pot:{String.toInt R.(2+{Cell.access Pos})}
				      tilt:{String.toInt R.(1+{Cell.access Pos})}
				      azimuth:{String.toInt R.(3+{Cell.access Pos})} )
				2:ant(pot:{String.toInt R.(5+{Cell.access Pos})}
				      tilt:{String.toInt R.(4+{Cell.access Pos})}
				      azimuth:{String.toInt R.(6+{Cell.access Pos})} )
				3:ant(pot:{String.toInt R.(8+{Cell.access Pos})}
				      tilt:{String.toInt R.(7+{Cell.access Pos})}
				      azimuth:{String.toInt R.(9+{Cell.access Pos})} )
			       )
	   {Cell.assign Pos  ({Cell.access Pos}+9)}
	  end

	  {Cell.assign Pos  ({Cell.access Pos}+1)}	  
	  M={String.toInt R.({Cell.access Pos}+1)}%Puntos con incidencia
	  TotPtos={String.toInt R.({Cell.access Pos})}
	  
	  %{System.show m#M}
	  %{System.show todos#TotPtos}
	  Ptos = {MakeTuple 'ptos' M}
	  Poblacion= {MakeTuple 'pob' M}
	  {Cell.assign Pos  ({Cell.access Pos}+2)}


	  for I in 1..M do

	     Ptos.I = pto(ind:({String.toInt (R.{Cell.access Pos})}+1)
			  x:{String.toInt R.({Cell.access Pos}+1)}
			  y: {String.toInt R.({Cell.access Pos}+2)}
			  numAntenas:_
			  lRbs:_
			  lAnts:_
			  lAzimIni:_
			  lElevIni:_
			 )
	     Poblacion.I ={String.toInt R.({Cell.access Pos}+3)}
	     %{System.show 'x'#'  '#Ptos.I.ind#' '#Ptos.I.x#' '# Ptos.I.y #''# Poblacion.I}



	     

	     {Cell.assign Pos  ({Cell.access Pos})+4}   	     
	     Ptos.I.numAntenas = {String.toInt R.({Cell.access Pos})}
	     %{System.show cuantas#Ptos.I.numAntenas}

	     Ptos.I.lRbs = {MakeTuple 'rbs'  Ptos.I.numAntenas}
	     Ptos.I.lAnts = {MakeTuple 'ants'  Ptos.I.numAntenas}
	     Ptos.I.lAzimIni = {MakeTuple 'azimIni'  Ptos.I.numAntenas}
	     Ptos.I.lElevIni = {MakeTuple 'elevIni'  Ptos.I.numAntenas}
	     for J in 1..Ptos.I.numAntenas do 
		Ptos.I.lRbs.J     = ({String.toInt R.({Cell.access Pos}+1)}+1)
		Ptos.I.lAnts.J    = ({String.toInt R.({Cell.access Pos}+2)}+1)

	%       Ptos.I.lElevIni.J = elevIni({String.toInt R.({Cell.access Pos}+4)})				     
		{Cell.assign Pos  (2+{Cell.access Pos})}

	     end
	     {Cell.assign Pos  ({Cell.access Pos})+1} 
	  end
	  {Cell.assign Pos  ({Cell.access Pos})-1} 
 	  DistRbPto = {MakeTuple 'dRbPto' TotPtos}
	  for I in 1..TotPtos do
	     DistRbPto.I = {MakeTuple 'dRbIpto' N}	    
	     for J in 1..N do
		DistRbPto.I.J={Float.toInt {String.toFloat R.({Cell.access Pos}+((I-1)*N+J))}}
		%{System.show DistRbPto.I.J}
	     end
	  end
	  {Cell.assign Pos  (TotPtos*N+{Cell.access Pos})}
	  DistTipo = {MakeTuple 'dRbPto' TotPtos}
	  for I in 1..TotPtos do
	     DistTipo.I = {MakeTuple 'dRbIpto' N}	    
	     for J in 1..N do
		DistTipo.I.J={String.toInt R.({Cell.access Pos}+((I-1)*N+J))}
	     end
	  end
	  {Cell.assign Pos  (TotPtos*N+{Cell.access Pos})}
 	 
  	  %for I in 1..N do
%  	     DistRbPtoT.I = {MakeTuple 'dRbIptoT' M}	    
%  	     for J in 1..M do		
%		DistRbPtoT.I.J={String.toFloat R.({Cell.access Pos}+((I-1)*M+J))}
%		{System.show i#I#j#J#DistRbPtoT.I.J}
%  	     end
%  	  end
% 	  {Cell.assign Pos  (M*N+{Cell.access Pos})}
 	  Cocanal = {MakeTuple 'cocanal' N*3}
	  for I in 1..N*3 do
	     Cocanal.I ={MakeTuple 'Cocanal ' N*3}
	     for J in 1..N*3 do		 
		Cocanal.I.J ={String.toInt R.({Cell.access Pos}+((I-1)*N*3+J))}		
	     end	     
	  end
	  {Cell.assign Pos  (N*N*9+{Cell.access Pos})}
	  RbPosCobPto = {MakeTuple 'rbCobPtos' N}
	  for I in 1..N do
	     RbPosCobPto.I = {MakeTuple 'rbCobPto' M }	    
	     for J in 1..M do
		RbPosCobPto.I.J={String.toInt R.({Cell.access Pos}+((I-1)*M+J))}		
	     end
	  end
	  {Cell.assign Pos  (M*N+{Cell.access Pos})}
	  NetName = {String.toAtom R.({Cell.access Pos}+1)}
	  PathFileWrite={String.toAtom R.({Cell.access Pos}+2)}
	  GainFile = {String.toAtom R.({Cell.access Pos}+3)}
	  
       end
 %     
    in
       R={List.toTuple 'es' {String.tokens {ReemplazarC {Read Nombre} 10 32} & }}       
       {ArmarEstructuras}
       Datos=data(
		potMax:   MaxPot
		potMin:   MinPot       
		minSol:   MinSol
		maxSol:   MaxSol
		minTilt:  MinTilt
		maxTilt:  MaxTilt
		umbInterf:UmbralInterf
		umbSign:  UmbralSign
		numRB:    N
		numPtos:  M
		radioBases: Rbs
		puntos :    Ptos
		distancia:  DistRbPto	
		distTipo:DistTipo
		cocanal:    Cocanal
		rbPosCobPto:RbPosCobPto		
		pobl:Poblacion
		canales:Canales
		umbTraf:UmbralTrafico
		salAzim:5
		salTilt:5
		salPot:5
		netName:NetName
		gainFile:GainFile
		pathFilesWrite:PathFileWrite
		 )
       %{System.show hay#' '#{Width R}}
    end
end
 