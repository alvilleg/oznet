%%Modelo de restricciones para OztNet
%% Prototipo inicial

functor
import
   Browser
   System
   FD
export
   restricciones : Restricciones

define   
   fun{Restricciones Datos }
      proc{$ Root}
	 %%Definici�n de variables
	 %%Previamente se eliminan las celdas en las que por razones de insuficiente infraestructura o
	 %%lejan�a de las radiobases existentes es tecnicamente imposible brindar cobertura, adem�s porque
	 %%debido a la baja demanda en dichas celdas es poco interesante hacerlo
	 
      %Almacena toda la informaci�n de un punto
             % celda (RbCob: _ antCob:_ nivelSe�al: _ flagCob:_  nivelInterf:_  x:datos.I.x y:datos.I.y pob:datos.I.Pob )
      %Informaci�n de las radiobases
                  %radiobase( ant1: ant (tilt:{MinTilt, maxTilt} azimuth:{0..360} potencia:_) 
	 %%                      ant2: ant(tilt azimuth potencia) ant3: ant (tilt azimuth potencia))
	 %%Las antenas pertenecientes a una misma radiobase
	 
	 %% Matriz N*M de {1,0}, usado entre otros para medir el
	 %%nivel de solapamiento en un punto, (sumatoria de columnas), indica si la una radiobase cubre un punto
 %     Cob %%Tupla de M elementos donde Ck =1 si el punto k tiene cobertura
%      Pob %%Tupla de N elementos dond Pobi indica cual es la poblaci�n aproximada para la radiobase i. %
	 
		 
      in
	 skip
      end
   end
end
   