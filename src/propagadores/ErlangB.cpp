#include "ErlangB.h"

/*
namespace  MiEspacio{	
	double**  archivoTabla = 0;
}

using namespace MiEspacio;
*/

	
	ErlangB::ErlangB(): _refCount(1), _newLoc(NULL) {
		
		FILE *fp1;
		char palabra[100];
		int c;
	
		fp1 = fopen("tablaErlangB.txt", "r");
		
		//lee la cantidad de filas
		c = fscanf(fp1, "%s", palabra);
		filas = atoi(palabra);
	
		//lee la cantidad de columnas 
		c = fscanf(fp1, "%s", palabra);
		columnas = atoi(palabra);
	
		// Array de punteros a int: 
		tabla = new  double*[filas];
		/*
		bool existe = false;
		if(MiEspacio::archivoTabla == 0){
			cout << " :( Me voy a crear :( :( :( :( :( :(  " << endl;
			MiEspacio::archivoTabla = new  double*[filas];
		}else{
			cout << " YA EXISTE NO VA A CREARSE" << endl;
			existe = true;
		}
		*/
		for(int i = 0; i < filas; i++) {
			tabla[i] = new double[columnas];
		//	if(!existe) MiEspacio::archivoTabla[i] = new  double[columnas];
		}
		//cout << "--------------------------------------------------------------------" << endl;
	
		for(int i = 0; i < filas; i++) 
			for(int j = 0; j < columnas; j++){
				c = fscanf(fp1, "%s", palabra);
				tabla[i][j] = atof(palabra);
//				if(!existe) MiEspacio::archivoTabla[i][j] = tabla[i][j];//atof(palabra);
			}
/*
		for(int i = 0; i < filas; i++) {
			for(int j = 0; j < columnas; j++){
				cout  << MiEspacio::archivoTabla[i][j] << endl;;
			}
		}*/

		fclose(fp1);
		
		//cout << "--------------------------------------------------------------------" << endl;
		_newLoc = this;
		
	}
	
	
	static void ErlangB::operator delete (void * p) {
		ErlangB * eB = (ErlangB *) p;
		//cout << "borrar ErlangB !!!" <<eB->_refCount<< endl; 
		if (0 == --eB->_refCount)
		{// Liberar memoria: 
			//cout << "ErlangB Borrado!!!" << endl; 
			for(int i = 0; i < eB->filas; i++) delete[] eB->tabla[i]; 
			delete[] eB->tabla; 
		}
	}
	
	ErlangB * ErlangB::getRef(void) {
		_refCount += 1;
		return this;
	}
	
	ErlangB * ErlangB::copy (void) {
		if (_newLoc)
			_newLoc->getRef();
		else
			_newLoc = new ErlangB();
		return _newLoc;
	}
	
	
	double ErlangB::getValue(int x, int y)
	{
		return tabla[x][y];
	}
	
	double ErlangB::getProbBloq(int canales, double trafico)
	{
		
		double actual=0;
	
		for(int i = 1; i<columnas; i++){
			actual = tabla[canales][i];
			if(trafico < actual){
				return tabla[0][i];
			}
		}
		
		
		return tabla[0][columnas-1];
	}
	
