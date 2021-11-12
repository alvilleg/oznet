/***************************************************************************
 *  Autor : Aldemar Villegas
 *  Fecha : Marzo 28 de 2006
 ***************************************************************************/


#include <iostream>
#include <cmath>
#include "mozart_cpi.hh" 
#include "ExtendedExpect.h"
#include "Iterator_OZ_FDIntVar.h" 
#define FailOnEmpty(X) if((X) == 0) goto failure; 
 
OZ_BI_proto(fd_elemDom); 

using namespace std;

class ElemDom : public OZ_Propagator 
{ 

  private: 
    static OZ_PropagatorProfile profile;
    OZ_Term *_dom_values ;
    OZ_Term _index,_value; 
    int _dom_size;

  public:  
   
    ElemDom::ElemDom(OZ_Term index,OZ_Term dom_values,OZ_Term value) 
    {
      //Asignar la matriz
//       std::cout<<"Inicia ..."<<endl;     
      _value=value;
      _index=index;      
      _dom_size=OZ_vectorSize(dom_values);
      _dom_values =  OZ_hallocOzTerms(_dom_size);  
      OZ_getOzTermVector(dom_values, _dom_values);
//       std::cout<<"Termina constructor ..."<<endl;     
    } 	

    virtual OZ_Return propagate(void);   
    virtual size_t ElemDom::sizeOf(void) 
    { 
      return sizeof(ElemDom); 
    }

    virtual void ElemDom::gCollect(void) 
    {
      OZ_gCollectTerm(_value);
      OZ_gCollectTerm(_index);
      _dom_values = OZ_gCollectAllocBlock(_dom_size, _dom_values);       

    } 
	
	
    virtual void ElemDom::sClone(void) 
    { 
      OZ_sCloneTerm(_value);   
      OZ_gCollectTerm(_index);
      _dom_values = OZ_sCloneAllocBlock(_dom_size, _dom_values);
    }
		
    virtual OZ_Term ElemDom::getParameters(void) const 
    {     
      OZ_Term list = OZ_nil();      
      for (int i = _dom_size; i--; )  
        list = OZ_cons(_dom_values[i], list);  
      
      return OZ_cons(list,  
                     (OZ_cons (
                         _value,(OZ_cons (_index ,
                         OZ_nil())))));      
	      
    }   	

    virtual OZ_PropagatorProfile *getProfile(void) const 
    { 
      return &profile; 
    } 	
};
  OZ_PropagatorProfile ElemDom::profile;
  

OZ_Return ElemDom::propagate(void) 
{         
  //std::cout<<"Inicia";
  OZ_FDIntVar  index(_index),value(_value);
  
  OZ_FDIntVar dom_values[_dom_size];
  
  Iterator_OZ_FDIntVar DomValues(_dom_size,dom_values );
  
  OZ_FiniteDomain indexAux(fd_empty);
  OZ_FiniteDomain valueAux(fd_empty);
    
  for (int i = _dom_size; i--; )
  {
    dom_values[i].read(_dom_values[i]);	  
  }
  
  for(int i = index->getMinElem();i!=-1;i=index->getNextLargerElem(i))
  {
    std::cout<<"en el ciclo de los indices ..."<<i<<endl;     
    for (int domVal=dom_values[i-1]->getMinElem(); 
             domVal!=-1;domVal=dom_values[i-1]->getNextLargerElem(domVal))
    {      	      
//       std::cout<<"en el ciclo de los dominios ..."<<domVal<<endl; 
      if(value->isIn(domVal))
      {
        indexAux+=i;
        valueAux+=domVal;
      }       	
    }
  }   
  std::cout<<"acaba propagación ..."<<endl;  
  FailOnEmpty(*index &= indexAux );  
  FailOnEmpty(*value &= valueAux );  
  
  return (DomValues.leave() | index.leave() | value.leave()) ? OZ_SLEEP : OZ_ENTAILED;
   
  failure:  
    //std::cout<<"Fallo "<<endl;
    DomValues.fail(); 
    index.fail();
    value.fail();
    return OZ_FAILED; 
}

OZ_BI_define(fd_elemDom,3 , 0) 
{ 

  OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_VECT OZ_EM_FD","OZ_EM_FD); 
  ExtendedExpect pe;
  OZ_EXPECT(pe, 0, expectIntVar);  
  OZ_EXPECT(pe, 1, expectVectorIntVarAny);    
  OZ_EXPECT(pe, 2, expectIntVar);  
  if (OZ_vectorSize(OZ_in(1)) == 0)  
      {
  //std::cout<<"fallo 1 "<<endl;
        return pe.fail();
      }

//     std::cout<<"Llama al constructor ..."<<endl;     
    return pe.impose(
        new ElemDom
        (OZ_in(0), OZ_in(1),OZ_in(2))); 

  } OZ_BI_end
        
  OZ_C_proc_interface *oz_init_module(void) 
  {	
    static OZ_C_proc_interface i_table[] = 
    { 
      {"elemDom", 3, 0, fd_elemDom}, 
      {0,0,0,0} 
    }; 
    std::cout<<"elemDom propagator loaded"<<endl;     
    return i_table; 
  }
