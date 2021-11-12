%*************************************************************
%Modulo encargado de distribuir las variables, consta de dos
%estrategias: que solo difieren en la forma de imponer el orden
%en que se fijaran los tiempos de aterrizaje de cada avion.
%    1.Primero los que tengan penalidad mas alta
%    2.Primero los que tienen tiempo ideal de aterrizaje menor
%
% ************************************************************
% Autor: Aldemar Villegas, 0132080
%        Maria Helena Ocampo, 0010344
% FechaInicio:
% Fecha fin:
% ************************************************************
functor
import
   Distribute
   FD
   Space
   Browser
   Explore
   System
export
   strategy:Strategy
   strategy1:Strategy1
define
   proc{Strategy N Target TiEarl TiLate PenAft PenBef Costo Vars}
      local
	 fun {TupList T}
	    {TupListAux T 1 }
	 end
	 fun {TupListAux T I}
	    if I<N then
	       T.I| {TupListAux T I+1}
	    else
	       T.N|nil
	    end
	 end
	 fun {SumList L1 L2}
	    case L1 of
	       nil then nil
	    []F|R then
	       case L2 of
		  Fr|Rr then
		  F+Fr|{SumList R Rr}
	       end
	    end
	 end
	 Pens={SumList {TupList PenAft}{TupList PenBef}}
	 Order= proc {$ V1 V2 Co}
		   %{Browser.browse ord#V1}
	%	   Co={List.nth Pens V1.id} > {List.nth Pens V2.id}
		%   Co= (Target.(V1.id)=< (Target.(V2.id)))
		   Co={List.nth Pens V1.id} > {List.nth Pens V2.id}
	%	      (Target.(V1.id)=< (Target.(V2.id)))}
		       
		   
		end
	 Value= proc{$ El R}
		   Dominio
		   Targ
		   Mens
		   Mays
		   MasCeAnt
		   MasCeDes
		   Dd
		   Da
		   fun{SepList Filt L T}
		      case L of
			 nil then nil
		      [] F|R then
			 if {Filt F T} then
			    F|{SepList Filt R T}
			 else
			    {SepList Filt R T}
			 end
		      end
		   end

		   fun{Menores A1 A2}
		      A1<A2
		   end
		   fun{Mayores A1 A2}
		      A1>=A2
		   end
		   
		   fun{ElMasCerca T D}
		      {Mini {Diferencias D T}}		      
		   end
		   fun {Diferencias D T}
		      case D of
			 nil then nil
		      [] F|R then {Number.abs F-T}|{Diferencias R T}
		      end
		   end
		   
		   fun {Mini L}
		       case L of
			  nil then false
		       [] F|R then
			  case R of
			     nil then 1
			  else
			     local M={Mini R}
			     in
				if F<{List.nth R M} then 1
				else
				   M+1
				end
			     end
			  end
		       end
		   end 
		in
		   Dominio={FD.reflect.domList El.dom}
		   Targ=Target.(El.id)
		   Mays={SepList Mayores Dominio Targ}
		   Mens={SepList Menores Dominio Targ}
