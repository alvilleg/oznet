declare
fun{PruebaRes}
   StringP
in
   proc{$ S}
      Indice = {FD.int 1#4}
      Valores = [1 10 3 4 5]
      Valor = {FD.int 0#FD.sup}
      
   in
      Valor = {FD.int Valores}
      Valor = {FD.int [2 3 5 6 10 1]}
      Valor = {FD.int [2 3 5 6  1]}
      S=Indice#Valor
      Indice =: 2
      %Valor =:2
      {FD.distribute ff S}
      {FD.element Indice Valores Valor}
   end   
end
{Explorer.all {PruebaRes}}