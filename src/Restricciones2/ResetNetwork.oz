functor   
import
   Browser
   FD
   Module
   DistOztnet
   Misc
   System

export
   resetNetwork:ResetNetwork
   searchOne:SearchOne
define
      
%declare             
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                     FUNCIÓN PRINCIPAL  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
   
   fun {ResetNetwork Param Gain LowerBound}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PARÁMETROS DE ENTRADA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      local
	 %%Esta funcion devuelve una tupla en la que en cada posicion i se tiene
	 %% signals: record con las senales pertenecientes a la RB i
	 %% distTypes : tipos de distancia pertenecientes a la RB i
	 %% azimuths:  azimuths pertenecientes a la RB i
	 %% tilts : tilts pertenecientes a la RB i
	 %% todos estos registros son paralelos, es decir la informacion en posiciones iguales
	 %% esta correlacionada
	 fun {GroupData Punto Param RcRbsByPnt}
	    RcResult = {MakeTuple 'Rb' Param.numRB}
	    RcResultDef = {MakeTuple 'Rb' Param.numRB}
	    for I in 1..Param.numRB do
	       RcResult.I = rc(signals:_ distTypes:_ azimuths:_ tilts:_)
	       RcResultDef.I = rc(signals:_ distTypes:_ azimuths:_ tilts:_)
	       RcResult.I.signals   = {Cell.new nil}
	       RcResult.I.distTypes = {Cell.new nil}
	       RcResult.I.azimuths  = {Cell.new nil}
	       RcResult.I.tilts     = {Cell.new nil}
	    end
	    proc {ClasifyData Index Value1 RcResult}
	       {Cell.assign RcResult.Index.signals
		(Value1.signal|{Cell.access RcResult.Index.signals })
	       }
	       {Cell.assign RcResult.Index.distTypes
		(Value1.distType| {Cell.access RcResult.Index.distTypes})
	       }
	       
	       {Cell.assign RcResult.Index.azimuths
		(Value1.azimuth|{Cell.access RcResult.Index.azimuths} )
	       }
		  
	       {Cell.assign RcResult.Index.tilts
		( Value1.tilt | {Cell.access RcResult.Index.tilts} )
	       }
	    end
	 in
	    for I in 1..{Width Punto} do
	       for J in 1..(Param.numAntByPnt.I) do
		  {ClasifyData { Misc.getAntByPoint I J RcRbsByPnt Param }
		   rc(signal:Punto.I.lSign.J
		      distType: ((Param.puntos.I.tipoDist.J)-1)
		      azimuth:Punto.I.lAz.J
		      tilt: Punto.I.lEle.J)
		   RcResult
		  }
	       end
	    end

	    for I in 1..(Param.numRB) do
	       RcResultDef.I.signals = {List.toTuple 's' {Cell.access RcResult.I.signals}}
	       RcResultDef.I.distTypes= {List.toTuple 'd' {Cell.access RcResult.I.distTypes}}
	       RcResultDef.I.azimuths={List.toTuple 'a' {Cell.access RcResult.I.azimuths}}
	       RcResultDef.I.tilts={List.toTuple 't' {Cell.access RcResult.I.tilts}}
	    end
	    RcResultDef
	 end
	 
	 

	 fun {IsIncident RcAntByPoints RcRbsByPoints NumAntByPnt RbCobPto}
	    RcResult ={MakeTuple 'inc' {Width RcAntByPoints }}		     
	 in
	    for I in 1..{Width Param.numAntByPnt}do
	       for J in 1..(NumAntByPnt.I)do
		  if (RbCobPto.({Misc.getAntByPoint I J RcRbsByPoints Param}).I) == 1 then
		     RcResult.(((Param.puntos.I.posIniAnts)+J)) =
		     {Misc.getAntByPoint I J RcAntByPoints Param}
		  else
		     RcResult.(((Param.puntos.I.posIniAnts)+J)) = 0
		  end			      
	       end
	    end
	    RcResult
	 end
	 
	 fun {ExtractForHandoff Variable Indices}
	    RcResult = {MakeTuple 'res' {Width Indices}}
	 in
	    for I in 1..{Width Indices}do
	       RcResult.I = Variable.(Indices.I)
	    end
	    RcResult
	 end
	 
	 fun {SumRec Rec Puntos MaxDistance}
	    fun {ExistLesserDist I Ldist Max}
	       if I >{Width Ldist }then
		  false
	       elseif Ldist.I =< Max then
		  true
	       else
		 {ExistLesserDist (I+1) Ldist Max}
	       end
	    end
	    fun {SumRecIte Rec I Value}
	       if I > {Width Rec} then
		  Value
	       elseif {ExistLesserDist 1 Puntos.I.distancia MaxDistance} then 
		  {SumRecIte Rec (I+1) (Value+Rec.I)}
	       else
		  {SumRecIte Rec (I+1) Value}
	       end
	    end
	 in
	    {SumRecIte Rec 1 0}
	 end
	 
	 fun{IsIn RcList Elem}
	    {FindIte RcList Elem {Width RcList} 1}   
	 end
	 fun{FindIte RcList Elem N I}
	    if (N+1) == I then
	       false
	    else if RcList.I==Elem then
		    true
		 else
		    {FindIte RcList Elem N (I+1)}
		 end
	    end
	 end
	 
	 fun {MaxIt Rec I Max N}
	    {Value.wait Rec.I}
	    if I== N then
	       Max
	    else if Rec.I > Rec.Max then	   
		    {MaxIt Rec (I+1) I N}
		 else
		    {MaxIt Rec (I+1) Max N} 
		 end      
	    end
	 end
	 
	 fun{Maxim Lst}
	    {MaxIt Lst 1 {Width Lst} {Width Lst}}
	 end
	 fun {MinIntTraffic IntTrafEnt IntTrafDec}
	    fun{GetDecimalPart DecimalNumber}
	       if DecimalNumber >= 1.0 then
		  {GetDecimalPart (DecimalNumber/10.0)}
	       else
		  DecimalNumber
	       end
	    end
	    fun{GetMin Rc}
	       fun{GetMinIte Index MinCurr}
		  if Index > {Width Rc} then
		     MinCurr
		  elseif Rc.Index < MinCurr then
		     {GetMinIte (Index+1) Rc.Index}
		  else
		     {GetMinIte (Index+1) MinCurr}
		  end
	       end
	    in
	       {GetMinIte 1 Rc.1}
	    end
	    RecTrans = {MakeTuple 'int' {Width IntTrafEnt}}
	 in
	    for I in 1..{Width IntTrafEnt} do
	       RecTrans.I = {Int.toFloat IntTrafEnt.I} + {GetDecimalPart {Int.toFloat IntTrafDec.I}}
	    end
	    {GetMin RecTrans}
	 end
	 
	%  fun{FactList N}
% 	    {FactListIt N 1 1|nil 1}
% 	 end
% 	 fun{FactListIt N I L Ultimo}
% 	    if I==(N+1) then
% 	       L
% 	    else
% 	       {FactListIt N (I+1) {Append L (Ultimo*I|nil)} (Ultimo*I)}
% 	    end
% 	 end

	 % fun{GenRc N }