%		   {System.show mays#Mays}
%		   {System.show mens#Mens}
%		   {System.show long#{List.length Dominio}}
%		   {System.show targ#Targ}
		   case Mays of
		   X|Xr then
		      case Mens of
			 Y|Yr then
			 Da={Number.abs Targ-{List.nth Mens {List.length Mens}}}
			 Dd={Number.abs Targ-{List.nth Mays 1}}
			 if({Int.toFloat Da}*PenBef.(El.id) < {Int.toFloat Dd}*PenAft.(El.id)) then
			    R={List.nth Mens {List.length Mens}}
			 else
			    R={List.nth Mays 1}
			 end
		      else
			 R={List.nth Mays 1}
		      end
		   else
		      case Mens of
			 Y|Yr then
			 R={List.nth Mens {List.length Mens}}
		      end
		   end
		   if({IsFree R}) then
		      R={List.nth Dominio {ElMasCerca Targ Dominio}}
		   end
%		   {System.show r#R}
		end
	 %Faltan validaciones, interfaz, calcular el costo, pulir Restricciones
	 
	 Filter = fun {$ V}
		     {FD.reflect.size V.dom} > 1
		  end
	 Select= fun {$ V}
%		    {System.show elegida#V.id}
		    V
		 end 
	 Proc=proc {$} {Space.waitStable} skip end
	 EstDist=generic(order:    Order
			 filter:       Filter
			 select:       Select
			 value:        Value
			 procedure:     Proc 
			)
      in
	 {Distribute.distribute EstDist Vars}
      end  
   end
   
   proc{Strategy1 N Target TiEarl TiLate PenAft PenBef Costo Vars}
      local
	 fun {TupList T}
	    {TupListAux T 1 }
	 end
	 fun {TupListAux T I}
	    if I<N then
	       T.I| {TupListAux T I+1}
	    else
	       T.N|nil
	    end
	 end
	 fun {SumList L1 L2}
	    case L1 of
	       nil then nil
	    []F|R then
	       case L2 of
		  Fr|Rr then
		  F+Fr|{SumList R Rr}
	       end
	    end
	 end
	 Pens={SumList {TupList PenAft}{TupList PenBef}}
	 Order= proc {$ V1 V2 Co}
		   %{Browser.browse ord#V1}
%		   Co={List.nth Pens V1.id} > {List.nth Pens V2.id}
		   Co={Bool.'and' {List.nth Pens V1.id} > {List.nth Pens V2.id}
		      (Target.(V1.id)=< (Target.(V2.id)))}
		       
		   
		end
	 Value= proc{$ El R}
		   Dominio
		   Targ
		   Mens
		   Mays
		   MasCeAnt
		   MasCeDes
		   Dd
		   Da
		   fun{SepList Filt L T}
		      case L of
			 nil then nil
		      [] F|R then
			 if {Filt F T} then
			    F|{SepList Filt R T}
			 else
			    {SepList Filt R T}
			 end
		      end
		   end

		   fun{Menores A1 A2}
		      A1<A2
		   end
		   fun{Mayores A1 A2}
		      A1>=A2
		   end
		   
		   fun{ElMasCerca T D}
		      {Mini {Diferencias D T}}		      
		   end
		   fun {Diferencias D T}
		      case D of
			 nil then nil
		      [] F|R then {Number.abs F-T}|{Diferencias R T}
		      end
		   end
		   
		   fun {Mini L}
		       case L of
			  nil then false
		       [] F|R then
			  case R of
			     nil then 1
			  else
			     local M={Mini R}
			     in
				if F<{List.nth R M} then 1
				else
				   M+1
				end
			     end
			  end
		       end
		   end 
		in
		   Dominio={FD.reflect.domList El.dom}
		   Targ=Target.(El.id)
		   Mays={SepList Mayores Dominio Targ}
		   Mens={SepList Menores Dominio Targ}
%		   {System.show mays#Mays}
%		   {System.show mens#Mens}
%		   {System.show long#{List.length Dominio}}
%		   {System.show targ#Targ}
		   case Mays of
		   X|Xr then
		      case Mens of
			 Y|Yr then
			 Da={Number.abs Targ-{List.nth Mens {List.length Mens}}}
			 Dd={Number.abs Targ-{List.nth Mays 1}}
			 if({Int.toFloat Da}*PenBef.(El.id) < {Int.toFloat Dd}*PenAft.(El.id)) then
			    R={List.nth Mens {List.length Mens}}
			 else
			    R={List.nth Mays 1}
			 end
		      else
			 R={List.nth Mays 1}
		      end
		   else
		      case Mens of
			 Y|Yr then
			 R={List.nth Mens {List.length Mens}}
		      end
		   end
		   if({IsFree R}) then
		      R={List.nth Dominio {ElMasCerca Targ Dominio}}
		   end
%		   {System.show r#R}
		end
	 %Faltan validaciones, interfaz, calcular el costo, pulir Restricciones
	 
	 Filter = fun {$ V}
		     {FD.reflect.size V.dom} > 1
		  end
	 Select= fun {$ V}
%		    {System.show elegida#V.id}
		    V
		 end 
	 Proc=proc {$} {Space.waitStable} skip end
	 EstDist=generic(order:    Order
			 filter:       Filter
			 select:       Select
			 value:        Value
			 procedure:     Proc 
			)
      in
	 {Distribute.distribute EstDist Vars}
      end  
   end
end








