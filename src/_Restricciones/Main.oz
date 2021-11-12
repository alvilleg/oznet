functor
import
   Browser
   Application
   ReadFile   
   Tk
   System
   Explorer
   ResetNetwork
   WriteOut
   Search
   Panel
define
   
%==================Interfaz Grafica==================================    
   Wind={New Tk.toplevel tkInit(title:'OztNet')}
   Label={New Tk.label tkInit(parent:Wind text:'Solucion para: ')}
   KLabel={New Tk.label tkInit(parent:Wind text:'Tiempo de busquda (Seg) =')}
   NArchivo={New Tk.entry tkInit(parent:Wind width:50)}
   FieldK={New Tk.entry tkInit(parent:Wind width:10) }
   Resul={New Tk.button tkInit(parent:Wind  text:'Solucion'  background:'gray'
			       action: proc{$}					  
					  {IniciarAplicacion }
				       end
			      )
	 }
   
   Ex={New Tk.button tkInit(parent:Wind text:'Examinar...' background: 'gray'
			    action:
			   proc {$}
			      case {Tk.return tk_getOpenFile(title:'Seleccione' filetypes: q(q('Archivos de texto' q('.txt'))) )}
			      of nil then skip 
			      elseof S then
				 {NArchivo tk(delete 0 'end')}
				 {NArchivo tk(insert 0 {String.toAtom S})}				 
			      end			     
			   end
			   )
      }
   
   Salir={New Tk.button tkInit(parent:Wind  text:'Salir'  background:'gray'
			    action: proc{$}
				       {Application.exit 0}
				    end
			       
			      )
	 }

   {Tk.send grid(Label row:1 column:1 padx:4 pady:4)}
   {Tk.send grid(NArchivo row:1 column:2 padx:4 pady:4)}
   {Tk.send grid(KLabel row:2 column:1 padx:4 pady:4)}
   {Tk.send grid(FieldK row:2 column:2 padx:1 pady:4)}
   {Tk.send grid(Ex row:3 column:2 padx:4 pady:4)}
   {Tk.send grid(Resul row:3 column:1 padx:4 pady:4)}
   {Tk.send grid(Salir row:3 column:3 padx:4 pady:4)}

%====================================================================
   proc{IniciarAplicacion}
      Sol
      Script1
      Solver1
      KillProc
      Datos
      Gain
      TimeLimit =20000%{String.toInt {FieldK tkReturn(get $)}}
      Stop      
      NoSearch
      P
      proc{StopSearch Engine NoSearch}
	 NoSearch = unit
	 {Engine stop}
      end
      
      proc {SearchBestS Solver NoSearch TimeLimit Res?}	 
	 proc{SearchBestIt Found Counter Res?}
	    {System.show van#' '#Counter}
	    if {IsFree NoSearch} then 
	       case  {Solver next($)}  of [S] then 
		  {Browser.browse next#S.aObjetivo}
		  {Cell.assign  BestSolution S}
		  {SearchBestIt true Counter+1 Res?}
	       [] L then 
		  Res = L		  
	       end
	    else
	       Res = stopped#Found#Counter
	    end
	 end
	 NoStop BestSolution Sol	 
      in	 
	 BestSolution = {NewCell nil}	 
	 thread
	    Dead
	 in
	    {Alarm TimeLimit Dead}
	    {WaitOr Dead NoStop}
	    if {IsDet Dead} then
	       {StopSearch Solver NoSearch}
	    end
	 end
	 
	 Res = {SearchBestIt false 0}#Sol
	 Sol = @BestSolution
	 NoStop = unit
      end
      
      proc {WriteSol Sol}
	 case Sol of
	    nil then
	    {System.show 'No hay solucion'#Sol}
	    skip
	 else
	    {System.show 'Si hay'#Sol}
	    {System.show objetivo#Sol.aObjetivo}
	    {WriteOut.writeOut Datos Datos.pathFilesWrite#'/'#Datos.netName#'Instance1.sig'
	     Datos.pathFilesWrite#'/'#Datos.netName#'Instance1.ins'  Sol Sol.aObjetivo
	    }
	    
	 end
      end      
   in
      
      case {NArchivo tkReturn(get $) }
      of nil then
	 skip
      elseof St then
	 Datos={ReadFile.leerArchivo {String.toAtom St}}	 
	 Gain = {ReadFile.leerGain Datos.gainFile}	 
      end
      {System.show Gain}            
      Script1={ResetNetwork.resetNetwork Datos Gain}
      Solver1={New Search.object script(Script1  proc{$ O N } O.objActSet <: N.objActSet end ~1) }      

      {Panel.object open}
      {Explorer.one {ResetNetwork.resetNetwork Datos Gain} }
      
      %%La mejor
      %% thread
      %% {Explorer.best {ResetNetwork.resetNetwork Datos Gain} proc{$ O N } O.cap  >: N.aObjetivo  end}
      %% {Explorer.one {ResetNetwork.resetNetwork Datos Gain} }%proc{$ O N } O.cap  >: N.cap  end}
      %%     end
      %% Time = {Time.time}
      %% for I in 1..3 do
      %% {Solver1 next($) _}	 
      %% end
      %  thread
      
      %P#Sol = {SearchBestS Solver1 NoSearch 30000}	 
      %{WriteSol Sol}	 	         
   end
end