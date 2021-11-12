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
 
OZ_BI_proto(fd_activeSet); 

using namespace std;

class activeSetProp : public OZ_Propagator 
{ 

  private: 
    static OZ_PropagatorProfile profile;
    OZ_Term *_rbCobPto ;
    OZ_Term _objActSet; 
    int _min,_max,_numPtos, _rb_size,_numRb;

  public:  
   
    activeSetProp(OZ_Term objActSet,OZ_Term rbCobPto,int min,int max,int numPtos);        
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
  
activeSetProp::activeSetProp(OZ_Term objActSet,OZ_Term rbCobPto,int min,int max,int numPtos) 
{
  //Asignar la matriz

  _objActSet=objActSet;
  _min=min;
  _max=max;
  _numPtos=numPtos;
  _rb_size=OZ_vectorSize(rbCobPto);
  
  _rbCobPto =  OZ_hallocOzTerms(_rb_size);  
  OZ_getOzTermVector(rbCobPto, _rbCobPto);
  _numRb = _rb_size/numPtos;
} 	

OZ_Return activeSetProp::propagate(void) 
{         
  //std::cout<<"Inicia";
  OZ_FDIntVar  objActSet(_objActSet);
  OZ_FDIntVar rbCobPto[_rb_size];
  Iterator_OZ_FDIntVar RBCobPto(_rb_size,rbCobPto );
  OZ_FiniteDomain objActiveSetAux(fd_empty);
  
  int suma=0,value=0,sumTotal=0;              
  int contObj=0;
  int indValue=0;
  int contNotSingle=0;  
  double valInd=0.0;
  double boundValue=0.0;
  bool   findValue=false;
  int maxDetIns=0, minDetExc=_numRb, numPtsAbove=0,numPtsUnder=0;
  
  for (int i = _rb_size; i--; )
    {
      rbCobPto[i].read(_rbCobPto[i]);	  
    }
  
  for (int cob=objActSet->getMinElem();cob!=-1;cob=objActSet->getNextLargerElem(cob))
    {      
	
      if(rbCobPto[cob]->getSize()==1)
	{		
	  if(cob >= _min && suma<=_max)
	    {
	      contObj++;
	    }
	}	
      else
	{
	  contNotSingle++;
	}
      //std::cout<<"value single "<< contNotSingle<<" value"<<value<<endl;	     	      
    }
  
  std::cout<<"sumaTotal "<<sumTotal<<" contNotSigle "<<contNotSingle<<endl;
  indValue = static_cast<int>((contObj*100)/_numPtos);
  std::cout<<"Valor indicador "<<indValue<<endl;      
   if(contNotSingle==0)
     {
       //todas est'an determinadas
       // valInd = (static_cast<double>(sumTotal))/(static_cast<double>(_min));
       //boundValue= (static_cast<double>())*(static_cast<double>(_numPtos))/100.0;	
       //std::cout<<"valInd "<<valInd<<" bound value "<<boundValue<<endl;
       /*if(valInd < boundValue)
	 {
	 std::cout<<"Fallo 0"<<endl;
	  break;
	  }*/	  
       if(objActSet->isIn(indValue))
	 {
	   //se asigna un valor al objetivo y termina la b'usqueda
	   std::cout<<"Si estaba"<<endl;	      
	   objActiveSetAux+=indValue;
	   findValue=true;	     	      	  
	   //reemplazarla por una variable con el valor
	   //return replaceBy(_objActSet,indValue);	      
	 }	       
     }
   else
     {       
       
       for (int o=objActSet->getMinElem();o!=-1;o=objActSet->getNextLargerElem(o))
	 {	  
	   suma=0;
	   value=0;
	   sumTotal=0;              
	   contObj=0;
	   indValue=0;
	   contNotSingle=0;  
	   valInd=0.0;
	   boundValue=0.0;
	   findValue=false;
	   maxDetIns=0;
	   minDetExc=_numRb;
	   for (int cob=objActSet->getMinElem();cob!=-1;cob=objActSet->getNextLargerElem(cob))

	     {

	       if(cob>= _min && suma<=_max)
		 {
		   contObj++;
		 }
	       else if(suma<_min)
		 {
		   if (suma > maxDetIns)
		     {
		       maxDetIns = suma;
		     }
		   numPtsUnder++;

		 }
	       else
		 {
		   if(suma < minDetExc)
		     {
		       minDetExc = suma;
		     }
		   numPtsAbove++;
		 }	
	       
	       //se determinan los valores que se necesitan para hacer el analisis
	     }
	   //   std::cout<<"Not single for "<< contNotSingle<<" value"<<value<<endl;
	   valInd = (static_cast<double>(sumTotal))/(static_cast<double>(_min)-static_cast<double>(maxDetIns))+
	     (static_cast<double>(contNotSingle))/(static_cast<double>(_min)-static_cast<double>(maxDetIns))-(static_cast<double>(numPtsAbove));
	   
	   boundValue=(static_cast<double>(o)*static_cast<double>(_numPtos))/100.0;
	   //std::cout<<"valInd for "<<valInd<<" for bound value "<<boundValue<<" obj "<<o<<endl;
	   
	   
	   if((valInd < boundValue))
	     {
	       std::cout<<"Fallo 0"<<endl;	  
	       break;
	       //FailOnEmpty(objActiveSetAux &=*objActSet );
	     }
	   valInd = (static_cast<double>(contObj))+
	     (static_cast<double>(contNotSingle))/(static_cast<double>(_min)-static_cast<double>(maxDetIns))-(static_cast<double>(numPtsAbove));
	   //std::cout<<"valInd for "<<valInd<<" for bound value "<<boundValue<<" obj "<<o<<endl;
	   if(valInd < boundValue)   
	     {
	       std::cout<<"Fallo 1"<<endl;	  
	       break;
	       //FailOnEmpty(objActiveSetAux &=*objActSet );
	     }
	   //std::cout<<"valInd for "<<valInd<<" for bound value "<<boundValue<<" obj "<<o<<endl;
	   
	   //los que faltan son los que deben ser menos los que van
	   boundValue = boundValue - static_cast<double>(contObj);
	   
	   //los que pueden ser son el m'aximo que se alcanzaria si a todos les faltara lo que le falta al 
	   //que menos le falta menos los que ya no pueden ser por que se pasaron del maximo
	   valInd= (static_cast<double>(contNotSingle))/(static_cast<double>(_min)-static_cast<double>(maxDetIns))-(static_cast<double>(numPtsAbove));
	     

	   //si los que pueden ser son menores a los que faltan se debe fallar
	   if((contNotSingle>0)&&(valInd< boundValue))
	   {
	     //std::cout<<"Fallo 2"<<endl;	  
	     break;
	   }
	   else 
	     { 
	       //std::cout<<"se incluye en el dominio, todavia se puede cumplir "<<o<<endl;
	       objActiveSetAux+=o;
	     }	  
	 }           	   
     }
   //std::cout<<"Cumplen "<<contObj<<endl;
   //std::cout<<"En el dominio quedan : "<<(objActiveSetAux &=*objActSet )<<" valor "<<objActSet->getMinElem()<<endl;  
   
   FailOnEmpty(objActiveSetAux &=*objActSet );  
   return (RBCobPto.leave() | objActSet.leave()) ? OZ_SLEEP : OZ_ENTAILED;
   
 failure:  
   std::cout<<"Fallo "<<endl;
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
	std::cout<<"fallo"<<endl;
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
    std::cout<<"activeSet propagator loaded 1 2"<<endl;     
    return i_table; 
  }
