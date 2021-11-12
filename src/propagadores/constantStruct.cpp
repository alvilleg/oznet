#include "constantStruct.h"

	using namespace std;
	
	constantStruct::constantStruct(int  *info,int dist_types,int tilts_types,int azim_types): _refCount(1), _newLoc(NULL) {
    int cont=0; 
    int index=0;
    distTypes = dist_types;
    tilts = tilts_types; 
    azimuths = azim_types; 
		tabla = info;
		_newLoc = this;
	}
		
  static void constantStruct::operator delete (void * p) {
    constantStruct * cs = (constantStruct *) p;
		if (0 == --cs->_refCount)
		{// Liberar memoria: 
		      
		  delete[] cs->tabla; 
		}
	}
	
  constantStruct * constantStruct::getRef(void) {
		_refCount += 1;
		return this;
	}
	
  constantStruct * constantStruct::copy (void) {
		if (_newLoc)
			_newLoc->getRef();
		else
      _newLoc = new constantStruct( tabla,distTypes,tilts ,azimuths );
		return _newLoc;
	}
	
	
  int constantStruct::getValue(int d,int x, int y)
	{
	  int index = (d*tilts*azimuths)+(x*azimuths)+y;
		return tabla[index];
	}
