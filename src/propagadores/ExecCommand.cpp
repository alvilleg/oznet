
#include<unistd.h>
#include <iostream>
#include "mozart.h"
#include "ExtendedExpect.h"

using namespace std;


void exec(char* param1){
	int pid;
	if((pid=fork())<0) cout << "Error Fork" << endl;
	else if (pid == 0) {
		cout << "Ejecuta Comando" << endl;
		char* arg[] = {"java","EditorLoader",param1};
		execvp(arg[0], arg);
		cout << "Error Comando" << endl;
	}
	else cout << "Termina comando" << pid << endl;
}


OZ_BI_define(exec_command,1,1)
{
	ExtendedExpect extExp;
        OZ_EXPECTED_TYPE(OZ_EM_VECT OZ_EM_LIT);

	OZ_EXPECT(extExp, 0, expectVectorInt);

	char * param1 = OZ_stringToC(OZ_in(0),0);
	exec(param1);

	OZ_RETURN_INT(0);
}
OZ_BI_end



OZ_C_proc_interface * oz_init_module(void){
	static OZ_C_proc_interface table[] = {
		{"exec",1,1,exec_command},
		{0,0,0,0}
	};

	return table;
}

