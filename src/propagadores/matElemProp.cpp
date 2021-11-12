/***************************************************************************
 *  Autor : Aldemar Villegas
 *  Fecha : Febrero 12 de 2006
 ***************************************************************************/


#include <iostream>
#include <cmath>
#include "mozart_cpi.hh" 
//#include "constantStruct.h"
#include "ExtendedExpect.h"

#define FailOnEmpty(X) if((X) == 0) goto failure; 

OZ_BI_proto(fd_matElem); 

using namespace std;

class matElemProp : public OZ_Propagator 
{ 

  private: 
    static OZ_PropagatorProfile profile;
    OZ_Term _indexRow,_indexCol,_value; 
    //constantStruct *cs;
    int _distTipo;
    int * _gain_info;
    int matPrueba[5][5];
    int tilts,azimuths,distances;
  public:  

    matElemProp::matElemProp(OZ_Term indexRow,OZ_Term indexCol,OZ_Term value,int distTipo ,int *gains_info,int numDist, int numTilts,int numAzims) :         
      _indexRow (indexRow),
      _indexCol(indexCol),
      _value(value),
      _distTipo(distTipo)     
    { 
      tilts =numTilts;
      azimuths=numAzims;
      distances=numDist;
      
      _gain_info = new int[distances*tilts*azimuths];
      for(int i=(distances*tilts*azimuths);i--;)
      {
        _gain_info[i] = gains_info[i];
      }
    }
    
    ~matElemProp()
    {
      //delete cs;
    }
     
    virtual OZ_Return propagate(void);   
    virtual size_t matElemProp::sizeOf(void) 
    { 
      return sizeof(matElemProp); 
    }

    virtual void matElemProp::gCollect(void) 
    {       
      OZ_gCollectTerm(_indexRow);          
      OZ_gCollectTerm(_indexCol);          
      OZ_gCollectTerm(_value);       
      //cs = cs->copy();
    } 
	
	
    virtual void matElemProp::sClone(void) 
    { 
      OZ_sCloneTerm(_indexRow); 
      OZ_sCloneTerm(_indexCol); 
      OZ_sCloneTerm(_value);
      //cs = cs->getRef();
    }
		
    virtual OZ_Term matElemProp::getParameters(void) const 
    {     
      OZ_Term listChars = OZ_nil();       
      return OZ_cons(_indexRow, 
                     OZ_cons(_indexCol, 
                             OZ_cons(_value, 
        
                                             OZ_nil()))); 
    }   	

    virtual OZ_PropagatorProfile *getProfile(void) const 
    { 
      return &profile; 
    } 	
};
  OZ_PropagatorProfile matElemProp::profile;	
	  
      	
  OZ_Return matElemProp::propagate(void) 
  {     
    OZ_FDIntVar  indexRow(_indexRow), indexCol(_indexCol),value(_value);    
    OZ_FiniteDomain indexRowAux(fd_empty), indexColAux(fd_empty),valueAux(fd_empty);         

    for(int i=indexRow->getMinElem(); i != -1; i = indexRow->getNextLargerElem(i))
      {
        for(int j=indexCol->getMinElem(); j != -1; j = indexCol->getNextLargerElem(j))
        {
          int index = (_distTipo*tilts*azimuths)+(i*azimuths)+j;
          //cout<<"index "<<index<<endl;
          int valueT= _gain_info[index]; 
//           cout<< "Valor obtenido tipo dist "<<_distTipo<<" i "<<i<<" j "<<j<<"index "<<index<<" size "<<(distances*tilts*azimuths)<<" valor "<<valueT<<endl;
          if(value->isIn(valueT))
          {
            valueAux+=valueT;            
            indexColAux+=j;
            indexRowAux+=i;   
          }          
        }             
      }        
//       cout<< "Value"<<(*value &= valueAux)<<endl;
//       cout<< "row"<<(*indexRow &= indexRowAux)<<endl;
//       cout<< "col"<<(*indexCol &= indexColAux)<<endl;
      FailOnEmpty(*value &= valueAux);
      FailOnEmpty(*indexRow &= indexRowAux);	
      FailOnEmpty(*indexCol &= indexColAux);
      return (value.leave()|indexRow.leave()|indexCol.leave()) ? OZ_SLEEP : OZ_ENTAILED; 

      failure: 
        value.fail(); 
        indexRow.fail(); 
        indexCol.fail();
        return OZ_FAILED; 

    
  }
  
  /*
    Parametros 
      1 : Varible de dominios finitos para la fila
      2 : Varible de dominios finitos para la Columna
      3 : Varible de dominios finitos donde se pone el resultado
      4 : Tipo de distancia en la que se va a buscar
      5 : Informaci'on de las ganancias en un vector de 3 dimensiones aplanado      
      6 : Numero de tipos de distancia
      7 : N'umero de tipos de tilt
      8 : Numero de tipos de azimuth
  */
  OZ_BI_define(fd_matElem,8 , 0) 
  { 
    OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_FD","OZ_EM_FD","OZ_EM_LIT","OZ_EM_VECT OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT); 
    ExtendedExpect pe; 
    OZ_EXPECT(pe, 0, expectIntVar); 
    OZ_EXPECT(pe, 1, expectIntVar); 
    OZ_EXPECT(pe, 2, expectIntVar);
    OZ_EXPECT(pe, 3, expectInt);                 
    OZ_EXPECT(pe, 4, expectVectorInt);
                    
    int distTipo    =OZ_intToC(OZ_in(3));   
    int numDists  =OZ_intToC(OZ_in(5));   
    int numTilts  =OZ_intToC(OZ_in(6));   
    int numAzims  = OZ_intToC(OZ_in(7));   
    int gains_info[numDists*numTilts*numAzims]; 
    
    int size_of_Vector = OZ_vectorSize(OZ_in(4));
    
    //cout<<" size "<<size_of_Vector<<" mult "<<numDists*numTilts*numAzims<<endl;
    
    OZ_getCIntVector(OZ_in(4),gains_info);
    
    return pe.impose(
        new matElemProp
        (OZ_in(0), OZ_in(1),OZ_in(2),distTipo, gains_info,numDists,numTilts,numAzims)); 

  } OZ_BI_end
        
  OZ_C_proc_interface *oz_init_module(void) 
  {	
    static OZ_C_proc_interface i_table[] = 
    { 
      {"matElem", 8, 0, fd_matElem}, 
      {0,0,0,0} 
    }; 
    std::cout<<"maElem propagator loaded\n";     
    return i_table; 
  }
