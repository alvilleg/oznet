#include "mozart_cpi.hh" 
#include "ExtendedExpect.h" 

	
OZ_expect_t ExtendedExpect::_expectIntVarAny(OZ_Term t)
{ 
	return expectIntVar(t, fd_prop_any);
}

OZ_expect_t ExtendedExpect::expectIntVarSingl(OZ_Term t)
{ 
	return expectIntVar(t, fd_prop_singl);
}	

OZ_expect_t ExtendedExpect::expectVectorIntVarAny(OZ_Term t)
{ 
	return expectVector(t, (OZ_ExpectMeth) &ExtendedExpect::_expectIntVarAny);
}

OZ_expect_t ExtendedExpect::expectVectorIntVarSingl(OZ_Term t)
{ 
	return expectVector(t, (OZ_ExpectMeth) &ExtendedExpect::expectIntVarSingl);
} 
