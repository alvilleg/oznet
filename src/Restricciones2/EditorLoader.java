class EditorLoader{

	public static void main(String arg[]){
		try{
		
		final Runtime runtime = Runtime.getRuntime();

		int   end = arg[0].lastIndexOf('@');
		final String path = arg[0].substring(end+1);
		String args = arg[0].substring(0,end).replace('%',' ');
		
		final String command = "java -jar NetworkMaker.jar "+args;

		
		runtime.addShutdownHook(new Thread( new Runnable() {
			public void run() {
			try{
				java.lang.Process process;
				java.io.File jarPath = new java.io.File(path);
				
				//Carga la red
				process = runtime.exec(command, null, jarPath);
			}catch(Exception ex){
				ex.printStackTrace();
			}
		}}));
		
		System.exit(0);
		
		} catch(Exception exe){
			exe.printStackTrace();
		}
	}
}