% 	    R
% 	 in
% 	    R= {MakeTuple 'rc' N}
% 	    for I in 1..N do
% 	       R.I = 1 %{Int.'mod' I 2}
% 	    end
% 	    R
% 	 end

	 %%Recibe una Radiobase una lista de radiobases incidentes en un punto, la lista paralela con
	 %%la antena correspondiente a cada radiobase, la radiobase y antena que ofrecen el mejor enlace,
	 %%y una tupla con toda la información de las radiobases, a partir de estos datos se determina la
	 %%lista de cocanalidad correspondiente a la radiobase y antena del mejor enlace.
	 %%K índice del punto a considerar
	
	 fun {CoberturaPunto K RbCobPto}
	    ResCobPTo = {MakeTuple 'flgRBPto' N}
	 in
	    for I in 1..N do
	       ResCobPTo.I = RbCobPto.I.K 
	    end
	    ResCobPTo
	 end
	 

	 Strategies = strategy(1:DistOztnet.strategy
			       2:DistOztnet.strategy2
			       3:DistOztnet.strategy3
			       4:DistOztnet.strategy4
			      )
	 
	 N        = Param.numRB     %Número de estaciones RadioBase
	 M        = Param.numPtos   %Número de puntos en los que se harán mediciones de Señal
	 
	 
	 MinPot   = Param.potMin    %Potencia mínima de las antenas
	 MaxPot   = Param.potMax    %Potencia máxima de las antenas
	 MinTilt  = Param.minTilt   %Tilt mínimo de las antenas 
	 MaxTilt  = Param.maxTilt   %Tilt máximo de las antenas
	 MinAzim  = 0               %Azimut mínimo de las antenas
	 MaxAzim  = 355             %Azimut máximo de las antenas
	 UmbCob   = Param.umbSign - Param.offset   %Umbral a partir del cual se puede definir si un punto tiene o no cobertura	 	 
	 SalAzim  = Param.salAzim   %Salto entre valores de Azimut
	 SalTilt  = {Float.toInt
		     {Float.ceil
		      ({Int.toFloat (Param.maxTilt - Param.minTilt)}/20.0)
		     }
		    }   %Salto entre valores de Tilt
	 SalPot   = {Float.toInt
		     {Float.ceil
		      ({Int.toFloat (Param.potMax - Param.potMin)}/20.0)
		     }
		    }
