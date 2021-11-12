functor 

import
   Space
   FD
   RelaxObjectives
   System
   Misc
export
   distribute: Distribute
   distWithoutRelax:DistWithoutRelax
define
   local     
      fun {Choose Xs Y Order}
	 case Xs of nil then Y
	 [] X|Xr then	    
	    {Choose Xr if {Order X Y} then X else Y end Order}    
	 end	 
      end

      proc {AssignAllValues Conf}
	 for I in 1..{Width Conf} do
	    for J in 1..3 do
	       {System.show 'Se asignan todos los valores ...'}
	       Conf.I.J.az.dom := {FD.reflect.min Conf.I.J.az.dom}
	       Conf.I.J.tilt.dom := {FD.reflect.min Conf.I.J.tilt.dom}
	       Conf.I.J.pot.dom := {FD.reflect.min Conf.I.J.pot.dom}
	       Conf.I.J.rang.dom := {FD.reflect.min Conf.I.J.rang.dom}
	    end
	 end
      end

     %  proc {RestrictSignals IndRb Data }
% 	 Data.rcRbData.IndRb.signals
% 	 Data.rcRbData.IndRb.tilts
% 	 Data.rcRbData.IndRb.azimuths
% 	 Data.rcRbData.IndRb.distTypes
% 	 Data.gain.gain
% 	 Data.gain.dist
% 	 Data.gain.tilts
% 	 Data.gain.azims
% 	 fun{Insert Val List}
% 	    case List of nil then
% 	       Val|List
% 	    elseif Val > List.1 then
% 	       List.1|{Insert Val List.2}
% 	    else
% 	       Val|List
% 	    end	       
% 	 end
% 	 fun {GetIndex IndexTD IndexT IndexA D T A}	    
% 	    IndexTD*T*A+(IndexT*A)+IndexA
% 	 end
%       in
% 	 fun {Filter ListTilts ListAzims ListDistTypes}
% 	    fun{BuidListIte IndexT IndexA IndexTD CurrList}
% 	       if indexTD > Data.gain.dist then
% 		  CurrList
% 	       elseif IndexT > Data.gain.tilts then
% 		  {BuidListIte 1 1 (IndexTD +1) {Insert
% 						 gain.({
% 							GetIndex IndexTD
% 							IndexT IndexA Data.gain.dist
% 							Data.gain.tilts  Data.gain.azims
% 						       })
% 						 CurrList}}
% 	       elseif IndexA > Data.gain.azims then
% 		  {BuidListIte (IndexT+1) 1 IndexTD {Insert
% 						     gain.({
% 							    GetIndex IndexTD
% 							    IndexT IndexA Data.gain.dist
% 							    Data.gain.tilts  Data.gain.azims
% 							   })
% 						     CurrList}}
% 	       else
% 		  {BuidListIte IndexT (IndexA+1) IndexTD {Insert
% 							  Data.gain.({
% 								 GetIndex IndexTD
% 								 IndexT IndexA Data.gain.dist
% 								 Data.gain.tilts  Data.gain.azims
% 								})
% 							  CurrList}}
% 	       end
% 	    end
% 	 in
% 	    {BuidListIte 1 1 1 nil}
% 	 end

