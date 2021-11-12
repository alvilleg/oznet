#include "mozart_cpi.hh" 

class Iterator_OZ_FDIntVar 
{ 
private: 
  int _l_size; 
  OZ_FDIntVar * _l; 
public: 
  Iterator_OZ_FDIntVar(int s, OZ_FDIntVar * l);
  OZ_Boolean leave(void);	 	
  void fail(void) ; 
};

