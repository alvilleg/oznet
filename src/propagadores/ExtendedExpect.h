#include "mozart.h"
#include "mozart_cpi.hh" 
class ExtendedExpect : public OZ_Expect 
{ 
  private:
  	OZ_expect_t _expectIntVarAny(OZ_Term t);

  public:
  	OZ_expect_t expectIntVarSingl(OZ_Term t);
  	OZ_expect_t expectVectorIntVarAny(OZ_Term t);
  	OZ_expect_t expectVectorIntVarSingl(OZ_Term t);
};
