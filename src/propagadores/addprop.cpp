/***************************************************************************
 *   Copyright (C) 2006 by edureyes                                        *
 *   edureyes@avisponverde                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/


#ifndef NDEBUG 
#include <stdio.h> 
#endif 
#include "mozart_cpi.hh" 
#include "iostream.h"

#define FailOnEmpty(X) if((X) == 0) goto failure; 


// OZ_BI_proto(fd_init); 
OZ_BI_proto(fd_add); 

class AddProp : public OZ_Propagator { 

private: 
	static OZ_PropagatorProfile profile;
	OZ_Term _x, _y, _z; 
  int umbral;

public: 
  AddProp(OZ_Term a, OZ_Term b, OZ_Term c,OZ_Term threshold) : _x(a), _y(b), _z(c), umbral(threshold) {} 
	
	
	virtual OZ_Return propagate(void); 
	
	
	virtual size_t sizeOf(void) { 
		return sizeof(AddProp); 
	}
	
	
	virtual void gCollect(void) { 
		OZ_gCollectTerm(_x); 
		OZ_gCollectTerm(_y); 
		OZ_gCollectTerm(_z); 
	} 
	
	
	virtual void sClone(void) { 
		OZ_sCloneTerm(_x); 
		OZ_sCloneTerm(_y); 
		OZ_sCloneTerm(_z); 
	}
	
	
	virtual OZ_Term getParameters(void) const { 
		return OZ_cons(_x, OZ_cons(_y, OZ_cons(_z, OZ_nil()))); 
	} 
	
	virtual OZ_PropagatorProfile *getProfile(void) const { 
	          return &profile; 
	} 
	
}; 
OZ_PropagatorProfile AddProp::profile;



OZ_Return AddProp::propagate(void) { 

  
  //cout<<"con lo nuevo umbral"<<umbral<<"\n";
	OZ_FDIntVar     x(_x), y(_y), z(_z); 
  int _umbral(umbral);
	OZ_FiniteDomain x_aux(fd_empty),y_aux(fd_empty), z_aux(fd_empty); 
	
  //cout<<"con lo nuevo _umbral "<<_umbral<<"\n";
  //cout<<"con lo nuevo umbral entro"<<umbral<<"\n";
	for (int i = x->getMinElem(); i != -1; i = x->getNextLargerElem(i)) 
  {
		for (int j = y->getMinElem(); j != -1; j = y->getNextLargerElem(j)) 
    {
      if (z->isIn(i + j) && umbral > (i + j) ) 
      { 
				x_aux += i; 
				y_aux += j; 
//         if((i+j) == _umbral)
//         {
        z_aux += (i + j); //_umbral;//
//         }
			}         
    }
  }     
			
	FailOnEmpty(*x &= x_aux); 
	FailOnEmpty(*y &= y_aux); 
	FailOnEmpty(*z &= z_aux); 
	
	return 
		(x.leave() | y.leave() | z.leave()) ? OZ_SLEEP : OZ_ENTAILED; 
		
	
	failure: 
		x.fail(); 
		y.fail(); 
		z.fail(); 
		
		return OZ_FAILED; 
}


OZ_BI_define(fd_add,4 , 0) { 
  OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_FD","OZ_EM_FD","OZ_EM_LIT); 
//   OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_FD","OZ_EM_FD); 
  
	OZ_Expect pe; 
	
  
	OZ_EXPECT(pe, 0, expectIntVar); 
	OZ_EXPECT(pe, 1, expectIntVar); 
	OZ_EXPECT(pe, 2, expectIntVar); 
  OZ_EXPECT(pe, 3, expectInt);
  
  cout <<"umbral entrada "<<OZ_in(3);
  OZ_Term entrada = (OZ_in(3)-14)/16;
  cout<<"\n" <<" entrada ="<<entrada;
  return pe.impose(new AddProp(OZ_in(0), OZ_in(1), OZ_in(2),entrada)); 

} OZ_BI_end

    
    
OZ_C_proc_interface *oz_init_module(void) {
	
	static OZ_C_proc_interface i_table[] = { 
	  //{"init", 0, 0, fd_init}, 
		{"add", 4, 0, fd_add}, 
		{0,0,0,0} 
	}; 
	
	printf("addition propagator loaded\n"); 
//   cout<<"addition propagator loaded cout";
	return i_table; 
}

