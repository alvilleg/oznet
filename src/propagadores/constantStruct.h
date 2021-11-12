#include <iostream>
#include <stdio.h>
#include <stdlib.h>
using namespace std;


class constantStruct {

	private:
    int distTypes;
		int tilts;
		int azimuths;
		int *tabla;
		int   _refCount;
		constantStruct* _newLoc;

	public:
    constantStruct(int *info,int dist_types,int tilts_types,int azim_types);
    
    /*Constructor por copia*/
    constantStruct(int ***table, int dist_types,int tilts_types,int azim_types);
		
		static void operator delete (void * p);
		
    constantStruct * getRef(void);
    constantStruct * copy (void);
		int getValue(int distType,int row, int col);
    	
};
