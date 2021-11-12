#include <iostream>
#include <stdio.h>
#include <stdlib.h>



using namespace std;


class ErlangB {

	private:
		
		int filas;
		int columnas;
		double** tabla;

		int   _refCount;
		ErlangB* _newLoc;

	public:
		ErlangB();

		static void operator delete (void * p);
		
		ErlangB * getRef(void);
		ErlangB * copy (void);

		double getValue(int x, int y);
		double getProbBloq(int canales, double trafico);
};
