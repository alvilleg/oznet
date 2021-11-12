functor   
import
%   Browser
   FD
   Module
   System

export
   resetNetwork:ResetNetwork
define
      
%declare             
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                     FUNCIÓN PRINCIPAL  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {ResetNetwork Param Gain}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PARÁMETROS DE ENTRADA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      local		 
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
	 
	 fun{FactList N}
	    {FactListIt N 1 1|nil 1}
	 end
	 fun{FactListIt N I L Ultimo}
	    if I==(N+1) then
	       L
	    else
	       {FactListIt N (I+1) {Append L (Ultimo*I|nil)} (Ultimo*I)}
	    end
	 end

	 fun{GenRc N }
	    R
	 in
	    R= {MakeTuple 'rc' N}
	    for I in 1..N do
	       R.I = 1 %{Int.'mod' I 2}
	    end
	    R
	 end

	 %%Recibe una Radiobase una lista de radiobases incidentes en un punto, la lista paralela con
	 %%la antena correspondiente a cada radiobase, la radiobase y antena que ofrecen el mejor enlace,
	 %%y una tupla con toda la información de las radiobases, a partir de estos datos se determina la
	 %%lista de cocanalidad correspondiente a la radiobase y antena del mejor enlace. 
	 fun {CoCanal LRbs LAnts Rb Ant Rbs}
	    Rc
	 in

	    {Value.wait Rbs.Rb.rang.1}
	    {Value.wait Rbs.Rb.rang.2}
	    {Value.wait Rbs.Rb.rang.3}

	    Rc = {MakeTuple 'coc' {Width LRbs}}

	    for I in 1.. {Width LRbs} do	       
	       Rc.I = Param.cocanal.(3*(Rb-1)+Rbs.Rb.rang.Ant).(3*(LRbs.I - 1)+(Rbs.(LRbs.I).rang.(LAnts.I)))
	    end
	    Rc
	 end

	 fun {CoberturaPunto K RbCobPto}
	    ResCobPTo = {MakeTuple 'flgRBPto' N}
	 in
	    for I in 1..N do
	       ResCobPTo.I = RbCobPto.I.K 
	    end
	    ResCobPTo
	 end

	 fun {Linealiza LSin}
	    Res = {FD.tuple lin {Width LSin} 0#FD.sup}	    
	 in
	    for I in 1..{Width LSin} do
	       {Value.wait LSin.I}
	       Res.I =: 10%{Float.toInt
			 %{Float.log {Number.pow 10.0
				%     (({Int.toFloat LSin.I})/10.0)
				 %   }
			 %}
			%}
	    end
	    Res
	 end
	 

	 N        = Param.numRB     %Número de estaciones RadioBase
	 M        = Param.numPtos   %Número de puntos en los que se harán mediciones de Señal
	 DistTipo = Param.distTipo  %Tipo de distancia entre la i-ésima estación RadioBase y el k-ésimo punto de medición.
	 Pobl     = Param.pobl      %Población que demanda servicio en un punto	 
	 Canal    = Param.canales   %Cantidad de canales asignados a una radiobase	 	 
	 MinPot   = Param.potMin    %Potencia mínima de las antenas
	 MaxPot   = Param.potMax    %Potencia máxima de las antenas
	 MinTilt  = Param.minTilt   %Tilt mínimo de las antenas 
	 MaxTilt  = Param.maxTilt   %Tilt máximo de las antenas
	 MinAzim  = 0               %Azimut mínimo de las antenas
	 MaxAzim  = 355                %Azimut máximo de las antenas
	 UmbCob   = Param.umbSign   %Umbral a partir del cual se puede definir si un punto tiene o no cobertura	 	 
	 SalAzim  = Param.salAzim   %Salto entre valores de Azimut
	 SalTilt  = Param.salTilt   %Salto entre valores de Tilt
	 SalPot   = Param.salPot    %Salto entre valores de Potencia
	 FD_PROP_1 = {Module.link '../propagadores/tilt.so{native}'|nil }
	 FD_PROP_2 = {Module.link '../propagadores/azim.so{native}'|nil }
	 FD_PROP_3 = {Module.link '../propagadores/erlang.so{native}'|nil }
	 FD_PROP = fd( tilt:{Nth FD_PROP_1 1}.tilt
		      azim:{Nth FD_PROP_2 1}.azim
		      erlang:{Nth FD_PROP_3 1}.erlang
		     )
	 MaxCanales = Canal.({Maxim Canal})	 
	 LFactChannels={FactList MaxCanales}

	 PesoInterf= 1 
	 PesoActSet = 1
	 PesoPobAten = 3
	 PesoTrafico = 10
	 TotalPob = 1000

	 
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
	    ProbBloq	    	   
	    Cob
	    Cap
	    IntAux

	    %%Flag que indica si un punto cumple la restricción de mínimo y máximo de elementos en el
	    %%active set
	    FlgReachActSetMin
	    FlgReachActSetMax
	    FlgReachActSet 

	    %%Flag que indica si un punto cumple con la restricción de la interferencia
	    FlgReachInterf
	    %%Flag que indica si una radiobase cumple la restricción de tráfico 
	    FlgReachTraffic

	    %%Cantidad de puntos que cumplen con la restriccion de interferencia
	    ObjInterf
	    %%Cantidad de puntos que cumplen con la restricción del active set
	    ObjActSet
	    
	    ObjTraffic

	    %$La funcion objetivo total
	    ObjTotal
	    
	 in
	 
	    Root = result(
		      conf:Result
		      puntos:Punto
		      cobAux:CobAux
		      rbCobPto:RbCobPto
		      pobRb:PobRB
		      cap:Cap
		      cob:Cob
		      intAux:IntAux
		%      objInterf: obj1(flg:FlgReachInterf value:ObjInterf)
		      objInterf: obj1(value:ObjInterf)
		      %objActSet: obj2(flg:FlgReachActSet value:ObjActSet)
		      objActSet: ObjActSet
		      objTraf  : ObjTraffic
		      aObjetivo: ObjTotal
		      pBloq : ProbBloq
		      )	 	 	    


	    FlgReachActSetMin = {FD.tuple act M 0#1}
	    FlgReachActSetMax = {FD.tuple act M 0#1}
	    FlgReachActSet    = {FD.tuple act M 0#1}
            %%%%%%%%%%%%%%%
	    FlgReachInterf    = {FD.tuple int M 0#1}
            %%%%%%%%%%%%%%%
	    FlgReachTraffic   = {FD.tuple traf N 0#1}

	    %%Probabilidad de bloqueo por radiobase
	    ProbBloq        = {FD.tuple pBloq N 0#100}
	    
	    ObjInterf	      = {FD.int 0#M}
	    ObjActSet	      = {FD.int 0#M} 
	    ObjTraffic        = {FD.int 0#N}
	    ObjTotal          = {FD.int 0#FD.sup}	    	   

	    % for I in 1..(MaxCanales+1) do	       
% 	       Ldom.I =: {Nth LFactChannels I}
% 	    end

	    RbCobPto= {MakeTuple 'rbCobPto' N}
	    for I in 1..N do
	       RbCobPto.I={FD.tuple rbPto M 0#1}
	    end
	    PobRB   = {MakeTuple 'pobRb' N}
	    for I in 1..N do
	       PobRB.I={FD.int 0#FD.sup}
	    end

	    
	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ESTRUCTURAS DE DATOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 
      %Define la variable que va a almacenar el resultado
	    {MakeTuple solucion N Result}
	    for I in 1..N do
	       Result.I =
	       radioBase(
		  ind:_                      %Identificador de la radio-base
		  1:ant(az:_ tilt:_ pot:_ )  %Antena número 1 
		  2:ant(az:_ tilt:_ pot:_ )  %Antena número 2
		  3:ant(az:_ tilt:_ pot:_ )  %Antena número 3
		  rang:_                     %Identificador del rango asignado a cada antena  
		  )	       
	    end
	    
	    
      %Define los puntos donde se van a tomar mediciones
	    {MakeTuple punto M Punto}	
	    for K in 1..M do
	       Punto.K =
	       punto(
		  ind:_     %Identificador del punto
		  lRbs:_    %Tupla de Radio-Bases que pueden dar señal a un punto
		  lAnt:_    %Tupla de Identificadores de la antena que le da cobertura 
		  lSin:_    %Tupla con el nivel de señal que le da la antena en lAnt		  
		  lAz:_     %Azimut con que incide la señal en el punto
		  lEle:_    %Elevación con que incide la señal en el punto
		  indRb:_   %Identificador de la radiobase que le brinda el nivel de señal más alto
		  inter:_   %Nivel de interferencia en el punto
		  flgCob:_  %Flag que indica si el punto está cubierto
		  )
	    end
	    
	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DOMINIOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
	    DomAzim = {Loop.forThread MinAzim MaxAzim SalAzim fun {$ Is I} I|Is end nil}
	    DomTilt = {Loop.forThread MinTilt MaxTilt SalTilt fun {$ Is I} I|Is end nil}
	    DomPot  = {Loop.forThread MinPot  MaxPot  SalPot  fun {$ Is I} I|Is end nil}

	    
	    for  I in 1..N do
	       Result.I.ind    = I
	       
	       Result.I.1.az   = {FD.int DomAzim}
	       Result.I.2.az   = {FD.int DomAzim}
	       Result.I.3.az   = {FD.int DomAzim}	   
	       
	       Result.I.1.tilt = {FD.int DomTilt}
	       Result.I.2.tilt = {FD.int DomTilt}
	       Result.I.3.tilt = {FD.int DomTilt}
	    
	       Result.I.1.pot  = {FD.int DomPot}
	       Result.I.2.pot  = {FD.int DomPot}
	       Result.I.3.pot  = {FD.int DomPot}
	       
	       Result.I.rang   = {FD.tuple ran 3 1#3} 
	    end
	    
	    
	    for K in 1..M do
	       Punto.K.ind     =  Param.puntos.K.ind  
	       Punto.K.lRbs    =  Param.puntos.K.lRbs 
	       Punto.K.lAnt    = {FD.tuple ant Param.puntos.K.numAntenas 1#3}  
	       Punto.K.lSin    = {FD.tuple sin Param.puntos.K.numAntenas 0#FD.sup}   	       
	       Punto.K.lAz     = {FD.tuple azi Param.puntos.K.numAntenas 0#24}
	       Punto.K.lEle    = {FD.tuple ele Param.puntos.K.numAntenas 0#18}	  
	       Punto.K.indRb   = {FD.int 1#N}
	       Punto.K.inter   = {FD.int 0#FD.sup}
	       Punto.K.flgCob  = {FD.int 0#1}	       
	    end
	    	    
	    CobAux = {FD.tuple cob M 0#FD.sup }
	    Cob    = {FD.tuple cob M 0#1}
	    Cap    = {FD.int 0#FD.sup}
	    IntAux = {FD.tuple cob M 0#FD.sup}
	    	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%RESTRICCIONES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
         %Dos antenas de una radiobase no pueden tener el mismo rango
	    for I in 1..N do
	       {FD.distinct Result.I.rang}
	    end
	    
	    
 	 %La diferencia entre azimut es 120
	    for I in 1..N do
	       %Result.I.1.az =: 20 %Param.radioBases.I.antenas.1.azimuth
	       Result.I.2.az =: Result.I.1.az+120
	       Result.I.3.az =: Result.I.2.az+120

	       %%Esta es la configuraci'on actual de la red
	       	       

	       %% {System.show a1#Result.I.1.az#2#azimuth#Result.I.2.az#3#azimuth#Result.I.3.az}
	       %%se va a dar una solucion tilt
	       
	       %Result.I.1.tilt =:Param.radioBases.I.antenas.1.tilt
  	       %Result.I.2.tilt =:Param.radioBases.I.antenas.2.tilt
 	       %Result.I.3.tilt =:Param.radioBases.I.antenas.3.tilt

 	       %Potencia
	       %Result.I.1.pot =:Param.radioBases.I.antenas.1.pot
	       %Result.I.2.pot =:Param.radioBases.I.antenas.2.pot
	       %Result.I.3.pot =:Param.radioBases.I.antenas.3.pot
 	     
	    end

	    
	    
	 %Coloca el flag de relación de cobertura entre punto y radio base   
	    for I in 1..N do
	       for K in 1..M do		
		  if {IsIn Punto.K.lRbs I} then
		     for L in 1..Param.puntos.K.numAntenas do
			if Punto.K.lRbs.L == I then			   			   
			   (FD.sup*RbCobPto.I.K)     + UmbCob         >=: Punto.K.lSin.L %Para hacerlo 1	       
			   (FD.sup*(1-RbCobPto.I.K)) + Punto.K.lSin.L >:  UmbCob         %Para hacerlo 0
			end
		     end
		  else
		     RbCobPto.I.K=:0
		  end		  
	       end
	    end

	    %Determina la población que quedo dentro de la cobertura de la radiobase
	    for I in 1..N do
	       %{System.show poblacion#PobRB.I}
	       {FD.sumAC Pobl  RbCobPto.I '=:'  PobRB.I }	       
	    end  
	    	    	    
	    %Se identifica la Radiobase que provee el mejor enlace es el indice de la radiobase y antena que proporciona mayor cobertura
	    thread
	       for K in 1..M do
		  Punto.K.indRb =: {Maxim Punto.K.lSin}	       
	       end
	    end   	 

	    %%==========Calcula nivel de cumplimiento del objetivo del active set=======
	    %%{FD_PROP.activeSet
	    %% RbCobPto %%Tupla de tuplas
	    %% ObjActSet
	    %% Param.minSol
	    %% Param.maxSol
	    %% M
	    %%}
	    %%==========================================================================
	    %Flag que indica si el punto está cubierto o no	 
	    for K in 1..M do
	       %{System.show cobertura#CobAux.K}
	       {FD.sum {CoberturaPunto K RbCobPto} '>=:' Punto.K.flgCob} %Para hacerlo 0
	       {FD.sum {CoberturaPunto K RbCobPto} '=:' CobAux.K} 
	       CobAux.K =<: Punto.K.flgCob*N                    %Para hacerlo 1
	       Cob.K =:  Punto.K.flgCob
	       
	       %%Nivel mínimo y máximo de elementos en el active set	       
	       %% Mayor o igual al mínimo
	       %%==========================================Reemplaza Aldemar =========
	       FD.sup* (1- FlgReachActSetMin.K)+CobAux.K   >=:Param.minSol
	       FD.sup * (FlgReachActSetMin.K)+Param.minSol  >: CobAux.K
	       %% Menor o igual al máximo
	       FD.sup * (1- FlgReachActSetMax.K)+Param.maxSol   >=:CobAux.K
	       FD.sup * (FlgReachActSetMax.K)+CobAux.K          >:Param.maxSol 

	       %% Se valida el cumplimiento de ambos
	       FlgReachActSet.K =:1 - (FlgReachActSetMin.K * FlgReachActSetMax.K) 
	    end
	    {FD.sum  FlgReachActSet '=:' ObjActSet}
	    %%==========================================
	    %% Determina nivel de cumplimiento del objetivo del active set 
	    
	    
	 %Asigna el nivel de señal proporcionado por una antena al punto dado	 	 
	    for K in 1..M do
	       for L in 1..Param.puntos.K.numAntenas do
		  thread		     
		     Punto.K.lSin.L =:Result.(Punto.K.lRbs.L).(Punto.K.lAnt.L).pot +Gain.(DistTipo.(Punto.K.ind).(Punto.K.lRbs.L)).(1+Punto.K.lEle.L).(1+Punto.K.lAz.L)		     
  		  end
	       end	       
	    end
%===========================================
	    %%Esta la reemplaza Eduardo
	    %%Nivel de interferencia por Punto    	    
	    %%Se calcula como la sumatoria de senales co-canal que inciden en un punto
	    for K in 1..M do	       
	       thread		
		  {FD.sumAC Punto.K.lSin 
		   {CoCanal Punto.K.lRbs
		    Punto.K.lAnt Punto.K.lRbs.(Punto.K.indRb)
		    Punto.K.lAnt.(Punto.K.indRb)
		    Result
		   }
		   '=:' IntAux.K
		  }

		  %% Esta es
		  Punto.K.inter + Punto.K.lSin.(Punto.K.indRb)  =: IntAux.K
		  %%Punto.K.inter   =: IntAux.K 

		  %% La relación portadora interferencia es mayor al umbral
		  
		  FD.sup*(FlgReachInterf.K ) + Punto.K.lSin.(Punto.K.indRb) >: Param.umbInterf*Punto.K.inter
		  FD.sup*(1-FlgReachInterf.K) + Param.umbInterf*Punto.K.inter  >: Punto.K.lSin.(Punto.K.indRb)
		  
	       end
	    end
	    %% Determina cumplimiento de objetivo interferencia
	     {FD.sum FlgReachInterf '=:' ObjInterf}
%===========================================

	%Calcula el azimuth y tilt relativos 
 	    for K in 1..M do	    
	       for L in 1..Param.puntos.K.numAntenas do
	 	   thread		   
  		     {
  		      FD_PROP.azim
  		      Punto.K.lAz.L
  		      Punto.K.lAnt.L
  		      Result.(Punto.K.lRbs.L).1.az
  		      XRb.K.L
  		      XPto.K.L 
  		      YRb.K.L  
  		      YPto.K.L 
  		      SalAzim
  		     }
 		  end	
		   
		  thread
		     {		      
		      FD_PROP.tilt
		      Result.(Punto.K.lRbs.L).(Punto.K.lAnt.L).tilt		
		      Punto.K.lEle.L
		      2%Altura de la antena
		      Param.radioBases.(Punto.K.lRbs.L).hrb
		      Param.distancia.(Punto.K.ind).(Punto.K.lRbs.L)
		      SalTilt		      
		     }		     
		  end
	       end	       
	    end	    	    
	    
	    %restricción de Máximo tráfico
	    
	    thread
	       for I in 1..N do
		   {FD_PROP.erlang
 		   PobRB.I
 		   ProbBloq.I		   
 		   100 %Máxima Probabilidad de bloqueo, se debe tomar del archivo
 		   Canal.I
 		   20		   
 		  }
	       end
	    end
	    
	    %%Determinaci'on de la Capacidad del sistema
	    {FD.sumAC Pobl  Cob '=:' Cap}

	    %% Cumplimiento  de la probabilidad de bloqueo
	    for I in 1..N do
	       FD.sup*(FlgReachTraffic.I)+ Param.umbTraf >=: ProbBloq.I
	       FD.sup*(1- FlgReachTraffic.I)     + ProbBloq.I >: Param.umbTraf
	    end
	    {FD.sum FlgReachTraffic '=:' ObjTraffic}
	    %Función objetivo total
	    %% es (PesoInterf*N*TotalPob)*ObjInterf + (PesoActSet*N*TotalPob)*ObjActSet + (PesoTrafico*M*TotalPob*ObjTraffic) +
	    %% (PesoPobAten*N*M)*Cap = M*N*TotalPob*ObjTotal

	    (PesoInterf)*ObjInterf + (PesoActSet)*ObjActSet + (PesoPobAten)*Cap + PesoTrafico*ObjTraffic =: ObjTotal
	   
	    
	    %{System.show root#Root}
	     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%DISTRIBUCIÓN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    for I in 1..N do		
	       {FD.distribute ff Result.I.1}
	       {FD.distribute ff Result.I.2}
	       {FD.distribute ff Result.I.3}
	       {FD.distribute ff Result.I.rang}
	    end
	 end
      end   
   end
end