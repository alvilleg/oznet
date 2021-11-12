declare
fun{IsIn RcList Elem}
	       {FindIte RcList Elem {Width RcList} 1}   
	    end
	    fun{FindIte RcList Elem N I}
	       if (N+1)== I then
		  false
	       else if RcList.I==Elem then
		       true
		    else
		       {FindIte RcList Elem N (I+1)}
		    end
	       end
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


	    fun {Get Rec I J K Ni Nj Nk}
	       Rec.((I-1)*(Nj*Nk)+((J-1)*Nk)+K)
	    end

	    for I in 1..2 do
	       for J in 1..2 do
		  for K in 1..3 do
		     {Browse ((I-1)*(3*2)+((J-1)*3)+K)}
		  end
	       end
	    end
	    
	   % {Browse  canales(10 11 15).({Maxim canales(10 11 15)})}
	   %  {Browse {Get r(a(
% 			      b(1 2 3 4 5 6)
% 			      b(7 8 9 10 11 12)
% 			      b(1 2 3 4 5 6)			      
% 			    )))}}