%       end
     
      fun {RelaxAllObjectives Data }
	 ValueObj = {MakeTuple 'objs' 4}
	 ValueAux = {MakeTuple 'aux' 4}
      in
	 
	 if (Data.pesos.pesoInterf.active==1) then
	    if {Bool.'not' {Value.isDet Data.objetivos.1.dom }}then
	       
	       ValueAux.1 = {RelaxObjectives.relaxInterference
			     Data.puntos
			     Data.param.umbInterf
			     Data.param.numPtos
			     Data.recAnts
			     Data.recRbs
			     Data.offset
			     Data.conf
			     Data.param
			     Data.flgReachInterf
			    }
	       
	       if {Float.toInt ValueAux.1} > {FD.reflect.max Data.objetivos.1.dom} then
		  ValueObj.1={Int.toFloat {FD.reflect.max Data.objetivos.1.dom}}
	       else
		  ValueObj.1=ValueAux.1
	       end
	       
	    else
	       ValueObj.1= {Int.toFloat Data.objetivos.1.dom}
	    end
	 else
	    {System.show 'No activo interferencia'}
	    ValueObj.1 = 0.0
	 end
	  
	 if (Data.pesos.pesoPobAten.active==1) then	 
	    if {Bool.'not' {Value.isDet Data.objetivos.3.dom }}then
	       ValueAux.3= {RelaxObjectives.relaxTotalPob
			    Data.cob
			    Data.param.pobl
			    Data.pobTotal
			   }
	       if {Float.toInt ValueAux.3} > {FD.reflect.max Data.objetivos.3.dom} then
		  ValueObj.3={Int.toFloat {FD.reflect.max Data.objetivos.3.dom}}
	       else
		  ValueObj.3=ValueAux.3
	       end
	    else
	       ValueObj.3={Int.toFloat Data.objetivos.3.dom}
	    end
	 else
	    {System.show 'No activo capacidad'}
	    ValueObj.3 =0.0
	 end
	 
	 if (Data.pesos.pesoActSet.active==1) then
	    if {Bool.'not' {Value.isDet Data.objetivos.2.dom }} then
	       
	       ValueAux.2=  {RelaxObjectives.relaxActiveSet
			     Data.forHandoff
			     Data.param.minSol
			     Data.param.maxSol
			     {Width Data.forHandoff}
			    }
	       if {Float.toInt ValueAux.2} > {FD.reflect.max Data.objetivos.2.dom} then
		  ValueObj.2={Int.toFloat {FD.reflect.max Data.objetivos.2.dom}}
	       else		  
		  ValueObj.2=ValueAux.2
	       end
	    else	       
	       ValueObj.2 = {Int.toFloat Data.objetivos.2.dom}
	    end
	 else
	    {System.show 'No activo active set'}
	    ValueObj.2 = 0.0
	 end
	 
	 if (Data.pesos.pesoTrafico.active==1) then
	    ValueAux.4=  {RelaxObjectives.relaxTraffic
			  Data.pobRb
			  Data.minIntTrafico
			  Data.maxTrafico
			 }
	    
	 else	    
	    ValueAux.4 = 0.0
	    {System.show 'No activo trafico'}
	 end 
	 %{System.show 'ultimo'}
	 if {Float.toInt ValueAux.4} > {FD.reflect.max Data.objetivos.4.dom} then	    
	    ValueObj.4={Int.toFloat {FD.reflect.max Data.objetivos.4.dom}}
	 
	 else	   
	    ValueObj.4=ValueAux.4
	 end 

	 %% Es el de la intensidad de tráfico 
	 

	 local 
	    Rec 
	    Val
	    Equivs = rc(3 2 4 1)
	    fun {ObjsActives Index ListaPesos ListaObjs}
	       if Index < 1 then
		  rc(1:ListaPesos 2:ListaObjs) 
	       elseif Data.param.pesos.(Equivs.Index).active == 1 then
		  {ObjsActives (Index - 1)
		   {Int.toFloat Data.param.pesos.(Equivs.Index).weigth}|ListaPesos 
		   ValueObj.Index|ListaObjs
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
	  %  {System.show 'tamano '#{Length Rec.1}}
	    Val = {Misc.scalarProduct {List.toTuple 'w' Rec.1} {List.toTuple 'o' Rec.2}}
	    {System.show 'Relax '#Val#'max obj '#{FD.reflect.max Data.objTotal}#'min obj '#{FD.reflect.min Data.objTotal}}
	    Val
	 end	  	 	
      end
   in
      proc {Distribute RawSpec Vec Data}	      
	 case RawSpec	    
	 of generic(value:     SelVal
		    order:     Order
		    select:    Select
		    filter:    Fil
		    procedure: Proc) then
	    if {List.length  {Record.toList Vec}}>0 then
	       proc {Do Xs}
		  {System.show 'espera estabilidad'}
		  %{System.show 'Use relax'#Data.useRelax}
		  {Space.waitStable}
		  {System.show 'ya esta estable '}
	       in
		  case {Filter Xs Fil} of nil then
		     skip
		     {System.show 'se acaba'}
		  elseof Xs=X|Xr then
		     %%Se valida el valor de la relajación
		     %%Falla si ya encontr'o una medjor soluci'on o si ya la que tiene es
		     %% la mejor
		
		     if  ({RelaxAllObjectives Data} <
			    {Int.toFloat {FD.reflect.min Data.objTotal}
			    })
		     then %false then %
			{System.show '*************************** falla No hay mejores por aqui'}
			%%{System.show 'bound'#{Int.toFloat {FD.reflect.min Data.objTotal}}}
			%{System.show 'Xr'#Xr}
			IndAnt
			C
			V
			D
		     in
			C= {Choose Xr X Order}
			V={Select C IndAnt}			
			D={SelVal V C.ind IndAnt}		      		    
			choice
			   %%{System.show '90'#D}
			   {FD.int D  fail}
			[]
			   %%{System.show '93'#D}
			   {FD.int compl(D) fail}
			end
		     % elseif  {Misc.areAllDet Data.signals } then
% 			{System.show 'Todas determinadas ...'}
% 			{AssignAllValues Data.conf}
			
		     else

			IndAnt
			C
			V
			D 
		     in

			C= {Choose Xr X Order}
			V= {Select C IndAnt}
			D= {SelVal V C.ind IndAnt}

			
			%%{System.show ' no falla 2 si relax'}
			%{System.show 'Use relax'#Data.useRelax}
			%%Data.objTotal =<: {Float.toInt {RelaxAllObjectives Data}}
		     	     
			if Proc\=unit then			 
			   {Proc} %%Aqui se puede imponer las restricion de la senal
			   {Space.waitStable}			 
			end
			
			choice			
			   {FD.int D V.dom}
			[]			
			   {FD.int compl(D) V.dom}
			end
			%% o aqui, se espera estabilidad y se hace el llamado recursivo???
			%%Prueba interponiendo la Restricci'on de senal
			%{RestrictSignals C.ind }
			Data.conf.(C.ind).1.tilt.dom = {FD.int [1 2 6 8 9 12 13 14 15]}
			{Do Xs}			
		     end
		  end
	       end
	    in
	       %{System.show '********* llama al do ********'}
	       {Do {Record.toList Vec}}	 
	    end
	 else
	    skip
	 end
      end
      
      proc {DistWithoutRelax RawSpec Vec Data}	      
	 case RawSpec	    
	 of generic(value:     SelVal
		    order:     Order
		    select:    Select
		    filter:    Fil
		    procedure: Proc) then
	    if {List.length  {Record.toList Vec}}>0 then
	       proc {Do Xs}
		  %{System.show 'espera estabilidad'}
		  {Space.waitStable}		   
	       in
		  case {Filter Xs Fil} of nil then
		     skip
		  elseof Xs=X|Xr then		     
		     IndAnt
		     C
		     V
		     D
		  in
		     C= {Choose Xr X Order}
		     V={Select C IndAnt}			
		     D={SelVal V C.ind IndAnt}  			
		     %{System.show ' no falla 2 No relax'#Data.useRelax} 
		     %Data.objTotal =<: {Float.toInt {RelaxAllObjectives Data}}
		     
		     if Proc\=unit then			   
			{Proc}
			{Space.waitStable}			
		     end

		     if  {FD.reflect.min Data.objTotal} == 10000 then
			choice			
			   {FD.int D fail}
			[]			   
			   {FD.int compl(D) fail}
			end
		     else
			choice			
			   {FD.int D V.dom}
			[]
			   
			   {FD.int compl(D) V.dom}
			end
		     end
		     {Do Xs}			
		  end	       
	       end
	    in	       
	       {Do {Record.toList Vec}}	 
	    end
	 else
	    skip
	 end
      end      
   end
end


