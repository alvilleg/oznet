#include <iostream>
#include <cmath>

#include "mozart_cpi.hh" 
#include "ExtendedExpect.h"
#include "Iterator_OZ_FDIntVar.h" 

#define FailOnEmpty(X) if((X) == 0) goto failure; 


using namespace std;

OZ_BI_proto(fd_interference); 


class InterferenceProp : public OZ_Propagator { 


private: 
	static OZ_PropagatorProfile profile;
	OZ_Term* _signal;
	OZ_Term* _cocanal;
	OZ_Term  _thisSignal;
	OZ_Term  _objetive;
	int      _offset;
	int      _signal_size;
	int      _cocanal_size;
	int      _umbral;
	int 	_index;	 
	 
public: 
	InterferenceProp(OZ_Term thisSignal, OZ_Term signal, OZ_Term cocanal, OZ_Term objetive, int offset, int umbral,int index) :
		_thisSignal(thisSignal), _objetive(objetive),
		_umbral(umbral), _offset(-offset),
		_signal_size(OZ_vectorSize(signal)), 
		_cocanal_size(OZ_vectorSize(cocanal)),
		_index(index)
	{ 
		_signal = OZ_hallocOzTerms(_signal_size);
		OZ_getOzTermVector(signal, _signal); 
		
		_cocanal = OZ_hallocOzTerms(_cocanal_size);
		OZ_getOzTermVector(cocanal, _cocanal); 
	} 


	virtual size_t sizeOf(void) { 
		return sizeof(InterferenceProp); 
	} 
	
	
	virtual OZ_PropagatorProfile *getProfile(void) const { 
		return &profile; 
	} 
	
	
	virtual OZ_Term getParameters(void) const
	{
		
		OZ_Term listSignal = OZ_nil(); 
		OZ_Term listCocanal = OZ_nil(); 
		
		for (int i = _signal_size; i--; ) listSignal = OZ_cons(_signal[i], listSignal); 
		for (int i = _cocanal_size; i--; ) listCocanal = OZ_cons(_cocanal[i], listCocanal);
		
		return  OZ_cons(_thisSignal, 
			    OZ_cons(listSignal, 
				OZ_cons(listCocanal, 
				    OZ_cons(_objetive, 
					OZ_cons(_offset,
					    OZ_cons(_umbral, OZ_nil())))))); 
	}
	
	
	virtual void gCollect(void){
		OZ_gCollectTerm(_objetive); 
		OZ_gCollectTerm(_thisSignal);
		_signal = OZ_gCollectAllocBlock(_signal_size, _signal); 
		_cocanal = OZ_gCollectAllocBlock(_cocanal_size, _cocanal); 
	}
	
	
	virtual void sClone(void){
		OZ_sCloneTerm(_objetive);
		OZ_sCloneTerm(_thisSignal);
		_signal = OZ_sCloneAllocBlock(_signal_size, _signal); 
		_cocanal = OZ_sCloneAllocBlock(_cocanal_size, _cocanal); 
	}
	
	
	virtual OZ_Return propagate(void){
		OZ_FDIntVar objetive(_objetive);
		OZ_FDIntVar thisSignal(_thisSignal);
		OZ_FiniteDomain objetiveAux(fd_empty);
		
		OZ_FDIntVar signal[_signal_size], cocanal[_cocanal_size]; 
		Iterator_OZ_FDIntVar _SIGNAL(_signal_size, signal); 
		Iterator_OZ_FDIntVar _COCANAL(_cocanal_size, cocanal); 
				
		for (int i = _signal_size; i--; ) signal[i].read(_signal[i]); 
		for (int i = _cocanal_size; i--; ) cocanal[i].read(_cocanal[i]); 
		

		double suma=0;
		//bool print=(_cocanal_size>2);

		for(int i= _signal_size; i --; )   
		{
//       cout<<"CoCanal "<< cocanal[i]->getMinElem()<<" size "<<_signal_size<<endl;
			//if(print)cout<<"CoCanal valida "<<i<<">>>"<<cocanal[i]->getMinElem()<<endl;
			if(cocanal[i]->getMinElem())
			{
				//if(print)cout<<"CoCanal entro a la "<<i<<" ";
				suma += (pow(10.0,(static_cast<double>((signal[i]->getMinElem()-_offset)/10.0))));
				//if(print)cout<<"interfSignal ["<<(signal[i]->getMinElem()-_offset)<<"] Suma ["<<suma<<"]"<<endl;
			}
		}
        
		if(suma > 0){
		
			suma = (10.0*(log(suma)/log(10.0)));
			//if(print)cout<<"actual ["<<(thisSignal->getMinElem()-_offset)<<"] suma ["<<suma<<"]"<<endl;
			//if(print)cout<<"div[ "<<((thisSignal->getMinElem()-_offset)-suma)<<"]"<<" _offset "<<_offset<<" _umbral "<<_umbral<<endl;
			
			//Asigna el valor del flag
			if(((thisSignal->getMinElem()-_offset)-suma) > _umbral)
			{
				if(objetive->isIn(1))
				{    			
        				//if(print)cout<<"Si cumple "<<endl;
					objetiveAux += 1;       
				}  
			}
			else
			{
				if(objetive->isIn(0))
				{    			
					//if(print)cout<<"No cumple"<<endl;
					objetiveAux += 0;       
				}
			}
		}else{
// 		  cout<<"Sin cocanal"<<endl;
			if(objetive->isIn(1))
			{    			
				objetiveAux += 1;       
			}  
		}

		//if(print)cout<<"###########################################"<<endl;		
		FailOnEmpty(*objetive &= objetiveAux);
		return (objetive.leave()) ? OZ_SLEEP : OZ_ENTAILED;

		
		failure: 

			thisSignal.fail(); objetive.fail(); _SIGNAL.fail(); _COCANAL.fail();
			return OZ_FAILED;
	} 
}; 

  OZ_PropagatorProfile InterferenceProp::profile;

  
  OZ_BI_define(fd_interference, 7, 0)
  {   
    OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_VECT OZ_EM_FD","OZ_EM_VECT OZ_EM_FD","OZ_EM_FD","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT); 
    ExtendedExpect extExp;
    
    OZ_EXPECT(extExp, 0, expectIntVar);
    OZ_EXPECT(extExp, 1, expectVectorIntVarAny); 
    OZ_EXPECT(extExp, 2, expectVectorIntVarAny); 
    OZ_EXPECT(extExp, 3, expectIntVar); 
    OZ_EXPECT(extExp, 4, expectInt); 
    OZ_EXPECT(extExp, 5, expectInt);
     
    
    if (OZ_vectorSize(OZ_in(1)) == 0) return extExp.fail();
    if (OZ_vectorSize(OZ_in(2)) == 0) return extExp.fail();
        
    int offset = OZ_intToC(OZ_in(4)); 
    int umbral = OZ_intToC(OZ_in(5)); 
    int index = OZ_intToC(OZ_in(6));
    
    return extExp.impose(new InterferenceProp(OZ_in(0),OZ_in(1),OZ_in(2),OZ_in(3),offset,umbral,index)); 

  } OZ_BI_end

  
  OZ_C_proc_interface *oz_init_module(void) 
  {
    static OZ_C_proc_interface i_table[] = 
	{ 
		{"interference", 7, 0, fd_interference}, 
		{0,0,0,0} 
	}; 
    return i_table; 
  }