%Salto entre valores de Potencia

	 FD_PROP_1 = {Module.link '../propagadores/tilt.so{native}'|nil }
	 FD_PROP_2 = {Module.link '../propagadores/azim.so{native}'|nil }
	 FD_PROP_3 = {Module.link '../propagadores/bloqueo.so{native}'|nil }
	 FD_PROP_4 = {Module.link '../propagadores/activeSetProp.so{native}'|nil }
	 FD_PROP_5 = {Module.link '../propagadores/interference.so{native}'|nil }
	 FD_PROP_6 = {Module.link '../propagadores/matElemProp.so{native}'|nil }
	 
	 
	 
	 FD_PROP = fd( tilt:{Nth FD_PROP_1 1}.tilt
		       azim:{Nth FD_PROP_2 1}.azim
		       bloqueo:{Nth FD_PROP_3 1}.bloqueo
		       activeSet:{Nth FD_PROP_4 1}.activeSet
		       interference:{Nth FD_PROP_5 1}.interference
		       matElem:{Nth FD_PROP_6 1}.matElem
		     )

	 
	 %MaxCanales = Canal.({Maxim Canal})	 
	 %LFactChannels={FactList MaxCanales}

	 %%Deben leerse desde el archivo generado en java
	 Pesos = pesos( pesoInterf  : Param.pesos.3
			pesoActSet  : Param.pesos.2
			pesoPobAten : Param.pesos.4
			pesoTrafico : Param.pesos.1
		      )

	 local
	    Rec	    
	    fun {ObjsActives Index ListaPesos}
	       if Index < 1 then
		  {List.toTuple 'w' ListaPesos} 
	       elseif Param.pesos.(Index).active == 1 then
		  {ObjsActives (Index - 1)
		   Param.pesos.(Index).weigth|ListaPesos}
	       else
		  {ObjsActives (Index - 1)
		   ListaPesos 		   
		  }
	       end
	    end
	 in
	    Rec={ObjsActives 4 nil}	    
	    MaxComDiv = {Misc.detMCD Rec} 
	    DomObj = {Loop.forThread 0 10000 MaxComDiv  fun {$ Is I} I|Is end nil}
	    {System.show 'comun diviso '#MaxComDiv}

	 end	  	 	      	 
	 %%Población Total
	 TotalPob = {SumRec Param.pobl Param.puntos Param.maxDistance}	 
	 
	 %%Se debe borrar y reemplazar
	 XRb  =  {MakeTuple 'k' M} 
	 XPto =  {MakeTuple 'k' M} 
	 YRb  =  {MakeTuple 'k' M} 
	 YPto =  {MakeTuple 'k' M}
	 
	 for K in 1..M do
	    XRb.K  = {MakeTuple 'k' Param.puntos.K.numAntenas}
	    XPto.K = {MakeTuple 'k' Param.puntos.K.numAntenas}
	    YRb.K  = {MakeTuple 'k' Param.puntos.K.numAntenas}
	    YPto.K ={MakeTuple 'k' Param.puntos.K.numAntenas}
	    for L in 1..Param.puntos.K.numAntenas do		  
	       XRb.K.L  = Param.radioBases.(Param.puntos.K.lRbs.L).x
	       XPto.K.L = Param.puntos.K.x
	       YRb.K.L  = Param.radioBases.(Param.puntos.K.lRbs.L).y
	       YPto.K.L = Param.puntos.K.y
	    end
	 end

	 %%Devuelve el indice de radiobase o antena dependiendo del Registro que se reciba
	 %%Correspondiente al indice de antena dado		 	 
      in
	 proc {$ Root}
	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
	    Punto                      %Alamacenara datos de los puntos de medición
	    DomAzim                    %Dominio para el azimut de todas las antenas del sistema  
	    DomTilt                    %Dominio para el tilt de todas las antenas del sistema 
	    DomPot                     %Dominio para la potencia de todas las antenas del sistema 
	    Result                     %Almacenará la configuración final de la red
	    CobAux                     %Cantidad de antenas que cubren un punto en un momento determinado
	    RbCobPto                   %Indica que una radiobase cubre un punto
	    PobRB                      %Población correspondiente a una radiobase
	    
	    Cob
	    Cap	    
	    
	    %%Flag que indica si un punto cumple la restricción de mínimo y máximo de elementos en el
	    %%active set	     

	    %%Flag que indica si un punto cumple con la restricción de la interferencia
	    FlgReachInterf
	    	    
	    %%Tupla con los valores de los diferentes objetivos
	    Objetivo

	    %$La funcion objetivo total
	    ObjTotal

	    ValLim

	    RecAntByPoints = {MakeTuple 'antPnt' Param.totAntByPoints}
	    RecRbsByPoints = {MakeTuple 'rbsPnt' Param.totAntByPoints}
	    IndexAntByPnt={Cell.new 1}
	    ObjetivoInterfAux
	    RcRbData
	 in
	    {System.show '204'}
	    ObjetivoInterfAux ={FD.int 0#FD.sup}
	    Root = result(
		      conf:Result
		      puntos:Punto		      		      
		      pobRb:PobRB
		      cap:Cap
		      cob:Cob
		      obj:Objetivo
		      aObjetivo: ObjTotal		      
		      lAnts : RecAntByPoints		      
		      flgInterf:FlgReachInterf
		      )	 	 	    
	    {System.show '276'}

	    %%Debe quedar entre 0#100
	    Objetivo={MakeTuple 'obj' 4}
	    for I in 1..4 do
	       Objetivo.I = var(dom:{FD.int 0#100 } type:5 ind:I)
	    end

	    {System.show '284'}
	    {Browser.browse 'Lower Bound '#LowerBound}
	    
            %%%%%%%%%%%%%%%
	    FlgReachInterf    = {FD.tuple int M 0#1}
	     {System.show '289'}           	   

	    {System.show '293'}
	    
	    ObjTotal          = {FD.int DomObj}

	    {System.show '297'}
	    
	    ValLim            = {FD.int 0#1}
	    
	    %%for I in 1..(MaxCanales+1) do	       
	    %%   Ldom.I =: {Nth LFactChannels I}
	    %%end

	    RbCobPto= {MakeTuple 'rbCobPto' N}

	    {System.show '307'}
	    for I in 1..N do
	       RbCobPto.I={FD.tuple rbPto M 0#1}
	    end
	    
	    PobRB    = {MakeTuple 'pobRb' N}
	   
	    for I in 1..N do
	       PobRB.I={FD.int 0#FD.sup}	       
	    end

	    {System.show '313'}
	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ESTRUCTURAS DE DATOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 
	    %%Define la variable que va a almacenar el resultado
	    {MakeTuple solucion N Result}
	    for I in 1..N do
	       Result.I =
	       radioBase(
		  ind:_                      %Identificador de la radio-base
		  1:ant(az:_ tilt:_ pot:_ rang:_)  %Antena número 1 
		  2:ant(az:_ tilt:_ pot:_ rang:_)  %Antena número 2
		  3:ant(az:_ tilt:_ pot:_ rang:_)  %Antena número 3
		  )	       
	    end
	    
	    {System.show '329'}
      %Define los puntos donde se van a tomar mediciones
	    {MakeTuple punto M Punto}	
	    for K in 1..M do
	       Punto.K =
	       punto(
		  ind:_     %Identificador del punto		 
		  lSign:_    %Tupla con el nivel de señal que le da la antena en lAnt		  
		  lAz:_     %Azimut con que incide la señal en el punto
		  lEle:_    %Elevación con que incide la señal en el punto
		  indRb:_   %Identificador de la radiobase que le brinda el nivel de señal más alto		  
		  lSignTot:_		  
		  )
	    end
	    
	    {System.show '344'}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DOMINIOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
	    DomAzim = {Loop.forThread MinAzim MaxAzim SalAzim fun {$ Is I} I|Is end nil}
	    DomTilt = {Loop.forThread MinTilt (MaxTilt-1) SalTilt fun {$ Is I} I|Is end MaxTilt|nil}
	    DomPot  = {Loop.forThread MinPot  (MaxPot -1)  SalPot  fun {$ Is I} I|Is end MaxPot|nil}

	    {System.show '351'}
	    for  I in 1..N do
	       Result.I.ind    = I
	       
	       Result.I.1.az   = var(dom:{FD.int DomAzim} type:2)
	       Result.I.2.az   = var(dom:{FD.int DomAzim} type:2)
	       Result.I.3.az   = var(dom:{FD.int DomAzim} type:2)	   
	       	       
	       Result.I.1.tilt = var(dom:{FD.int DomTilt} type:1)
	       Result.I.2.tilt = var(dom:{FD.int DomTilt} type:1)
	       Result.I.3.tilt = var(dom:{FD.int DomTilt} type:1)
	    
	       Result.I.1.pot  = var(dom:{FD.int DomPot} type:3)
	       Result.I.2.pot  = var(dom:{FD.int DomPot} type:3)
	       Result.I.3.pot  = var(dom:{FD.int DomPot} type:3)

	       Result.I.1.rang  =var(dom:{FD.int 1#3} type:4)
	       Result.I.2.rang  =var(dom:{FD.int 1#3} type:4)
	       Result.I.3.rang  =var(dom:{FD.int 1#3} type:4)	       
	    end
	    
	    for K in  1..M do
%		{System.show 'k'#K#'m'#M}
		Punto.K.ind     =  Param.puntos.K.ind
		%%Quitar		
		for I in 1..Param.puntos.K.numAntenas do
		   %%Lista con la informaci'on de antena y radiobase por punto
		   %%Para tener control de la sectorizaci'on

		   RecAntByPoints.({Cell.access IndexAntByPnt}) = {FD.int 1#3}
		   RecRbsByPoints.({Cell.access IndexAntByPnt}) =  Param.puntos.K.lRbs.I
		   
		   {Cell.assign IndexAntByPnt ({Cell.access IndexAntByPnt}+1)}
		   %{System.show index#({Cell.access IndexAntByPnt})}
		end	       	
		Punto.K.lSign   = {FD.tuple sign Param.puntos.K.numAntenas 0#FD.sup}
		Punto.K.lSignTot= {FD.tuple signTot Param.puntos.K.numAntenas 0#FD.sup}
		Punto.K.lAz     = {FD.tuple azi Param.puntos.K.numAntenas 0#24}
		Punto.K.lEle    = {FD.tuple ele Param.puntos.K.numAntenas 0#18}	  
		Punto.K.indRb   = {FD.int 1#N}
		
	    end	 
	    {System.show 'Termina el ciclo'}
	    %Root.lAnts= {Cell.access ListAntsByPoint}
	    %{Browser.browse a#RecAntByPoints}
	    CobAux = {FD.tuple cob M 0#FD.sup }
	    Cob    = {FD.tuple cob M 0#1}
	    Cap    = {FD.int 0#FD.sup}
	    {System.show 'Inicialización'}

	    %%Se Agrupan los datos por Radiobase
	    RcRbData = {GroupData Punto Param RecRbsByPoints}
	     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%RESTRICCIONES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
         %Dos antenas de una radiobase no pueden tener el mismo rango
	    for I in 1..N do
	       {FD.distinct t(1:Result.I.1.rang.dom 2:Result.I.2.rang.dom 3:Result.I.3.rang.dom) }
	    end
	    {System.show 'Linea 370'}
	    
 	 %La diferencia entre azimut es 120
 	    for I in 1..N do
 	       %Result.I.1.az =: 20 %Param.radioBases.I.antenas.1.azimuth
 	       Result.I.2.az.dom =: Result.I.1.az.dom+120
 	       Result.I.3.az.dom =: Result.I.2.az.dom+120
 	    end

	    %%==========================================
	    %% Determina nivel de cumplimiento del objetivo del active set 
	    %%==========Calcula nivel de cumplimiento del objetivo del active set======= 	   	   	    	    

	    {System.show '382'}
	    
	    %%Calcula el azimuth y tilt relativos 
	    for K in 1..M do	    
	       for L in 1..Param.puntos.K.numAntenas do
		  {
		   FD_PROP.azim
		   Punto.K.lAz.L
		   ({Misc.getAntByPoint K L RecAntByPoints Param})
		   Result.({Misc.getAntByPoint K L RecRbsByPoints Param}).1.az.dom
		   XRb.K.L
		   XPto.K.L 
		   YRb.K.L  
   		   YPto.K.L 
		   5
		  }
	       end
	    end
	    {System.show '402'}
	    for K in 1..M do
	       for L in 1..Param.puntos.K.numAntenas do
		  thread
		     {Value.wait {Misc.getAntByPoint K L RecAntByPoints Param}}
		     {		      
		      FD_PROP.tilt
		      Result.({Misc.getAntByPoint K L RecRbsByPoints Param}).({Misc.getAntByPoint K L RecAntByPoints Param}).tilt.dom
		      Punto.K.lEle.L
		      2%Altura de la antena
		      Param.radioBases.({Misc.getAntByPoint K L RecRbsByPoints Param}).hrb
		      {Float.toInt Param.puntos.K.distancia.L}		      
		      Param.salTilt
		      K
		     } 
		     %{System.show 'fin l'#L#'k'#K}
		  end		  
 	       end	       
 	    end	    	    

	    for I in 1..N do
	       {FD_PROP.matElem
 	       RcRbData.I.signals %{AplanaSignals Punto RecRbsByPoints}
 	       RcRbData.I.tilts%{AplanaTilts Punto RecRbsByPoints}
 	       RcRbData.I.azimuths%{AplanaAzimuths Punto RecRbsByPoints}
 	       RcRbData.I.distTypes%{AplanaTipoDist Punto RecRbsByPoints}
 	       Gain.gain
 	       Gain.dist
 	       Gain.tilts
 	       Gain.azims
 	      }
 	    end
	     {System.show '420'#M}
	    for K in 1..M do
	       %{System.show '429'#K}
	       if Param.puntos.K.numAntenas == 1 then
		  %%Si solo hay una de antemano se conoce la deseada
		  Punto.K.indRb = 1
	       end
	       for L in 1..Param.puntos.K.numAntenas do
	 	  %{System.show 'l'#L#'K'#K#'M'#M}
% 		  {System.show 'ele'#Punto.K.lEle.L}
% 		  {System.show 'azim'# Punto.K.lAz.L}
% 		  {System.show 'sign'# Punto.K.lSign.L}

		  
		  %% Este es el matElem anterior
		 %  {FD_PROP.matElem		   
% 		   Punto.K.lEle.L
% 		   Punto.K.lAz.L
%   		   Punto.K.lSign.L
% 		   (Param.puntos.K.tipoDist.L-1)
% 		   Gain.gain
% 		   Gain.dist
% 		   Gain.tilts
% 		   Gain.azims
% 		  }
		                                  		  
		  thread
		     {FD.plus Result.({Misc.getAntByPoint  K L RecRbsByPoints Param}).({Misc.getAntByPoint  K L RecAntByPoints Param}).pot.dom
		      Punto.K.lSign.L
		      Punto.K.lSignTot.L
		     }
		  end		  
	       end
	    end
 	    
	    {System.show '527'}
	    
	    %Coloca el flag de relación de cobertura entre punto y radio base
	    {System.show 'min distance '#Param.minDistance #'max dist '# Param.maxDistance}
	    for I in 1..N do
	       for K in 1..M do		
		  if {IsIn Param.puntos.K.lRbs I} then
		     for L in 1..Param.puntos.K.numAntenas do
			if {Bool.'and' (Param.puntos.K.lRbs.L == I)
			    ({Bool.'not' {Value.isDet RbCobPto.I.K}})} then
			   if Param.puntos.K.distancia.L =< Param.minDistance then
			      RbCobPto.I.K =:1			      
			   elseif Param.puntos.K.distancia.L > Param.maxDistance then
			      RbCobPto.I.K =:0
			   else
			      (FD.sup*RbCobPto.I.K)+UmbCob >=: Punto.K.lSignTot.L
			      %%Para hacerlo 1	       
			      (FD.sup*(1-RbCobPto.I.K))+Punto.K.lSignTot.L >:UmbCob
			      %%Para hacerlo 0
			   end
			end
		     end
		  else
		     RbCobPto.I.K=:0
		     skip
 		  end		  
 	       end
	     end
	    
	     {System.show '461'}
	    
	    
 	    %%=========================================================================
 	    for K in 1..M do
  	       %{System.show cobertura#CobAux.K}
 	       {FD.sum {CoberturaPunto K RbCobPto} '>=:' Cob.K} %Para hacerlo 0
 	       {FD.sum {CoberturaPunto K RbCobPto} '=:' CobAux.K} 
	       CobAux.K =<: Cob.K*N
	       CobAux.K =<: Param.puntos.K.numAntenas
	       
	       %%Para hacerlo 1	       
 	    end
	    {System.show '472'}
 	    %%Determina la población que quedo dentro de la cobertura de la radiobase
 	    ValLim=:0
	    for I in 1..N do
   %  	       {System.show poblacion#PobRB.I}
	       {FD.sumAC Param.pobl  RbCobPto.I '=:'  PobRB.I }
	       {FD.sum  RbCobPto.I '>:' ValLim }
	    end
	    
	    {System.show '481'}
 	    %%Se identifica la Radiobase que provee el mejor enlace es el indice de la radiobase y antena que proporciona mayor cobertura
 	    thread	       
	       for K in 1..M do
		  if Param.puntos.K.numAntenas > 1 then 
		     Punto.K.indRb =: {Maxim Punto.K.lSignTot}
		  end
 	       end
 	    end

	    {System.show '489'}
	   
 	    %%Nivel de interferencia por Punto    	    
 	    %Se calcula como la sumatoria de senales co-canal que inciden en un punto
 	    for K in 1..M do	       
 	       thread
		  if {Bool.'and' (Param.puntos.K.numAntenas > 1)
		      {Bool.'not' ({FD.reflect.max Punto.K.lSignTot.(Punto.K.indRb)} < UmbCob)}
		     }		     		     
		  then		      
		     {FD_PROP.interference
		      Punto.K.lSignTot.(Punto.K.indRb)
		      Punto.K.lSignTot
		      {Misc.coCanal			
		        {Misc.getAntByPoint K (Punto.K.indRb) RecRbsByPoints Param} %%Radiobase deseada
		        {Misc.getAntByPoint K (Punto.K.indRb) RecAntByPoints Param} %%Antena deseada 
		        RecRbsByPoints                                              %%Radiobases por Punto
		        RecAntByPoints 			                            %%Antenas correspondientes de cada Radiobase
		        Result
		        K
		        Param
		      }
		      FlgReachInterf.K
		      Param.offset
		      Param.umbInterf
		      K
 		     }
 		  else
   		      %Si solo tiene una antena siempre cumple el objetivo
   		      %de la interferencia
 		     FlgReachInterf.K =: 1
 		     skip
 		  end		  
  		end
	    end
	    {System.show '517'}
 	    %% Determina cumplimiento de objetivo interferencia
	    {FD.sum FlgReachInterf '=:' ObjetivoInterfAux}
 	    Objetivo.1.dom * M =<:   ObjetivoInterfAux * 100 
 	    (Objetivo.1.dom + 1) * M  >:ObjetivoInterfAux*100
%  	    {System.show '529'}
  %=========================================

	    
	    
  	    %%Determinaci'on de la Capacidad del sistema
  	    {FD.sumAC Param.pobl Cob '=:' Cap}
	    {System.show '569'}	    

	    thread
	       for K in 1..M do		  
		  {Value.wait CobAux.K}
	       end
	       {FD_PROP.activeSet
		{ExtractForHandoff CobAux Param.forHandoff}
		Objetivo.2.dom
		Param.minSol
		Param.maxSol
		
		{Width Param.forHandoff}
	       }
	    end
	    {System.show '554'}
	    %%Este propagador calcula el objetivo de probabilidad de bloqueo
	    thread	       
	       for K in 1..M do
		  for I in 1..Param.numAntByPnt.K do
		     {Value.wait {Misc.getAntByPoint K I RecAntByPoints Param}}
		     
		  end
	       end
	       
	       %{System.show 'Ejecuta propagador...'#Objetivo.4.dom}
	       {FD_PROP.bloqueo
		Param.pobl
		RecRbsByPoints
		{IsIncident RecAntByPoints RecRbsByPoints Param.numAntByPnt RbCobPto}
		Param.numAntByPnt
		Param.canales
		Param.intTrafEnt
		Param.intTrafDec
		Objetivo.4.dom
		Param.umbTraf
		{Float.toInt Param.maxTraficoAnt}
		{Float.toInt (Param.maxTraficoAnt * 100.0)} -
		({Float.toInt Param.maxTraficoAnt}*100)
		CobAux
	       }	        
	    end	    

	    {System.show '576'#TotalPob}
	    %Calcula el porcetaje de población atendida
	    if TotalPob > 0 then
	       Objetivo.3.dom * TotalPob =<:Cap*100
	       (Objetivo.3.dom + 1) * TotalPob >:Cap*100
	    else
	       Objetivo.3.dom =: 100
	    end

	    {System.show '581'}
	    %Función objetivo total	   
%	    {FD.sumAC Pesos  rc(Objetivo.1.dom Objetivo.2.dom Objetivo.3.dom Objetivo.4.dom) '=:' ObjTotal}

	    %{System.show objTot#ObjTotal}
	   % {System.show objs#rc(Objetivo.1.dom Objetivo.2.dom Objetivo.3.dom Objetivo.4.dom )}
	    %%Para probar solo con el active set

	    local
	       Rec
	       Equivs = rc(3 2 4 1)
	       fun {ObjsActives Index ListaPesos ListaObjs}
		  if Index < 1 then
		     rc(1:ListaPesos 2:ListaObjs) 
		  elseif Param.pesos.(Equivs.Index).active == 1 then
		     {ObjsActives (Index - 1)
		      Param.pesos.(Equivs.Index).weigth|ListaPesos 
		      Objetivo.Index.dom|ListaObjs
		     }
		  else
		     {ObjsActives (Index - 1)
		      ListaPesos 
		      ListaObjs
		     }
		  end
	       end
	    in
	       Rec={ObjsActives 4 nil nil}
	       {System.show 'tamano '#{Length Rec.1}}
	       {FD.sumAC {List.toTuple 'w' Rec.1} {List.toTuple 'o' Rec.2}  '=:' ObjTotal}
	    end	    
	    
	    {System.show '587'}
	    ObjTotal >: LowerBound

	    {System.show 'Antes de la distribucionm Param '#Param.maxTrafico}
	    %%La estrategia de distribución se encarga de manejar lo de los pesos	   
	    {Strategies.(Param.strategy) rec(conf:Result objTotal:ObjTotal
					     cobAux:CobAux pesos:Pesos
					     puntos:Punto
					     param:Param
					     offset:Param.offset
					     recAnts:RecAntByPoints
					     recRbs:RecRbsByPoints
					     cob:Cob
					     pobTotal:TotalPob
					     radioBases: Param.radioBases
					     useRelax:Param.useRelax
					     objetivos:Objetivo
					     
					     pobRb : PobRB				     
					     minIntTrafico:{MinIntTraffic
							    Param.intTrafEnt
							    Param.intTrafDec
							   }
					     maxTrafico:Param.maxTrafico
					     flgReachInterf : FlgReachInterf
					     rcRbData: RcRbData
					     gain:Gain.gain
					     forHandoff:{ExtractForHandoff
							 CobAux
							 Param.forHandoff}					     
					    )
	    }
	 end
      end   
   end




   fun {SearchOne Param Gain}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PARÁMETROS DE ENTRADA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      local

%%Esta funcion devuelve una tupla en la que en cada posicion i se tiene
	 %% signals: record con las senales pertenecientes a la RB i
	 %% distTypes : tipos de distancia pertenecientes a la RB i
	 %% azimuths:  azimuths pertenecientes a la RB i
	 %% tilts : tilts pertenecientes a la RB i
	 %% todos estos registros son paralelos, es decir la informacion en posiciones iguales
	 %% esta correlacionada
	 fun {GroupData Punto Param RcRbsByPnt}
	    %{System.show 'agrupando datos ..'}
	    RcResult = {MakeTuple 'Rb' Param.numRB}
	    RcResultDef = {MakeTuple 'Rb' Param.numRB}
	    for I in 1..Param.numRB do
	       RcResult.I = rc(signals:_ distTypes:_ azimuths:_ tilts:_)
	       RcResultDef.I = rc(signals:_ distTypes:_ azimuths:_ tilts:_)
	       RcResult.I.signals   = {Cell.new nil}
	       RcResult.I.distTypes = {Cell.new nil}
	       RcResult.I.azimuths  = {Cell.new nil}
	       RcResult.I.tilts     = {Cell.new nil}
	    end
	    proc {ClasifyData Index Value1 RcResult}
	     %  {System.show 'clasificando datos ..'#(Index)}
	       {Cell.assign RcResult.Index.signals
		(Value1.signal|{Cell.access RcResult.Index.signals })
	       }
	       {Cell.assign RcResult.Index.distTypes
		(Value1.distType| {Cell.access RcResult.Index.distTypes})
	       }
	       
	       {Cell.assign RcResult.Index.azimuths
		(Value1.azimuth|{Cell.access RcResult.Index.azimuths} )
	       }
		  
	       {Cell.assign RcResult.Index.tilts
		( Value1.tilt | {Cell.access RcResult.Index.tilts} )
	       }
	       
	    end
	 in
	    for I in 1..{Width Punto} do
	       for J in 1..(Param.numAntByPnt.I) do
		%  {System.show 'VAmos enla RB '#I}
		  {ClasifyData { Misc.getAntByPoint I J RcRbsByPnt Param }
		   rc(signal:Punto.I.lSign.J
		      distType: ((Param.puntos.I.tipoDist.J)-1)
		      azimuth:Punto.I.lAz.J
		      tilt: Punto.I.lEle.J)
		   RcResult
		  }
	       end
	    end

	    for I in 1..(Param.numRB) do
	       RcResultDef.I.signals = {List.toTuple 's' {Cell.access RcResult.I.signals}}
	       RcResultDef.I.distTypes= {List.toTuple 'd' {Cell.access RcResult.I.distTypes}}
	       RcResultDef.I.azimuths={List.toTuple 'a' {Cell.access RcResult.I.azimuths}}
	       RcResultDef.I.tilts={List.toTuple 't' {Cell.access RcResult.I.tilts}}
	    end
	    RcResultDef
	 end
	 
	 fun {IsIncident RcAntByPoints RcRbsByPoints NumAntByPnt RbCobPto}
	    RcResult ={MakeTuple 'inc' {Width RcAntByPoints }}		     
	 in
	    for I in 1..{Width Param.numAntByPnt}do
	       for J in 1..(NumAntByPnt.I)do
		  if (RbCobPto.({Misc.getAntByPoint I J RcRbsByPoints Param}).I) == 1 then
		     RcResult.(((Param.puntos.I.posIniAnts)+J)) =
		     {Misc.getAntByPoint I J RcAntByPoints Param}
		  else
		     RcResult.(((Param.puntos.I.posIniAnts)+J)) = 0
		  end			      
	       end
	    end
	    RcResult
	 end
	 
	 fun {ExtractForHandoff Variable Indices}
	    RcResult = {MakeTuple 'res' {Width Indices}}
	 in
	    for I in 1..{Width Indices}do
	       RcResult.I = Variable.(Indices.I)
	    end
	    RcResult
	 end

	 fun {SumRec Rec Puntos MaxDistance}
	    fun {ExistLesserDist I Ldist Max}
	       if I >{Width Ldist }then
		  false
	       elseif Ldist.I =< Max then
		  true
	       else
		  {ExistLesserDist (I+1) Ldist Max}
	       end
	    end
	    fun {SumRecIte Rec I Value}
	       if I > {Width Rec} then
		  Value
	       elseif {ExistLesserDist 1 Puntos.I.distancia MaxDistance} then 
		  {SumRecIte Rec (I+1) (Value+Rec.I)}
	       else
		   {SumRecIte Rec (I+1) Value}
	       end
	    end
	 in
	    {SumRecIte Rec 1 0}
	 end	 
	 
	 fun{IsIn RcList Elem}
	    {FindIte RcList Elem {Width RcList} 1}   
	 end
	 fun{FindIte RcList Elem N I}
	    if (N+1) == I then
	       false
	    else if RcList.I==Elem then
		    true
		 else
		    {FindIte RcList Elem N (I+1)}
		 end
	    end
	 end
	 
	 fun {MaxIt Rec I Max N}
	    {Value.wait Rec.I}
	    if I== N then
	       Max
	    else if Rec.I > Rec.Max then	   
		    {MaxIt Rec (I+1) I N}
		 else
		    {MaxIt Rec (I+1) Max N} 
		 end      
	    end
	 end
	 
	 fun{Maxim Lst}
	    {MaxIt Lst 1 {Width Lst} {Width Lst}}
	 end
	 
	%  fun{FactList N}
% 	    {FactListIt N 1 1|nil 1}
% 	 end
% 	 fun{FactListIt N I L Ultimo}
% 	    if I==(N+1) then
% 	       L
% 	    else
% 	       {FactListIt N (I+1) {Append L (Ultimo*I|nil)} (Ultimo*I)}
% 	    end
% 	 end

	 % fun{GenRc N }
% 	    R
% 	 in
% 	    R= {MakeTuple 'rc' N}
% 	    for I in 1..N do
% 	       R.I = 1 %{Int.'mod' I 2}
% 	    end
% 	    R
% 	 end

	 %%Recibe una Radiobase una lista de radiobases incidentes en un punto, la lista paralela con
	 %%la antena correspondiente a cada radiobase, la radiobase y antena que ofrecen el mejor enlace,
	 %%y una tupla con toda la información de las radiobases, a partir de estos datos se determina la
	 %%lista de cocanalidad correspondiente a la radiobase y antena del mejor enlace.
	 %%K índice del punto a considerar
	
	 fun {CoberturaPunto K RbCobPto}
	    ResCobPTo = {MakeTuple 'flgRBPto' N}
	 in
	    for I in 1..N do
	       ResCobPTo.I = RbCobPto.I.K 
	    end
	    ResCobPTo
	 end
	 

	 N        = Param.numRB     %Número de estaciones RadioBase
	 M        = Param.numPtos   %Número de puntos en los que se harán mediciones de Señal
	 
	 MinPot   = Param.potMin    %Potencia mínima de las antenas
	 MaxPot   = Param.potMax    %Potencia máxima de las antenas
	 MinTilt  = Param.minTilt   %Tilt mínimo de las antenas 
	 MaxTilt  = Param.maxTilt   %Tilt máximo de las antenas
	 MinAzim  = 0               %Azimut mínimo de las antenas
	 MaxAzim  = 355                %Azimut máximo de las antenas
	 UmbCob   = Param.umbSign - Param.offset   %Umbral a partir del cual se puede definir si un punto tiene o no cobertura	 	 
	 SalAzim  = Param.salAzim   %Salto entre valores de Azimuth

	 %%Salto entre valores de tilt
	 SalTilt  = {Float.toInt
		     {Float.ceil
		      ({Int.toFloat (Param.maxTilt - Param.minTilt)}/20.0)
		     }
		    }
	 %%Salto entre valores de potencia
	 SalPot   = {Float.toInt
		     {Float.ceil
		      ({Int.toFloat (Param.potMax - Param.potMin)}/20.0)
		     }
		    }



	 FD_PROP_1 = {Module.link '../propagadores/tilt.so{native}'|nil }
	 FD_PROP_2 = {Module.link '../propagadores/azim.so{native}'|nil }
	 FD_PROP_3 = {Module.link '../propagadores/bloqueo.so{native}'|nil }
	 FD_PROP_4 = {Module.link '../propagadores/activeSetProp.so{native}'|nil }
	 FD_PROP_5 = {Module.link '../propagadores/interference.so{native}'|nil }
	 FD_PROP_6 = {Module.link '../propagadores/matElemProp.so{native}'|nil }
	 
	 
	 
	 FD_PROP = fd( tilt:{Nth FD_PROP_1 1}.tilt
		       azim:{Nth FD_PROP_2 1}.azim
		       bloqueo:{Nth FD_PROP_3 1}.bloqueo
		       activeSet:{Nth FD_PROP_4 1}.activeSet
		       interference:{Nth FD_PROP_5 1}.interference
		       matElem:{Nth FD_PROP_6 1}.matElem
		     )

	 
	 %MaxCanales = Canal.({Maxim Canal})	 
	 %LFactChannels={FactList MaxCanales}

	 %%Deben leerse desde el archivo generado en java
	 Pesos = pesos( pesoInterf  : Param.pesos.3
			pesoActSet  : Param.pesos.2
			pesoPobAten : Param.pesos.4
			pesoTrafico : Param.pesos.1
		      )	 
	 
	 
	 %%Población Total
	 TotalPob = {SumRec Param.pobl Param.puntos Param.maxDistance} 	 
	 
	 %%Se debe borrar y reemplazar
	 XRb  =  {MakeTuple 'k' M} 
	 XPto =  {MakeTuple 'k' M} 
	 YRb  =  {MakeTuple 'k' M} 
	 YPto =  {MakeTuple 'k' M}
	 
	 for K in 1..M do
	    XRb.K  = {MakeTuple 'k' Param.puntos.K.numAntenas}
	    XPto.K = {MakeTuple 'k' Param.puntos.K.numAntenas}
	    YRb.K  = {MakeTuple 'k' Param.puntos.K.numAntenas}
	    YPto.K ={MakeTuple 'k' Param.puntos.K.numAntenas}
	    for L in 1..Param.puntos.K.numAntenas do		  
	       XRb.K.L  = Param.radioBases.(Param.puntos.K.lRbs.L).x
	       XPto.K.L = Param.puntos.K.x
	       YRb.K.L  = Param.radioBases.(Param.puntos.K.lRbs.L).y
	       YPto.K.L = Param.puntos.K.y
	    end
	 end

	 %%Devuelve el indice de radiobase o antena dependiendo del Registro que se reciba
	 %%Correspondiente al indice de antena dado		 	 
      in
	 proc {$ Root}
	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
	    Punto                      %Alamacenara datos de los puntos de medición
	    DomAzim                    %Dominio para el azimut de todas las antenas del sistema  
	    DomTilt                    %Dominio para el tilt de todas las antenas del sistema 
	    DomPot                     %Dominio para la potencia de todas las antenas del sistema 
	    Result                     %Almacenará la configuración final de la red
	    CobAux                     %Cantidad de antenas que cubren un punto en un momento determinado
	    RbCobPto                   %Indica que una radiobase cubre un punto
	    PobRB                      %Población correspondiente a una radiobase
	    
	    Cob
	    Cap	    
	    
	    %%Flag que indica si un punto cumple la restricción de mínimo y máximo de elementos en el
	    %%active set	     

	    %%Flag que indica si un punto cumple con la restricción de la interferencia
	    FlgReachInterf
	    %%Flag que indica si una radiobase cumple la restricción de tráfico 
	    
	    %%Tupla con los valores de los diferentes objetivos
	    Objetivo

	    %$La funcion objetivo total
	    ObjTotal



	    RecAntByPoints = {MakeTuple 'antPnt' Param.totAntByPoints}
	    RecRbsByPoints = {MakeTuple 'rbsPnt' Param.totAntByPoints}
	    IndexAntByPnt={Cell.new 1}
	    ObjetivoInterfAux
	    RcRbData
	 in
	    {System.show '204'}
	    ObjetivoInterfAux ={FD.int 0#FD.sup}
	    Root = result(
		      conf:Result
		      puntos:Punto		      		      
		      pobRb:PobRB
		      cap:Cap
		      cob:Cob
		      obj:Objetivo
		      aObjetivo: ObjTotal		      		      
		      flgInterf:FlgReachInterf
		      )	 	 	    


	    %%Debe quedar entre 0#100
	    Objetivo={MakeTuple 'obj' 4}
	    for I in 1..4 do
	       Objetivo.I = var(dom:{FD.int 0#100 } type:5 ind:I)
	    end
            
	    FlgReachInterf    = {FD.tuple int M 0#1}
            
	    

	    %%Probabilidad de bloqueo por radiobase
	    	    	    	    
	    ObjTotal          = {FD.int 0#10000}
	    
	    %%for I in 1..(MaxCanales+1) do	       
	    %%   Ldom.I =: {Nth LFactChannels I}
	    %%end

	    RbCobPto= {MakeTuple 'rbCobPto' N}
	    for I in 1..N do
	       RbCobPto.I={FD.tuple rbPto M 0#1}
	    end
	    
	    PobRB    = {MakeTuple 'pobRb' N}
	   
	    for I in 1..N do
	       PobRB.I={FD.int 0#FD.sup}	       
	    end

	    
	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ESTRUCTURAS DE DATOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 
	    %%Define la variable que va a almacenar el resultado
	    {MakeTuple solucion N Result}
	    for I in 1..N do
	       Result.I =
	       radioBase(
		  ind:_                      %Identificador de la radio-base
		  1:ant(az:_ tilt:_ pot:_ rang:_)  %Antena número 1 
		  2:ant(az:_ tilt:_ pot:_ rang:_)  %Antena número 2
		  3:ant(az:_ tilt:_ pot:_ rang:_)  %Antena número 3
		  )	       
	    end
	    
	    
      %Define los puntos donde se van a tomar mediciones
	    {MakeTuple punto M Punto}	
	    for K in 1..M do
	       Punto.K =
	       punto(
		  ind:_     %Identificador del punto		 
		  lSign:_    %Tupla con el nivel de señal que le da la antena en lAnt		  
		  lAz:_     %Azimut con que incide la señal en el punto
		  lEle:_    %Elevación con que incide la señal en el punto
		  indRb:_   %Identificador de la radiobase que le brinda el nivel de señal más alto		  
		  lSignTot:_
		  )
	    end
	    
	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DOMINIOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
	    DomAzim = {Loop.forThread MinAzim (MaxAzim -1 ) SalAzim
		       fun {$ Is I}
			  I|Is
		       end
		       Param.listAddAzim
		      }
	    DomTilt = {Loop.forThread MinTilt
		       (MaxTilt-1)
		       SalTilt
		       fun {$ Is I}
			  I|Is
		       end		       
		       Param.listAddTilt
		      }
	    DomPot  = {Loop.forThread MinPot  (MaxPot-1)  SalPot
		       fun
			  {$ Is I} I|Is
		       end
		       Param.listAddPot
		      }

	    
	    for  I in 1..N do
	       Result.I.ind    = I
	       
	       Result.I.1.az   = var(dom:{FD.int DomAzim} type:2)
	       Result.I.2.az   = var(dom:{FD.int DomAzim} type:2)
	       Result.I.3.az   = var(dom:{FD.int DomAzim} type:2)	   
	       	       
	       Result.I.1.tilt = var(dom:{FD.int DomTilt} type:1)
	       Result.I.2.tilt = var(dom:{FD.int DomTilt} type:1)
	       Result.I.3.tilt = var(dom:{FD.int DomTilt} type:1)
	    
	       Result.I.1.pot  = var(dom:{FD.int DomPot} type:3)
	       Result.I.2.pot  = var(dom:{FD.int DomPot} type:3)
	       Result.I.3.pot  = var(dom:{FD.int DomPot} type:3)

	       Result.I.1.rang  =var(dom:{FD.int 1#3} type:4)
	       Result.I.2.rang  =var(dom:{FD.int 1#3} type:4)
	       Result.I.3.rang  =var(dom:{FD.int 1#3} type:4)	       
	    end
	    
	    for K in  1..M do
%		{System.show 'k'#K#'m'#M}
		Punto.K.ind     =  Param.puntos.K.ind
		%%Quitar		
		for I in 1..Param.puntos.K.numAntenas do
		   %%Lista con la informaci'on de antena y radiobase por punto
		   %%Para tener control de la sectorizaci'on

		   RecAntByPoints.({Cell.access IndexAntByPnt}) = {FD.int 1#3}
		   RecRbsByPoints.({Cell.access IndexAntByPnt}) =  Param.puntos.K.lRbs.I
		   
		   {Cell.assign IndexAntByPnt ({Cell.access IndexAntByPnt}+1)}
		   %{System.show index#({Cell.access IndexAntByPnt})}
		end	       	
		Punto.K.lSign   = {FD.tuple sign Param.puntos.K.numAntenas 0#FD.sup}
		Punto.K.lSignTot= {FD.tuple signTot Param.puntos.K.numAntenas 0#FD.sup}
		Punto.K.lAz     = {FD.tuple azi Param.puntos.K.numAntenas 0#24}
		Punto.K.lEle    = {FD.tuple ele Param.puntos.K.numAntenas 0#18}	  
		Punto.K.indRb   = {FD.int 1#N}
	    end	 
	    %{System.show 'Termina el ciclo'}
	    %Root.lAnts= {Cell.access ListAntsByPoint}
	    %{Browser.browse a#RecAntByPoints}
	    CobAux = {FD.tuple cob M 0#FD.sup }
	    Cob    = {FD.tuple cob M 0#1}
	    Cap    = {FD.int 0#FD.sup}
	    %{System.show 'Inicialización'}

	    %%Se Agrupan los datos por Radiobase
	    RcRbData = {GroupData Punto Param RecRbsByPoints}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%RESTRICCIONES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
         %Dos antenas de una radiobase no pueden tener el mismo rango
	    for I in 1..N do
	       {FD.distinct t(1:Result.I.1.rang.dom 2:Result.I.2.rang.dom 3:Result.I.3.rang.dom) }
	    end
	    {System.show 'Linea 370'}
	    
 	 %La diferencia entre azimut es 120
 	    for I in 1..N do 	       
 	       Result.I.2.az.dom =: Result.I.1.az.dom+120
 	       Result.I.3.az.dom =: Result.I.2.az.dom+120
       {System.show 'Linea 957'}
 	       %%Esta es la configuraci'on actual de la red
	       	 %{System.show 'azimuth entrada'#Param.radioBases.I.antenas.1.azimuth}      
	       Result.I.1.az.dom=:Param.radioBases.I.antenas.1.azimuth
       {System.show 'Linea 961'}
	      
  	       %%se va a dar una solucion tilt
	       
  	       Result.I.1.tilt.dom =:Param.radioBases.I.antenas.1.tilt
     	       Result.I.2.tilt.dom =:Param.radioBases.I.antenas.2.tilt
    	       Result.I.3.tilt.dom =:Param.radioBases.I.antenas.3.tilt
       {System.show 'Linea 968'}
%    	       %%Potencia
   	       Result.I.1.pot.dom =: Param.radioBases.I.antenas.1.pot
   	       Result.I.2.pot.dom =: Param.radioBases.I.antenas.2.pot
   	       Result.I.3.pot.dom =: Param.radioBases.I.antenas.3.pot
{System.show 'Linea 973'}
	       %%Se debe corregir para que funcione correctamente
	       Result.I.1.rang.dom =:1
	       Result.I.2.rang.dom =:2
	       Result.I.3.rang.dom =:3
{System.show 'Linea 229'}	       
 	    end

	    %%==========================================
	    %% Determina nivel de cumplimiento del objetivo del active set 
	    %%==========Calcula nivel de cumplimiento del objetivo del active set======= 	   	   	    	    

	    {System.show '382'}
	    
	    %%Calcula el azimuth y tilt relativos 
	    for K in 1..M do	    
	       for L in 1..Param.puntos.K.numAntenas do
		 % {System.show 'l'#L#'k'#K}		  		 
		  %{System.show 'es' }
		  {
		   FD_PROP.azim
		   Punto.K.lAz.L
		   ({Misc.getAntByPoint K L RecAntByPoints Param})
		   Result.({Misc.getAntByPoint K L RecRbsByPoints Param}).1.az.dom   		         
		   XRb.K.L
		   XPto.K.L 
		   YRb.K.L  
   		   YPto.K.L 
		   5
		  }
	       end
	    end
	    {System.show '402'}
	    for K in 1..M do	    
	       for L in 1..Param.puntos.K.numAntenas do
		  thread
		     {		      
		      FD_PROP.tilt
		      Result.({Misc.getAntByPoint  K L RecRbsByPoints Param}).({Misc.getAntByPoint K L RecAntByPoints Param}).tilt.dom
		      Punto.K.lEle.L
		      2%Altura de la antena
		      Param.radioBases.({Misc.getAntByPoint K L RecRbsByPoints Param}).hrb
		      {Float.toInt Param.puntos.K.distancia.L}		      
		      Param.salTilt
		      K
		     } 
		     %{System.show 'fin l'#L#'k'#K}
		  end		  
 	       end	       
 	    end	    	    
	    
	    {System.show '420'#M}

 	    for I in 1..N do
 	      {FD_PROP.matElem
 	       RcRbData.I.signals %{AplanaSignals Punto RecRbsByPoints}
 	       RcRbData.I.tilts%{AplanaTilts Punto RecRbsByPoints}
 	       RcRbData.I.azimuths%{AplanaAzimuths Punto RecRbsByPoints}
 	       RcRbData.I.distTypes%{AplanaTipoDist Punto RecRbsByPoints}
 	       Gain.gain
 	       Gain.dist
 	       Gain.tilts
 	       Gain.azims
 	      }
 	    end
	    
	    for K in 1..M do
	       for L in 1..Param.puntos.K.numAntenas do
		 %% {System.show 'l'#L#'K'#K#'M'#M}
		 %  {FD_PROP.matElem		   
% 		   Punto.K.lEle.L
% 		   Punto.K.lAz.L
% 		   Punto.K.lSign.L
%    		   (Param.puntos.K.tipoDist.L-1)
% 		   Gain.gain
%    		   Gain.dist
% 		   Gain.tilts
% 		   Gain.azims
% 		  }
		  
		  thread
		     {FD.plus Result.({Misc.getAntByPoint K L RecRbsByPoints Param}).({Misc.getAntByPoint K L RecAntByPoints Param}).pot.dom
		      Punto.K.lSign.L
		      Punto.K.lSignTot.L
		     }
		  end		  
	       end
	    end
	    
	    {System.show '527'}
	    
	    %Coloca el flag de relación de cobertura entre punto y radio base

	    for I in 1..N do
	       for K in 1..M do		
		  if {IsIn Param.puntos.K.lRbs I} then
		     for L in 1..Param.puntos.K.numAntenas do
			if {Bool.'and' (Param.puntos.K.lRbs.L == I)
			    ({Bool.'not' {Value.isDet RbCobPto.I.K}})} then
			   if Param.puntos.K.distancia.L =< Param.minDistance then
			      RbCobPto.I.K =:1			      
			   elseif Param.puntos.K.distancia.L > Param.maxDistance then
			      RbCobPto.I.K =:0
			   else
			      (FD.sup*RbCobPto.I.K)+UmbCob >=: Punto.K.lSignTot.L
			      %%Para hacerlo 1	       
			      (FD.sup*(1-RbCobPto.I.K))+Punto.K.lSignTot.L >:UmbCob
			      %%Para hacerlo 0
			   end
 			end						
 		     end
 		  else
 		     RbCobPto.I.K=:0
		     skip
 		  end		  
 	       end
	     end

	    
	     {System.show '461'}
	    
	    
 	    %%=========================================================================
 	    for K in 1..M do
	       %%{System.show cobertura#CobAux.K}
 	       {FD.sum {CoberturaPunto K RbCobPto} '>=:' Cob.K} %Para hacerlo 0
 	       {FD.sum {CoberturaPunto K RbCobPto} '=:' CobAux.K} 
	       CobAux.K =<: Cob.K*N
	       CobAux.K =<: Param.puntos.K.numAntenas
	       %%Para hacerlo 1	       
 	    end
	    {System.show '472'}
 	    %%Determina la población que quedo dentro de la cobertura de la radiobase
	    	    
 	    for I in 1..N do	    	   	    
 	       {FD.sumAC Param.pobl  RbCobPto.I '=:'  PobRB.I }	       	    
 	    end

	    {System.show '481'}
 	    %%Se identifica la Radiobase que provee el mejor enlace es el indice de la radiobase y antena que proporciona mayor cobertura
 	    thread	       
 	       for K in 1..M do		  
 		  Punto.K.indRb =: {Maxim Punto.K.lSignTot}	       
 	       end
 	    end

	    {System.show '489'}
	   
 	    %%Nivel de interferencia por Punto    	    
 	    %Se calcula como la sumatoria de senales co-canal que inciden en un punto
 	    for K in 1..M do	       
	       thread
		  
		  if {Bool.'and' (Param.puntos.K.numAntenas > 1)
		     {Bool.'not' ({FD.reflect.max Punto.K.lSignTot.(Punto.K.indRb)} < UmbCob)}
		     }  then		      
 		     {FD_PROP.interference Punto.K.lSignTot.(Punto.K.indRb) Punto.K.lSignTot

		      {Misc.coCanal			
 		       {Misc.getAntByPoint K (Punto.K.indRb) RecRbsByPoints Param} %%Radiobase deseada
 		       {Misc.getAntByPoint K (Punto.K.indRb) RecAntByPoints Param} %%Antena deseada 
 		       RecRbsByPoints                            %%Radiobases por Punto
 		       RecAntByPoints 			          %%Antenas correspondientes de cada Radiobase
 		       Result
 		       K
		       Param
		      }
 		      FlgReachInterf.K  Param.offset Param.umbInterf K
 		     }
 		  else
   		      %Si solo tiene una antena siempre cumple el objetivo
   		      %de la interferencia
 		     FlgReachInterf.K =: 1
 		     skip
		  end		  
  		end
	    end
	    {System.show '517'}
 	    %% Determina cumplimiento de objetivo interferencia
	    {FD.sum FlgReachInterf '=:' ObjetivoInterfAux}
 	    Objetivo.1.dom * M =<:   ObjetivoInterfAux * 100 
 	    (Objetivo.1.dom + 1) * M  >:ObjetivoInterfAux*100
%  	    {System.show '529'}
  %=========================================

	    
	    
  	    %%Determinaci'on de la Capacidad del sistema
  	    {FD.sumAC Param.pobl Cob '=:' Cap}

	    {System.show '569'}	    

	    thread
	       for K in 1..M do		  
		  {Value.wait CobAux.K}
	       end
	       {FD_PROP.activeSet
		{ExtractForHandoff CobAux Param.forHandoff}
		Objetivo.2.dom
		Param.minSol
 		Param.maxSol
		{Width Param.forHandoff}
	       }
	    end
	    {System.show '554'}
	    %Este propagador calcula el objetivo de probabilidad de bloqueo
	    thread	       
	       for K in 1..M do
		  for I in 1..Param.numAntByPnt.K do
		     {Value.wait {Misc.getAntByPoint K I RecAntByPoints Param}}
		     %{System.show 'Listo ...'#{Misc.getAntByPoint K I RecAntByPoints Param}}
		  end
	       end
	       %{System.show 'Ejecuta propagador...'#Objetivo.4.dom}
	       {FD_PROP.bloqueo
		Param.pobl
		RecRbsByPoints
		{IsIncident RecAntByPoints RecRbsByPoints Param.numAntByPnt RbCobPto}
		Param.numAntByPnt
		Param.canales
		Param.intTrafEnt
		Param.intTrafDec
		Objetivo.4.dom
		Param.umbTraf
		{Float.toInt Param.maxTraficoAnt}
		{Float.toInt (Param.maxTraficoAnt * 100.0)} - ({Float.toInt Param.maxTraficoAnt}*100)
		 CobAux
	       }	       
	    end

	    %Objetivo.4.dom=:100

	    {System.show '576'}
	    %Calcula el porcetaje de población atendida
	    if TotalPob > 0 then
	       Objetivo.3.dom * TotalPob =<:Cap*100
	       (Objetivo.3.dom + 1) * TotalPob >:Cap*100
	    else
	       Objetivo.3.dom = 100
	    end

	    {System.show '581'}
	    %Función objetivo total	   
%	    {FD.sumAC Pesos  rc(Objetivo.1.dom Objetivo.2.dom Objetivo.3.dom Objetivo.4.dom) '=:' ObjTotal}

	    %{System.show objTot#ObjTotal}
	   % {System.show objs#rc(Objetivo.1.dom Objetivo.2.dom Objetivo.3.dom Objetivo.4.dom )}
	    %%Para probar solo con el active set
	    local
	       Rec
	       Equivs = rc(3 2 4 1)
	       fun {ObjsActives Index ListaPesos ListaObjs}
		  if Index < 1 then
		     rc(1:ListaPesos 2:ListaObjs) 
		  elseif Param.pesos.(Equivs.Index).active == 1 then
		     {ObjsActives (Index - 1)
		      Param.pesos.(Equivs.Index).weigth|ListaPesos 
		      Objetivo.Index.dom|ListaObjs
		     }
		  else
		     {ObjsActives (Index - 1)
		      ListaPesos 
		      ListaObjs
		     }
		  end
	       end
	    in
	       Rec={ObjsActives 4 nil nil}
	       {System.show 'tamano '#{Length Rec.1}}
	       {FD.sumAC {List.toTuple 'w' Rec.1} {List.toTuple 'o' Rec.2}  '=:' ObjTotal}
	    end
	    {System.show '1204'}
	    %%La estrategia de distribución se encarga de manejar lo de los pesos	   
	    {DistOztnet.strategyForOne rec(
					  conf:Result
					  objTotal:ObjTotal
					  cobAux:CobAux
					  pesos:Pesos
					  puntos:Punto
					  param:Param
					  offset:Param.offset
					  recAnts:RecAntByPoints
					  recRbs:RecRbsByPoints
					  cob:Cob
					  pobTotal:TotalPob
					  radioBases:Param.radioBases
					  )
	    }
	 end
      end   
   end
   end