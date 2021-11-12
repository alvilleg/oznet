functor
   
import
   Browser
   FD
   Loop
export
   resetNetwork:ResetNetwork

define   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                     FUNCIÓN PRINCIPAL  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {ResetNetwork Param}
      proc {$ Result}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PARÁMETROS DE ENTRADA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 N        =Param.numRB  %Número de estaciones RadioBase
	 M        =  Param.numPtos  %Número de puntos en los que se harán mediciones de Señal
	 Dist     = 10 %Param.distancia  %Distancia entre la i-ésima estación RadioBase y el k-ésimo punto de medición
	 Pobl     = 10 %Param.pob  %Población que demanda servicio en un punto
	 Cocan    = 10 %Param.cocanal  %Indica si dos antenas comparten el mismo rango de canales
	 Canal    = 10%Param.canales  %Cantidad de canales asignados a una radiobase
	 MinSol   = 10%Param.minSol  %Cantidad mínima de solapamiento aceptada      
	 MaxSol   = 10%Param.maxSol  %Cantidad máxima de solapamiento permitida
	 MinPot   =10% Param.minPot  %Potencia mínima de las antenas
	 MaxPot   =10% Param.maxPot %Potencia máxima de las antenas
	 MinTilt  =10% Param.minTilt %Tilt mínimo de las antenas 
	 MaxTilt  =10% Param.maxTilt %Tilt máximo de las antenas
	 MinAzim  =10% 0             %Azimut mínimo de las antenas
	 MaxAzim  = 10%360            %Azimut máximo de las antenas
	 UmbSign  =10% Param.umbSign %Umbral a partir del cual se puede definir si un punto tiene o no cobertura
	 UmbInter =10% Param.umbInterf %Umbral que define el mínimo nivel permitido para la relación portadora-interferencia.
	 UmbTraf  =10% Param.umbTraf %Umbral que define la cantidad máxima de tráfico permitida para cualquier radiobase del sistema,dado en Erlangs
	 SalAzim  = 5%Param.salAzim %Salto entre valores de Azimut
	 SalTilt  = 6%Param.salTilt %Salto entre valores de Tilt
	 SalPot   = 5%Param.salPot %Salto entre valores de Potencia
	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 Punto
	 DomAzim
	 DomTilt
	 DomPot
	% {System.show aqui#Punto}
      in
	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ESTRUCTURAS DE DATOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 
      %Define la variable que va a almacenar el resultado
%	  {System.show aqui#Punto}
	 {MakeTuple solucion N Result}
	 for I in 1..N do
	    Result.I =
	    radioBase(
	       ind:_                      %Identificador de la radio-base
	       1:ant(az:_ tilt:_ pot:_ )  %Antena número 1 
	       2:ant(az:_ tilt:_ pot:_ )  %Antena número 2
	       3:ant(az:_ tilt:_ pot:_ )  %Antena número 3
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
	       lSin:_    %MakeTuple sin Datos.puntos.K.numAntenas}   %Tupla con el nivel de señal que le da la antena en lAnt
	       lFlgCob:_ %Flag que indica si la señal en lSin supera el umbral de cobertura
	       lAz:_     %Azimut con que incide la señal en el punto
	       lEle:_    %Elevación con que incide la señal en el punto
	       indRb:_   %Identificador de la antena que le brinda el nivel de señal más alto	 
	       )
	 end
	 
	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DOMINIOS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 
	 DomAzim = {Loop.forThread MinAzim MaxAzim SalAzim fun {$ Is I} I|Is end nil}
	 DomTilt = {Loop.forThread MinTilt MaxTilt SalTilt fun {$ Is I} I|Is end nil}
	 DomPot  = {Loop.forThread MinPot  MaxPot  SalPot  fun {$ Is I} I|Is end nil}
	 
	 for  I in 1..N do
	    Result.I.ind    = {FD.int 1#N}
	    
	    Result.I.1.az   = {FD.int DomAzim}
	    Result.I.2.az   = {FD.int DomAzim}
	    Result.I.3.az   = {FD.int DomAzim}
	    
	    Result.I.1.tilt = {FD.int DomTilt}
	    Result.I.2.tilt = {FD.int DomTilt}
	    Result.I.3.tilt = {FD.int DomTilt}
	    
	    Result.I.1.pot  = {FD.int DomPot}
	    Result.I.2.pot  = {FD.int DomPot}
	    Result.I.3.pot  = {FD.int DomPot}
	    skip
	 end
	
	 
	 for K in 1..M do
	    Punto.K.ind     = {FD.int 1#M} 
	   % Punto.K.lRbs    = {FD.tuple rbs Param.puntos.K.numAntenas 1#N}  
	    Punto.K.lAnt    = {FD.tuple ant Param.puntos.K.numAntenas 1#3}  
	    Punto.K.lSin    = {FD.tuple sin Param.puntos.K.numAntenas 0#FD.sup}   
	    Punto.K.lFlgCob = {FD.tuple cob Param.puntos.K.numAntenas 0#1}  
	    Punto.K.lAz     = {FD.tuple azi Param.puntos.K.numAntenas 0#FD.sup}
	    Punto.K.lEle    = {FD.tuple ele Param.puntos.K.numAntenas 0#FD.sup}
	%    Punto.K.indRb   = {FD.int 1#N}
	    skip
	 end
	 Result.1 = 10
%       for K in 1..M do
% 	 Punto.K.lSig.indRb = max
	 
% {FS.int.min *M $D}      
      end 
   end   
end