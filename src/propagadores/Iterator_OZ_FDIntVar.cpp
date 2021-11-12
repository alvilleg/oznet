#include "mozart_cpi.hh" 
#include "Iterator_OZ_FDIntVar.h" 


Iterator_OZ_FDIntVar::Iterator_OZ_FDIntVar(int s, OZ_FDIntVar * l) 
  : _l_size(s), _l(l) 
{ 
  
} 
OZ_Boolean Iterator_OZ_FDIntVar::leave(void) 
{ 
  OZ_Boolean vars_left = OZ_FALSE; 
  for (int i = _l_size; i--; ) 
    vars_left |= _l[i].leave(); 
  return vars_left; 
} 
void Iterator_OZ_FDIntVar::fail(void) 
{ 
  for (int i = _l_size; i--; _l[i].fail()); 
} 
