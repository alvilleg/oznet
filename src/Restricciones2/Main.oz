functor
import
   Browser
   Application
   ReadFile   
   System
   Explorer
   ResetNetwork
   WriteOut
   Search
   Panel
   Property
   Module
define      
   proc{IniciarAplicacion}
      Sol
      Sol1
      Script1
      Solver1
      Script2
      Solver2
      ExecCommand      
      Datos
      Gain      
      NoSearch      
      P1      
      Val
      Config      
      Trafico
      WriteAll
      JustOne
      SolOne
      InstanceToOpen
      proc{CheckSoloution Sol}
	 local
	    Punto=Sol.puntos
	    Conf = Sol.conf
	 in
	    {System.show '******************************'}
	    for I in 1..{Width Punto}do
	       %{System.show 'punto '#I}
	       for J in 1..{Width Punto.I.lSign} do
		  if {Bool.'not' {IsDet Punto.I.lSign.J} } then
		     {System.show 'No determinada senal '#Punto.I.ind#' posicion '#J#' lista '#Punto.I.lSign.J}
		  end
		  if {Bool.'not' {IsDet Punto.I.lAz.J} } then
		     {System.show 'No determinada azimuth '#Punto.I.ind#' posicion '#J}
		  end
		  if {Bool.'not' {IsDet Punto.I.lEle.J} } then
		     {System.show 'No determinada tilt '#Punto.I.ind#' posicion '#J#'lista '#Punto.I.lEle.J}
		  end
	       end
	    end
	    {System.show '******************************'}
	    for I in 1..{Width Conf} do
	       for J in 1..3 do
		  if {Bool.'not' {IsDet Conf.I.J.az.dom } } then
		     {System.show 'No determinado azimuth RB '#I#'Ant'#J}
		  end
		  if {Bool.'not' {IsDet Conf.I.J.tilt.dom } } then
		     {System.show 'No determinado tilt  RB '#I#'Ant'#J}
		  end
		  if {Bool.'not' {IsDet Conf.I.J.pot.dom } } then
		     {System.show 'No determinado pot RB '#I#'Ant'#J}
		  end
		  if {Bool.'not' {IsDet Conf.I.J.rang.dom } } then
		     {System.show 'No determinado rang RB '#I#'Ant'#J}
		  end
	       end
	    end
	 end
      end
      proc{StopSearch Engine NoSearch}
	 NoSearch = unit
	 {Engine stop}
      end
      
      proc {SearchBestS Solver NoSearch TimeLimit Writer WriteAll Res?}	 
	 proc{SearchBestIt Found Counter Res?}
	    {System.show van#' '#Counter}
	    if {IsFree NoSearch} then 
	       case  {Solver next($)}  of [S] then 
		  {Browser.browse next#S.aObjetivo}
		  {System.show S.aObjetivo}
		  {CheckSoloution S}
		  if WriteAll == 1 then
		     {Writer S (Counter+1) 1}
		  else
		     {Writer S 0 0}
		  end
		  {Cell.assign  BestSolution S}
		  {SearchBestIt true Counter+1 Res?}
	       [] L then 
		  Res = L		  
	       end
	    else
	       Res = rc(status:stopped hasSol:Found manySols:Counter)
	    end
	 end
	 NoStop BestSolution Sol	 
      in	 
	 BestSolution = {NewCell nil}	 
	 thread
	    Dead
	 in
	    if TimeLimit.active == 1 then
	       {Alarm TimeLimit.t Dead}
	       {WaitOr Dead NoStop}
	       if {IsDet Dead} then
		  {StopSearch Solver NoSearch}
	       end
	    end
	 end
	 
	 Res = {SearchBestIt false 0}#Sol
	 Sol = @BestSolution
	 NoStop = unit
      end

      proc {WriteSol Sol Seq WriteAll}
	 case Sol of
	    nil then
	    {System.show 'No hay solucion'#Sol}
	    skip
	 elseif WriteAll == 0 then	    
	    {WriteOut.writeOut Datos Config.signalsFile#'.sig'
	     Config.instanceFile#'.ins'  Sol Sol.aObjetivo}
	 else
	    {WriteOut.writeOut Datos
	     Config.signalsFile#'-Sol-'#Seq#'.sig'
	     Config.instanceFile#'-Sol-'#Seq#'.ins'  Sol Sol.aObjetivo}
	 end
      end
   in
      %%Interfaz para la ejecucion de comandos
      ExecCommand = {Module.link '../propagadores/execCommand.so{native}'|nil}
      
      %%Se lee Archivo de configuración
      Config = {ReadFile.leerConfig}      

      %%Se cargan datos de la red
      Datos={ReadFile.leerArchivo Config.inputFile}
      Datos.gainFile = Config.inputGain
      Datos.pesos=Config.weigth
      Datos.useRelax=Config.useRelax

      %%Se carga datos de ganancias
      Gain = {ReadFile.leerGain Config.inputGain}
      Datos.offset=Gain.offset

      %%Lee la estrategia de distribuci'on
      Datos.strategy= Config.strategy

      %%Se llenan los datos de la configuraci'on de la red
      {ReadFile.fillNetInfo Config.inputNet Datos}

      %%Se determina el máximo tráfico que se puede portar      
      {ReadFile.leerTrafico
       Trafico       
       ( {Int.toFloat Datos.umbTraf}/100.0 )
       Datos.canales.1
       Datos.canales.1 
      }
      Datos.maxTrafico= Trafico.1      
      Datos.maxTraficoAnt = Trafico.2
      WriteAll = Config.writeAll
      JustOne = Config.justOne
      %%Propiedades de garbage colector
      {Property.put 'gc.free' 51}      
      %%Valida si debe explorar una solución o buscar la mejor
      if (Config.solType == 0) then
	 %%Buscar la primera configuración
	 thread
	    %%Ver panel de consumo de memoria
	    {Panel.object open}
	 end

	 %%Se crea el script
	 Script1={ResetNetwork.searchOne Datos Gain}
	 %%Se pasa el script al motor
	 Solver1={New Search.object
		  script(Script1  proc{$ O N } O.aObjetivo <: N.aObjetivo end ~1) }      
	 
	 %%Se toma la primera solucion
	 %{Explorer.one Script1}
	 Sol =  ({Solver1 next($)})
	 {System.show 'Termina el proceso'}
 	 case Sol of nil then
 	    {System.show 'No tiene solucion'}
 	    skip
 	 else
 	    {WriteSol Sol.1 0 0}
 	 end
      else
	 %%Buscar la mejor soluci'on en determinado tiempo	 

	 %%Abrir ventana para ver parametros de busqueda
	 Val ={ExecCommand.1.exec {Append "-Oz@" Config.jarDir}}
	 
	 Script1={ResetNetwork.searchOne Datos Gain}
	 Solver1={New Search.object script(Script1
					   proc{$ O N } O.aObjetivo <: N.aObjetivo end
					   ~1)
		 }      
	 
	 Sol = {Solver1 next($)}
	 case Sol
	 of nil then
	    {System.show 'No tiene solucion'}	    
	 elseif WriteAll == 1 then
	    {WriteSol Sol.1 0 WriteAll}
	 end
	 
	 Script2={ResetNetwork.resetNetwork Datos Gain Sol.1.aObjetivo}
	 Solver2={New Search.object script(Script2
					   proc{$ O N } O.aObjetivo <: N.aObjetivo end
					   Config.recomp)
		 }      
	 %%Abrir ventana para ver parametros de busqueda
	 %%{Explorer.best Script2  proc{$ O N } O.aObjetivo <: N.aObjetivo end}
	 
	 thread
	    %%Ver panel de consumo de memoria
	    {Panel.object open}
	 end
	 
	 %%Solo se busca la siguiente Mejor
	 if JustOne == 1 then	       
	    SolOne = {Search.one.depth Script2 ~1 _}
	    case SolOne of nil then
	       Sol1 = nil
	    else
	       Sol1 = SolOne.1
	    end
	 else	    
	    %%Busca la mejor solución o hasta que se cumpla el tiempo
	    P1#Sol1 = {SearchBestS Solver2 NoSearch Config.t WriteSol WriteAll}
	    {System.show 'Search info -- > '#P1#' sol '#Sol1#'writeAll'#WriteAll#'just One '#JustOne }
	 end
	    %Sol1=nil
	 %%Si se encontro solucion se escribe
	 if(Config.writeCurrent.active == 1)then
	    {WriteOut.writeOut Datos Config.signalsCurrent#'.sig'
	     Config.instanceCurrent#'.ins'  Sol.1 Sol.1.aObjetivo
	    }
	 end
	 case Sol1 of nil then	       
	    InstanceToOpen=Config.instanceCurrent
	 else
	    InstanceToOpen=Config.instanceFile
	    {WriteSol Sol1 0 0}	       
	 end            
      end
      
      if(Config.solType == 1) then
	 %%Se envia mensaje al editor para que se abra nuevamente y muestre el
	 %%Mejor resultado obtenido
	 
	  Val = {ExecCommand.1.exec
 		{Append {Append {Append {Append Config.netFile "%"}
 				 InstanceToOpen} "@"} Config.jarDir
  		}
 	       }
	 
      end
   end
   {IniciarAplicacion}
   
   %%Se cierra la aplicaci'on
   {Application.exit 0}
end