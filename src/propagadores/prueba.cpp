#include<unistd.h>
#include <iostream>

using namespace std;


//char* arg[] = {" -jar ","/home/eduardo/tesis/NetworkMaker/dist/NetworkMaker.jar"};
//char* arg[] = {"/usr/lib/jdk1.5.0_06/bin/java","-jar","/home/eduardo/tesis/NetworkMaker/dist/NetworkMaker.jar"};
//char* arg[] = {"java","-jar","NetworkMaker.jar"};
//char* arg[] = {"java", "src/controladores/OztNet"};

char* arg[] = {"java","PruebaJ"};


static char* command;


int main(int c, char* args[])
{
	cout << "Ejecutar comando " << args[1] << endl;
	int res = execvp(arg[0], arg);
	cout << res << "Ejecutar comando" << endl;
	return 0;
}	
