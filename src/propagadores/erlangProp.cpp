/***************************************************************************
 *  Autor : Aldemar Villegas
 *  Fecha : Febrero 12 de 2006
 *  Este propagador recibe como entrada la cantidad de canales asociados a una
 *  radiobase, un array con los factoriales de todos los números entre cero y ése
 *  Número de canales, la probabilidad máxima de bloqueo permitida y una variable
 *  a determinar que es la cantidad de usuarios que dados éstos parámetros la 
 *  radiobase puede soportar.
 ***************************************************************************/

#include <iostream>
#include <cmath>

#include "mozart_cpi.hh" 
#include "ExtendedExpect.h"
#include "Iterator_OZ_FDIntVar.h" 
#include "CalcFact.h"

#define FailOnEmpty(X) if((X) == 0) goto failure; 

using namespace std;

OZ_BI_proto(fd_erlangB); 


class erlangProp : public OZ_Propagator 
{ 

  private: 
    static OZ_PropagatorProfile profile;
    int _channelsByCell,_blockProb,_sizeChannels; 
    OZ_Term _usersByCell, _probBloqByCell;
    int _factChannels[21];   
    
  public:  
   
    erlangProp(OZ_Term usersByCell,OZ_Term probBloqByCell,int blockProb,int channelsByCell, int n);        
    virtual OZ_Return propagate(void);   
    virtual size_t erlangProp::sizeOf(void) 
    { 
      return sizeof(erlangProp); 
    }

    virtual void erlangProp::gCollect(void) 
    {             
      OZ_gCollectTerm(_usersByCell);
      OZ_gCollectTerm(_probBloqByCell);
    } 
		
    virtual void erlangProp::sClone(void) 
    {          
      OZ_sCloneTerm(_usersByCell);
      OZ_sCloneTerm(_probBloqByCell);
    }
	
	
    virtual OZ_Term erlangProp::getParameters(void) const 
    {   	
      	  return OZ_cons(_usersByCell,
                          (OZ_cons (_probBloqByCell, 
                           OZ_cons(_channelsByCell, 
			   	OZ_cons(_blockProb,OZ_nil())))));
    }   	

    virtual OZ_PropagatorProfile *getProfile(void) const 
    { 
      return &profile; 
    } 	
};
  OZ_PropagatorProfile erlangProp::profile;
  
  erlangProp::erlangProp
  (
  	OZ_Term usersByCell,
        OZ_Term probBloqByCell,
	int blockProb,
	int channelsByCell,
        int n
  ) : 
  _usersByCell(usersByCell),
  _probBloqByCell(probBloqByCell),
  _blockProb(blockProb), 
  _channelsByCell(channelsByCell),
  _sizeChannels (n)
  {    
    /* Asigna el factorial */    
    _factChannels[0]=1;  
    for (int i=1; i<=20;i++)
    {
    ////cout<<"en el calculo"<<i<<endl;
      _factChannels[i] = _factChannels[i-1]*i;
   // //cout <<fact[i]<<" "<<endl;
    }           
    //cout<<"se asigna "<<endl;
  } 	
	    	
  OZ_Return erlangProp::propagate(void) 
  {     
    int x,fact;
    double suma;
    int prob;
    OZ_FDIntVar  usersByCell(_usersByCell), probBloqByCell(_probBloqByCell);
    OZ_FiniteDomain usersByCellAux(fd_empty), probBloqByCellAux(fd_empty);         
        
    for(int i=usersByCell->getMinElem(); i != -1; i =usersByCell->getNextLargerElem(i))   
    {
      suma=0;      
      for(int k=0;k<= _channelsByCell ;k++)
      {
        fact=_factChannels[k];
      	suma += (pow(static_cast<double>(i),k)/fact); 
	//        cout <<" Tamaño "<<_sizeChannels<<"K"<<k<<" Fact "<<fact<<endl;
      }
      	
      //cout<<"Suma "<<suma<<"Fact "<<fact<<endl;
      prob = (int)(100.0*(std::pow(static_cast<double>(i),static_cast<double>(_channelsByCell))/(fact))/(suma));      
      //cout <<"prob"<<prob<<endl;
      if(probBloqByCell->isIn(prob))
	{    
	  usersByCellAux += i;
	  probBloqByCellAux += prob;       
	}      
    }
    
    /*if (usersByCell->getSize() == 1) 
    {       
      usersByCell.leave();       
    }*/
    
    FailOnEmpty(*usersByCell &= usersByCellAux); 
    FailOnEmpty(*probBloqByCell &= probBloqByCellAux); 
    return (usersByCell.leave() | probBloqByCell.leave()) ? OZ_SLEEP : OZ_ENTAILED; 
    failure:
      probBloqByCell.fail();
      usersByCell.fail();      
      return OZ_FAILED; 
  }
  
  OZ_BI_define(fd_erlangB,4 , 0) 
  { 
    OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_FD","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT); 
    OZ_Expect pe; 
    ExtendedExpect extExp;
    OZ_EXPECT(pe, 0, expectIntVar); 
    OZ_EXPECT(pe, 1, expectIntVar); 
    OZ_EXPECT(pe, 2, expectInt); 
    OZ_EXPECT(pe, 3, expectInt); 
    OZ_EXPECT(pe, 4, expectInt);
     
    int entrada1 = OZ_intToC(OZ_in(2));
    int entrada2 = OZ_intToC(OZ_in(3)); 
    int entrada3 = OZ_intToC(OZ_in(4)); 
    
    //cout<<" Total can"<<entrada3<<endl;  
    //cout<<" Probabilidad ="<<entrada1<<endl;    
    
    
    ////cout<<"\n" <<" pos = "<<OZ_in(3);  
    return pe.impose(new erlangProp
			(OZ_in(0),OZ_in(1),entrada1,entrada2,entrada3)); 

  } OZ_BI_end
        
  OZ_C_proc_interface *oz_init_module(void) 
  {	
    static OZ_C_proc_interface i_table[] = 
    { 
      {"erlang", 5, 0, fd_erlangB}, 
      {0,0,0,0} 
    }; 
    //cout<<"erlang propagator loaded"<<"\n"; 
    return i_table; 
  }
