//#include "mozart.h"
#include "mozart_cpi.hh" 

//typedef OZ_expect_t (O::*OZ_ExpectMeth)(OZ_Term); 
class ExtendedExpect : public OZ_Expect 
{ 
private:  	
OZ_expect_t _expectIntVarAny(OZ_Term t) 
{ 
	return expectIntVar(t, fd_prop_any); 
}     
public: 
OZ_expect_t expectIntVarSingl(OZ_Term t) 
{ 
	return expectIntVar(t, fd_prop_singl); 
}	

OZ_expect_t expectVectorIntVarAny(OZ_Term t) 
{ 
	return expectVector(t, (OZ_ExpectMeth) &_expectIntVarAny); 
} 
OZ_expect_t expectVectorIntVarSingl(OZ_Term t) 
{ 
	return expectVector(t, (OZ_ExpectMeth) &expectIntVarSingl); 
} 
}