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

class activeSetProp : public OZ_Propagator 
{ 

  private: 
    static OZ_PropagatorProfile profile;
    OZ_Term *_rbCobPto ;
    OZ_Term _objActSet; 
    int _min,_max,_numPtos, _rb_size;

  public:  
   
    activeSetProp::activeSetProp(OZ_Term objActSet,OZ_Term rbCobPto,int min,int max,int numPtos) 
    {
  //Asignar la matriz
//cout<<"Constructor activeSet "<<endl;     
      _objActSet=objActSet;
      _min=min;
      _max=max;
      _numPtos=numPtos;
      _rb_size=OZ_vectorSize(rbCobPto);
  
      _rbCobPto =  OZ_hallocOzTerms(_rb_size);  
      OZ_getOzTermVector(rbCobPto, _rbCobPto);
//cout<<"Termina Constructor activeSet "<<endl;           
    } 	

    virtual OZ_Return propagate(void);   
    virtual size_t activeSetProp::sizeOf(void) 
    { 
      return sizeof(activeSetProp); 
    }

    virtual void activeSetProp::gCollect(void) 
    {
      OZ_gCollectTerm(_objActSet);
      _rbCobPto = OZ_gCollectAllocBlock(_rb_size, _rbCobPto);       

    } 
	
	
    virtual void activeSetProp::sClone(void) 
    { 
      OZ_sCloneTerm(_objActSet);   
      _rbCobPto = OZ_sCloneAllocBlock(_rb_size, _rbCobPto);
    }
		
    virtual OZ_Term activeSetProp::getParameters(void) const 
    {     
      OZ_Term list = OZ_nil();      
      for (int i = _rb_size; i--; )  
	list = OZ_cons(_rbCobPto[i], list);  
      
      return OZ_cons(list,  
			     (OZ_cons (_objActSet, OZ_nil())));      
	      
    }   	

    virtual OZ_PropagatorProfile *getProfile(void) const 
    { 
      return &profile; 
    } 	
};
  OZ_PropagatorProfile activeSetProp::profile;
  

OZ_Return activeSetProp::propagate(void) 
{         
  //std::cout<<"Inicia";
  OZ_FDIntVar  objActSet(_objActSet);
  OZ_FDIntVar rbCobPto[_rb_size];
  Iterator_OZ_FDIntVar RBCobPto(_rb_size,rbCobPto );
  OZ_FiniteDomain objActiveSetAux(fd_empty);
  
  int contObj=0;
  int indValue=0,posAdd=0;
  int contNotSingle=0;  
  double boundValue=0.0;
  bool   findValue=false,allDet=true;
  int maxDetDef=0, numPtsAbove=0,numPtsUnder=0;
  //std::cout<<" rb_size "<<_rb_size<<" numPtos "<<_numPtos<<endl;  
  for (int i = _rb_size; i--; )
    {
      rbCobPto[i].read(_rbCobPto[i]);	  
    }
  
  for (int cob= _rb_size;cob--;)
    {      	
      //if(rbCobPto[cob]->getSize()==1)
      //{		
      if(rbCobPto[cob]->getMinElem() >= _min && rbCobPto[cob]->getMinElem()<=_max)
	    {
	      contObj++;
	    }
	//}	
    }
    
  indValue = static_cast<int>((contObj*100)/_numPtos);
    
  /*if(objActSet->isIn(indValue))
  {*/
      //se asigna un valor al objetivo y termina la b'usqueda
      //std::cout<<"Se acaba el objetivo es"<<indValue<<endl;	      
      objActiveSetAux+=indValue;
      findValue=true;	     	      	  
      //reemplazarla por una variable con el valor
      //return replaceBy(_objActSet,indValue);	      
    //}
  //  std::cout<<"Valor indicador "<<indValue<<"PosAdd"<<posAdd<<endl;      
   FailOnEmpty(*objActSet &= objActiveSetAux );  
   return (RBCobPto.leave() | objActSet.leave()) ? OZ_SLEEP : OZ_ENTAILED;
   
 failure:  
   //std::cout<<"Fallo "<<endl;
   RBCobPto.fail(); 
   objActSet.fail();
   return OZ_FAILED; 
}

OZ_BI_define(fd_activeSet,5 , 0) 
{ 

  OZ_EXPECTED_TYPE(OZ_EM_VECT OZ_EM_FD","OZ_EM_FD","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT); 
  ExtendedExpect pe;
  OZ_EXPECT(pe, 0, expectVectorIntVarAny);  
  OZ_EXPECT(pe, 1, expectIntVar);    

  OZ_EXPECT(pe, 2, expectInt);  

  OZ_EXPECT(pe, 3, expectInt);  

  OZ_EXPECT(pe, 4, expectInt);  

  
  int entrada2 =OZ_intToC(OZ_in(2));// (OZ_in(3)-14)/16;
  int entrada3 =OZ_intToC(OZ_in(3));// (OZ_in(4)-14)/16;          
  int entrada4 =OZ_intToC(OZ_in(4));// (OZ_in(4)-14)/16;  

    if (OZ_vectorSize(OZ_in(0)) == 0)  
      {
	//std::cout<<"fallo 1 "<<endl;
	return pe.fail();
      }

    return pe.impose(
    			new activeSetProp
			(OZ_in(1), OZ_in(0),entrada2,entrada3,entrada4)); 

  } OZ_BI_end
        
  OZ_C_proc_interface *oz_init_module(void) 
  {	
    static OZ_C_proc_interface i_table[] = 
    { 
      {"activeSet", 5, 0, fd_activeSet}, 
      {0,0,0,0} 
    }; 
    std::cout<<"activeSet propagator loaded V2"<<endl;     
    return i_table; 
  }
