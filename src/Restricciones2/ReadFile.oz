functor
   
import
   Open
   System
   
export
   leerArchivo:LeerArchivo
   leerGain:LeerArchivoGain
   leerConfig:LeerArchivoConfig
   leerTrafico:LeerTrafico
   fillNetInfo:FillNetInfo
define
   proc {FillNetInfo FileName Data}
      Rec
      Pos={NewCell 0}
      Canales
      ListAddPot
      ListAddTilt
      ListAddAzim
      CuantosAzim
      CuantosTilt
      CuantosPot
      fun{ReadList Size Ini Rc}
	 fun {ReadListIte Index Acum}
	    if Index > Size then
	       Acum
	    else
	       {ReadListIte (Index+1) {String.toInt Rc.(Ini+Index)}|Acum}
	    end	    
	 end
      in
	 {ReadListIte 1 nil}
      end
   in
      %{System.show 'Inicia FillNetInfo'}
      Rec =  Rec={List.toTuple 'es' {String.tokens {ReemplazarC {ReemplazarC {Read FileName} 10 32} 9 32} & }}
      Canales = {MakeTuple 'channels' (Data.numRB*3) }     
      
      for I in 1..Data.numRB do
	
	 Canales.((I-1)*3 +1)= {String.toInt Rec.(5+{Cell.access Pos})}	
	 Canales.((I-1)*3 +2)= {String.toInt Rec.(10+{Cell.access Pos})}	
	 Canales.((I-1)*3 +3)= {String.toInt Rec.(15+{Cell.access Pos})}
	
	 Data.radioBases.I.antenas=ants(1:ant(pot:{String.toInt Rec.(2+{Cell.access Pos})}
					      tilt:{String.toInt Rec.(1+{Cell.access Pos})}
					      azimuth:{String.toInt Rec.(3+{Cell.access Pos})}
					     
					     )
					2:ant(pot:{String.toInt Rec.(7+{Cell.access Pos})}
					      tilt:{String.toInt Rec.(6+{Cell.access Pos})}
					      azimuth:{String.toInt Rec.(8+{Cell.access Pos})}
					    
					     )
					3:ant(pot:{String.toInt Rec.(12+{Cell.access Pos})}
					      tilt:{String.toInt Rec.(11+{Cell.access Pos})}
					      azimuth:{String.toInt Rec.(13+{Cell.access Pos})}
					      
					     )
				       )
	 
	 Data.radioBases.I.rang = {MakeTuple 'rang' 3}
	 Data.radioBases.I.rang.1 ={String.toInt Rec.(4+{Cell.access Pos})}
	 Data.radioBases.I.rang.2 ={String.toInt Rec.(9+{Cell.access Pos})}
	 Data.radioBases.I.rang.3 ={String.toInt Rec.(14+{Cell.access Pos})} 
	 {Cell.assign Pos  ({Cell.access Pos}+15)}
	 
      end
      
      Data.canales=Canales
      {Cell.assign Pos  ({Cell.access Pos}+1)}
      CuantosPot = {String.toInt Rec.({Cell.access Pos})}

      
      ListAddPot = {ReadList CuantosPot {Cell.access Pos} Rec}
      {Cell.assign Pos  ({Cell.access Pos}+(CuantosPot+1))}


      
      CuantosTilt = {String.toInt Rec.({Cell.access Pos})}

      ListAddTilt= {ReadList CuantosTilt {Cell.access Pos} Rec}
      {Cell.assign Pos  ({Cell.access Pos}+(CuantosTilt+1))}


      
      CuantosAzim ={String.toInt Rec.({Cell.access Pos})} 
      ListAddAzim= {ReadList CuantosAzim {Cell.access Pos} Rec}
      {Cell.assign Pos  ({Cell.access Pos}+CuantosAzim)}

      Data.listAddPot= ListAddPot
      Data.listAddTilt=ListAddTilt
      Data.listAddAzim=ListAddAzim

      %{System.show 'Antes de Cocanal FillNetInfo'}    

      Data.cocanal = {MakeTuple 'cocanal' (Data.numRB)*3}
      for I in 1..(Data.numRB)*3 do
	 Data.cocanal.I ={MakeTuple 'Cocanal ' (Data.numRB)*3}
	 for J in 1..(Data.numRB)*3 do		 
	    Data.cocanal.I.J ={String.toInt Rec.({Cell.access Pos}+((I-1)*(Data.numRB)*3+J))}		
	 end	     
      end


      %{System.show 'Termina FillNetInfo'}
   end
   %%La probabilidad de bloqueo se recibe como flotante
   proc {LeerTrafico Trafico BloqProb MaxCanales MaxCanalesAnt}
      Filas
      Columnas
      Tags
      CellProbCerca ={Cell.new 0}
      Rec
   in
      {System.show 'Inicia trafico'#BloqProb#'canales'#MaxCanales}
      Rec={List.toTuple 'es' {String.tokens {ReemplazarC {ReemplazarC {Read '../propagadores/tablaErlangB.txt'} 10 32} 9 32} & }}
      {System.show '2'#BloqProb#'canales'#MaxCanales}
      Filas   = { String.toInt Rec.1 }
      {System.show '3'#BloqProb#'canales'#MaxCanales}
      Columnas = { String.toInt Rec.2 }
      {System.show '4'#BloqProb#'canales'#MaxCanales}
      Tags = {MakeTuple 'tags' (Columnas-1)}
      {System.show '5'#BloqProb#'canales'#MaxCanales}
      for I in 2..Columnas do
	 {System.show 'Rec'#(Rec.(I+2))}
	 Tags.(I-1) = {String.toFloat (Rec.(I+2))}
	% {System.show 'Encontro la probabilidad '#I#' Valor = '#Tags.I}
      end
      for I in 2..Columnas do
	 if I < Columnas then
	    if {Bool.'and' (Tags.(I-1) =< BloqProb) (Tags.(I) > BloqProb )} then
	       {System.show 'Encontro la probabilidad '#(I)#' Valor = '#Tags.(I-1)}
	       {Cell.assign CellProbCerca I}
	    else
	       {System.show 'No está '#I}
	    end
	 elseif {Cell.access CellProbCerca} == 0 then 
	    {Cell.assign CellProbCerca (Columnas)}
	 end	
      end
      {System.show 'Antes if columna '#{Cell.access CellProbCerca}}           
      if MaxCanales =< Filas then
	 {System.show 'Index'#((MaxCanales)*Columnas + {Cell.access CellProbCerca})}
	 Trafico = rc(1:{String.toFloat
			 (Rec.((MaxCanales)*Columnas +
			       ({Cell.access CellProbCerca}+2)))}
		      2: {String.toFloat
			 (Rec.((MaxCanalesAnt)*Columnas +
			       ({Cell.access CellProbCerca}+2)))}
		     )	 
	 {System.show 'Encontro El trafico  Valor = '#Trafico.1 #' para antena '#Trafico.2}
      else
	 {System.show 'No está'}
      end
   end
   proc {LeerArchivoConfig Config}
      Rec={List.toTuple 'es' {String.tokens {ReemplazarC {Read 'ozConfig.cnf'} 10 32} & }}
      SolType
      Strategy
      Weigth
      WriteCurrent      
      InstanceCurrent
      SignalsCurrent
      InstanceFile
      SignalsFile
      InputFile
      InputNet
      InputGain
      NetFile
      JarDir
      T
      Relax
      WriteAll
      JustOne
      Recomp
      FlgRecomp
   in
      
      SolType={String.toInt Rec.1}
      Weigth = {MakeTuple 'wt' 4}

      for I in 1..4 do
	 Weigth.I = wt(active : {String.toInt Rec.(2+((I-1)*2)) } weigth:{String.toInt Rec.(3+(I-1)*2)})
	 {System.show 'ind'#(2+((I-1)*2))}
      end
      T = t(active:{String.toInt Rec.10} t:{String.toInt Rec.11})
      Relax=r(active:{String.toInt Rec.12})
      Strategy={String.toInt Rec.13}+1      
      JustOne = {String.toInt Rec.14}
      WriteAll ={String.toInt Rec.15}

      FlgRecomp = Rec.16
      if (FlgRecomp == 1)then
	 Recomp = Rec.17
      else
	 Recomp = ~1
      end 
	           
      WriteCurrent=r(active:{String.toInt Rec.18})
      InstanceCurrent = Rec.19
      SignalsCurrent = Rec.20
      InstanceFile = Rec.21
      SignalsFile = Rec.22
      InputNet  = Rec.23
      InputFile = Rec.24
      InputGain = Rec.25
      NetFile = Rec.26
      JarDir = Rec.27

      
      Config = config(solType:SolType
		      weigth:Weigth
		      t:T
		      strategy:Strategy
		      instanceCurrent:InstanceCurrent
		      signalsCurrent:SignalsCurrent
		      instanceFile:InstanceFile
		      signalsFile:SignalsFile
		      inputFile:InputFile
		      inputNet:InputNet
		      inputGain:InputGain
		      netFile:NetFile
		      jarDir:JarDir
		      useRelax:Relax
		      writeCurrent:WriteCurrent
		      writeAll:WriteAll
		      justOne:JustOne
		      recomp:Recomp
		     )	            
     
   end
   
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


  %   fun {Get Rec I J K Ni Nj Nk Salto}
%        Rec.(Salto + ((I-1)*(Nj*Nk)+((J-1)*Nk)+K))
%     end
    

    proc {LeerArchivoGain Nombre Gain}
       Rec={List.toTuple 'es' {String.tokens {ReemplazarC {Read Nombre} 10 32} & }}
       Dists
       Tilts
       Azims
       Offset
       GainM
    in
       {System.show 'Inicia lectura de ganancia'}
       Dists={String.toInt Rec.1}
       Tilts={String.toInt Rec.2}
       Azims={String.toInt Rec.3}
       
       %{System.show dist#Dists#tilts#Tilts#azims#Azims#total#{Width Rec}}
       GainM = {MakeTuple 'gain' (Dists*Tilts*Azims)}
       for I in 1..(Dists*Tilts*Azims) do
	  GainM.I = {String.toInt Rec.(3 + I)}
       end
              
       Offset= {String.toInt Rec.((Dists*Tilts*Azims)+4)}
       {System.show offset#Offset}
       Gain= gain(offset:Offset gain:GainM dist:Dists tilts:Tilts azims:Azims)
       {System.show 'Termina lectura de ganancia'}
    end

    proc {LeerArchivo Nombre Datos}
       R              %registro con los datos del archivo
       N              %nro de radiobases
       M              %nro de Puntos
       Pos            %posición que se va leyendo en el archivo
       
       UmbralSign     %Umbral de señal
       UmbralInterf   %Umbral de interferencia
       MinSol         %Mínimo solapamiento permitido
       MaxSol         %Máximo solapamiento permitido
       MaxPot         %Máxima potencia
       MinPot         %Mínima potencia
       MaxTilt        %Máximo tilt
       MinTilt        %Mínimo tilt
       Ptos           %Toda la información de los puntos
       Rbs            %Toda la información de las radiobases                 
       
       TotAntByPoints %Total de antenas por punto
       Poblacion      %Población por celda de la grilla       
       UmbralTrafico  %Umbral de trafico en Erlangs    
       TotPtos        %Total de puntos
       NetName        %Nombre de la red
       PathFileWrite  %Ruta donde se debe escribir el archivo de salida       
       IntTrafEnt     %Parte entera de las intensidades de trafico de las celdas
       IntTrafDec     %Parte decimal de las intensidades de trafico de las celdas
       NumAntByPnt       
       %%Lista con los indices de los puntos que deben usarse para garantizar la
       %%movilidad de los usuarios
       PointsForHandoff
       
       MaxDistance %%Distancia m'axima hasta la que una antena radiando a la maxima potencia
       %%puede llegar
       MinDistance
       fun{FillPointsForHandoff Ptos MaxDistance MinDistance}
	  fun{FillHandoffIte I J List1}
	     if I > {Width Ptos} then
		%%La convierto a tupla
		{List.toTuple 'handoff' List1} 
	     elseif J > Ptos.I.numAntenas then 
		%%Se acabaron las antenas y con ninguna se cumple la
		%%distancia, asi que sigo con otro punto
		{FillHandoffIte (I+1) 1 List1}
	     elseif {Bool.'and' (Ptos.I.distancia.J > (MinDistance-200.0)) (Ptos.I.distancia.J =<MaxDistance )} then
		%%se incluye en la lista y se toma el siguiente punto.
		{FillHandoffIte (I+1) 1 I|List1}
	     else
		%%Se continua con la otra antena
		{FillHandoffIte I (J+1) List1}
	     end
	  end
       in
	  {FillHandoffIte 1 1 nil}
       end
       
       proc{ArmarEstructuras }
	  Pos={Cell.new 0}
	  TotAntByPoints = {Cell.new 0}
	  
	  MinPot = {String.toInt R.1}
	  MaxPot = {String.toInt R.2}
	  MinSol = {String.toInt R.3}
	  MaxSol = {String.toInt R.4} 
	  MinTilt= {String.toInt R.5}
	  MaxTilt= {String.toInt R.6}
	  UmbralInterf ={String.toInt R.7}
	  UmbralSign   ={String.toInt R.8}
	  UmbralTrafico={String.toInt R.9}
	  N={String.toInt R.10}
 	  
	  %%Actualiza la posición en la lectura del archivo
	  {Cell.assign Pos 10}

	  Rbs = {MakeTuple 'rbs' N }
	  	  	  
	  for I in 1..N do	    
	     Rbs.I = rb(x:{String.toInt R.(1+{Cell.access Pos})}
			y: {String.toInt R.(2+{Cell.access Pos})}
			hrb:{String.toInt R.(3+{Cell.access Pos})}		
			angle:_
			antenas:_
			rang:_
		       )
	     {Cell.assign Pos  ({Cell.access Pos}+4)}	  
	  end
	  {Cell.assign Pos  ({Cell.access Pos}+1)}	  
	  M={String.toInt R.({Cell.access Pos}+1)}
	  %%Puntos con incidencia
	  TotPtos={String.toInt R.({Cell.access Pos})}
	  MaxDistance={String.toFloat R.({Cell.access Pos}+2)}
	  MinDistance = {String.toFloat R.({Cell.access Pos}+3)}
	  
	  NumAntByPnt= {MakeTuple 'numAntsByPnt' M }
	  
	  {System.show m#M}
	  %%{System.show todos#TotPtos}
	  Ptos = {MakeTuple 'ptos' M}
	  
	  Poblacion= {MakeTuple 'pob' M}
	  {Cell.assign Pos  ({Cell.access Pos}+4)}
{System.show m#M}

	  for I in 1..M do

	     Ptos.I = pto(ind:({String.toInt (R.{Cell.access Pos})}+1)
			  x:{String.toInt R.({Cell.access Pos}+1)}
			  y: {String.toInt R.({Cell.access Pos}+2)}
			  numAntenas:_
			  lRbs:_
			  lAnts:_
			  lAzimIni:_
			  lElevIni:_
			  posIniAnts:({Cell.access TotAntByPoints})
			  distancia:_
			  tipoDist:_   
			 )

	     Poblacion.I ={String.toInt R.({Cell.access Pos}+3)}
	     %{System.show 'x'#'  '#Ptos.I.ind#' '#Ptos.I.x#' '# Ptos.I.y #''# Poblacion.I}

	     {Cell.assign Pos  ({Cell.access Pos})+4}	     	     
	     %{System.show antByPoints#{Cell.access TotAntByPoints}}
	     
	     Ptos.I.numAntenas = {String.toInt R.({Cell.access Pos})}

	     NumAntByPnt.I =  Ptos.I.numAntenas
	     
	     {Cell.assign TotAntByPoints ({Cell.access TotAntByPoints})+Ptos.I.numAntenas}
	     %{System.show cuantas#Ptos.I.numAntenas}

	     Ptos.I.lRbs = {MakeTuple 'rbs'  Ptos.I.numAntenas}
	     Ptos.I.lAnts = {MakeTuple 'ants'  Ptos.I.numAntenas}
	     Ptos.I.lAzimIni = {MakeTuple 'azimIni'  Ptos.I.numAntenas}
	     Ptos.I.lElevIni = {MakeTuple 'elevIni'  Ptos.I.numAntenas}
	     Ptos.I.distancia = {MakeTuple 'dist'  Ptos.I.numAntenas}
	     Ptos.I.tipoDist = {MakeTuple 'tipoDist'  Ptos.I.numAntenas}
	     for J in 1..Ptos.I.numAntenas do 
		Ptos.I.lRbs.J     = ({String.toInt R.({Cell.access Pos}+1)}+1)
		Ptos.I.lAnts.J    = ({String.toInt R.({Cell.access Pos}+2)}+1)		
		Ptos.I.distancia.J ={String.toFloat R.({Cell.access Pos}+3)}
		Ptos.I.tipoDist.J = {String.toInt R.({Cell.access Pos}+4)}
		{Cell.assign Pos  (4+{Cell.access Pos})}
	     end
	     {Cell.assign Pos  ({Cell.access Pos})+1} 
	  end

	  PointsForHandoff = {FillPointsForHandoff Ptos MaxDistance MinDistance}
	  
	  {System.show 'Total puntos '#M#' Total para handoff '#{Width PointsForHandoff}}
	  {Cell.assign Pos  ({Cell.access Pos})-1}	  
	  	  
	  NetName = {String.toAtom R.({Cell.access Pos}+1)}
	  PathFileWrite={String.toAtom R.({Cell.access Pos}+2)}
	  

	  
	  %Lee parte entera de la intensidad de trafico
	  IntTrafEnt = {MakeTuple 'intTrafEnt' M}
	  {Cell.assign Pos  (3+{Cell.access Pos})}
	  for J in 1..M do
	     IntTrafEnt.J = {String.toInt R.({Cell.access Pos}+(J-1))}
	  end

	  %Lee parte decimal de la intensidad de trafico
	  IntTrafDec = {MakeTuple 'intTrafDec' M}
	  {Cell.assign Pos  (M+{Cell.access Pos})}
	  for J in 1..M do
	     IntTrafDec.J ={String.toInt R.({Cell.access Pos}+(J-1))}
	  end	  
       end
      {System.show m#M}
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
		cocanal:    _		
		pobl:Poblacion
		canales:_
		umbTraf:UmbralTrafico
		salAzim:5
		salTilt:5
		salPot:5		
		netName:NetName		
		pathFilesWrite:PathFileWrite
		totAntByPoints:{Cell.access TotAntByPoints}
		gainFile:_

		intTrafEnt: IntTrafEnt
		intTrafDec: IntTrafDec
		numAntByPnt:NumAntByPnt
		pesos:_
		useRelax:_
		offset:_
		maxTrafico:_
		maxTraficoAnt:_
		minIntTrafico:_
		strategy:_
		listAddPot:_
		listAddTilt:_
		listAddAzim:_
		forHandoff:PointsForHandoff
		minDistance:MinDistance
		maxDistance:MaxDistance
		)
       %{System.show hay#' '#{Width R}}
    end
end
 