declare
fun{Insert Val List}
   case List of nil then
      Val|List
   elseif Val > List.1 then
      List.1|{Insert Val List.2}
   else
      Val|List
   end	       
end

{Browse {Insert 8 nil}}
