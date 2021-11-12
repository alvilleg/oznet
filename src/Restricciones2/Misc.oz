import
   System
export
   coCanal:CoCanal
   getAntByPoint:GetAntByPoint
   scalarProduct:ScalarProduct
   detMCD:DetMCD
   areAllDet:AreAllDet
define   
   fun {CoCanal Rb Ant  RecRbs RecAnts Rbs IndexPoint Param}
     
      Rc
   in
     
      {Value.wait Rbs.Rb.1.rang.dom}
     
      {Value.wait Rbs.Rb.2.rang.dom}
     
      {Value.wait Rbs.Rb.3.rang.dom}       
      Rc = {MakeTuple 'coc' Param.puntos.IndexPoint.numAntenas}
     
      for I in 1..Param.puntos.IndexPoint.numAntenas do
	 %%Param.puntos.K.posIniAnts + I
	 %%Indice de antena
	 %%(3*(Rb-1)+Rbs.Rb.Ant) indice  de la antena deseada
	 
	 %%Indice de la antena con la que se compara	       
	 %%(3*(RecRbs.(Param.puntos.K.posIniAnts + I) - 1)+(Rbs.
	 %%(RecRbs.(Param.puntos.K.posIniAnts + I)).(RecAnts.(Param.puntos.K.posIniAnts + I)))
	
	 if {Value.isDet RecAnts.(Param.puntos.IndexPoint.posIniAnts + I)} then
	    if {Value.isDet (Rbs.(RecRbs.(Param.puntos.IndexPoint.posIniAnts + I)).(RecAnts.(Param.puntos.IndexPoint.posIniAnts + I)).rang.dom)} then 
	       
	       Rc.I =
	       Param.cocanal.(3*(Rb-1)+Rbs.Rb.Ant.rang.dom).(3*(RecRbs.(Param.puntos.IndexPoint.posIniAnts + I) - 1)+(Rbs.(RecRbs.(Param.puntos.IndexPoint.posIniAnts + I)).(RecAnts.(Param.puntos.IndexPoint.posIniAnts + I)).rang.dom))
	    else
	
	       Rc.I = 0
	    end
	 else
	    Rc.I = 0
	 end	 
	
      end
     
      Rc
   end
   
   fun {GetAntByPoint IndexPoint IndexAnt Record Param}
      R
   in
      R=Record.((Param.puntos.IndexPoint.posIniAnts)+IndexAnt)	    
      R
   end

   fun{ScalarProduct Vect1 Vect2}
      fun{ScalarProductIte Acum Index Vect1 Vect2}
	 if(Index > {Width Vect1})then
	    Acum
	 else
	    {ScalarProductIte (Acum +(Vect1.Index * Vect2.Index)) (Index+1) Vect1 Vect2}
	 end
      end
   in
      if {Width Vect1}=={Width Vect2} then
	 if {Int.is Vect1.1} then
	    {ScalarProductIte 0 1 Vect1 Vect2}
	 else
	    {ScalarProductIte 0.0 1 Vect1 Vect2}
	 end
      else
	 {System.show 'Error!!'}
	 0
      end
   end

%%%%%
   fun{DetMCD Rc1}
      fun{GetMinIte Rc Index MinCurr}
	 if Index > {Width Rc} then
	    MinCurr
	 elseif Rc.Index < MinCurr then
	    {GetMinIte Rc (Index+1) Rc.Index}
	 else
	    {GetMinIte Rc (Index+1) MinCurr}
	 end
      end
      fun {IsCommunDivisor Num Rc1}	 
	 fun{IsCommunDivisorIte Num Rc Index}
	    if Index > {Width Rc}then
	       true
	    elseif Num == 0 then
	       false
	    elseif {Int.'mod' Rc.Index Num}==0 then
	       {IsCommunDivisorIte Num Rc (Index+1)}
	    else
	       false
	    end
	 end
      in
	 {IsCommunDivisorIte Num Rc1 1}	 
      end
      
      fun {FindMCD Min1 Rc}
	 fun {FindMCDIte Num Rc}
	    if Num == 1 then
	       1
	    elseif {IsCommunDivisor Num Rc} then
	       Num
	    else
	       {FindMCDIte (Num-1) Rc}
	    end	       
	 end
      in
	 {FindMCDIte (Min1-1) Rc}
      end
      Min1
   in     
      %%Se determina si el minimo del conjunto es Comun divisor del 
      %%resto
      Min1 = {GetMinIte Rc1 1 Rc1.1}
      
      if {IsCommunDivisor Min1 Rc1} then
	 Min1
      else
	 {FindMCD Min1 Rc1}
      end
   end   

%%%%%   

   
   fun {AreAllDet Rec}
      fun {AreAllDetIte Index Rec}
	 if (Index > {Width Rec}) then
	    true
	 elseif {Value.isDet Rec.Index} then
	    {AreAllDetIte (Index+1) Rec}
	 else
 	    false
	 end
      end
   in
      {AreAllDetIte 1 Rec}
   end

