/***************************************************************************
 *  Autor : Aldemar Villegas
 *  Fecha : Julio 4 de 2006
 *
 * Esta clase realiza la propagaci'on de las senales de una sola
 * se implementa con el objetivo de eliminar la multiple creaci'on de 
 * propagadores y la copia de la matriz de ganancias.
 ***************************************************************************/


#include <iostream>
#include <cmath>
#include "mozart_cpi.hh" 
#include "Iterator_OZ_FDIntVar.h" 
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
    /** Arreglos paralelos con variables de dominios finitos para 
      senales, tilts y azimuths
    **/
    OZ_Term * _listOfSignals;
    OZ_Term * _listOfTilts;
    OZ_Term * _listOfAzims;
    
    int  *_distanceTypes;
    int sizeOfLists;
    int distances,tilts,azimuths;   
  public:  

    matElemProp::matElemProp(OZ_Term listOfSignals,OZ_Term listOfTilts,OZ_Term listOfAzims,int *distanceTypes ,int *gains_info, int d, int t , int az)
    {
      //cout<<"Constructor matElem "<<endl;     
      //cs=new constantStruct(gains_info,numDist,numTilts,numAzims);    
      sizeOfLists=OZ_vectorSize(listOfSignals);
      _distanceTypes = new int[sizeOfLists];
      for(int i=sizeOfLists;i--;)
      {
         //std::cout<<"lee las distancias "<<i<<" valor "<<distanceTypes[i]<<endl;
        _distanceTypes[i] = distanceTypes[i];  
      }
      _gain_info = new int[d*t*az];
      for(int i=(d*t*az);i--;)
      {
        _gain_info[i] = gains_info[i];
      }
      sizeOfLists=OZ_vectorSize(listOfSignals);
      _listOfSignals =  OZ_hallocOzTerms(sizeOfLists);  
      OZ_getOzTermVector(listOfSignals, _listOfSignals);
      
      _listOfTilts =  OZ_hallocOzTerms(sizeOfLists);  
      OZ_getOzTermVector(listOfTilts, _listOfTilts);
      
      _listOfAzims =  OZ_hallocOzTerms(sizeOfLists);  
      OZ_getOzTermVector(listOfAzims, _listOfAzims);
      
      distances = d;
      tilts = t;
      azimuths = az;
      //cout<<"Termina Constructor matElem "<<endl;     
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
      _listOfSignals = OZ_gCollectAllocBlock(sizeOfLists, _listOfSignals);
      _listOfTilts = OZ_gCollectAllocBlock(sizeOfLists, _listOfTilts); 
      _listOfAzims = OZ_gCollectAllocBlock(sizeOfLists, _listOfAzims); 
      
    } 
	
	
    virtual void matElemProp::sClone(void) 
    { 
      _listOfSignals = OZ_sCloneAllocBlock(sizeOfLists, _listOfSignals);
      _listOfTilts = OZ_sCloneAllocBlock(sizeOfLists, _listOfTilts); 
      _listOfAzims = OZ_sCloneAllocBlock(sizeOfLists, _listOfAzims); 
    }
		
    virtual OZ_Term matElemProp::getParameters(void) const 
    {     
      OZ_Term list=OZ_nil();       
      for (int i = sizeOfLists; i--; )
	       list = OZ_cons(_listOfSignals[i], list);
	    for (int i = sizeOfLists; i--; )
	       list = OZ_cons(_listOfTilts[i], list);
	    for (int i = sizeOfLists; i--; )
	       list = OZ_cons(_listOfAzims[i], list); 
      return list;
    }

    virtual OZ_PropagatorProfile *getProfile(void) const 
    { 
      return &profile; 
    } 	
};
  OZ_PropagatorProfile matElemProp::profile;	
	  
      	
  OZ_Return matElemProp::propagate(void) 
  {     
    
    int currentTypeDist =0,value=0;
    bool valueFind=false;

    OZ_FDIntVar listOfSignals[sizeOfLists];
    Iterator_OZ_FDIntVar Signals(sizeOfLists,listOfSignals );

    OZ_FDIntVar listOfTilts[sizeOfLists];
    Iterator_OZ_FDIntVar Tilts(sizeOfLists,listOfTilts );

    OZ_FDIntVar listOfAzims[sizeOfLists];
    Iterator_OZ_FDIntVar Azims(sizeOfLists,listOfAzims );

     //std::cout<<"llena las estructuras "<<endl;
    for (int i = sizeOfLists; i--; )
    {
      listOfSignals[i].read(_listOfSignals[i]);	
      listOfTilts[i].read(_listOfTilts[i]);	 
      listOfAzims[i].read(_listOfAzims[i]);	   
    }

    /*****/
//     std::cout<<"*********inicia ciclo principal ****"<<sizeOfLists<<endl;
    for(int i= 0 ; i< sizeOfLists;i++)
      {
        /**Se recorren todos los elementos de las listas paralelas**/
	
        currentTypeDist = _distanceTypes[i];
        OZ_FDIntVar currentSignal( listOfSignals[i]);
        OZ_FDIntVar currentTilt( listOfTilts[i]);
        OZ_FDIntVar currentAzim( listOfAzims[i]);

        OZ_FiniteDomain currSigAux(fd_empty);
        OZ_FiniteDomain currTilAux(fd_empty);
        OZ_FiniteDomain currAziAux(fd_empty);

        OZ_FiniteDomain currSigAux2(fd_empty);
        OZ_FiniteDomain currTilAux2(fd_empty);
        OZ_FiniteDomain currAziAux2(fd_empty);
        //std::cout<<"********* ciclo de variables ****"<<_distanceTypes[i]<<endl;
//          std::cout<<"*********Tamano ***"<<currentSignal->getSize()<<endl;
        if (currentSignal->getSize()>1 )
        {
          for(int t=currentTilt->getMinElem(); t!=-1;t=currentTilt->getNextLargerElem(t))
          {
            for(int a=currentAzim->getMinElem();a!=-1;a=currentAzim->getNextLargerElem(a))
            {
              //std::cout<<"********* index****"<<(currentTypeDist*tilts*azimuths)+(t*azimuths)+a<<endl;
              value = _gain_info[(currentTypeDist*tilts*azimuths)+(t*azimuths)+a];
              //std::cout<<"********* 4 ****"<<value<<endl;
              if (currentSignal->isIn(value))
              {
//                  std::cout<<"distancia "<<currentTypeDist<<" tilt"<<t<<" azimuth "<<a<<"--> el valor esta"<<value<<endl;
                 currSigAux+=value;
                 currTilAux+=t;
                 currAziAux+=a;
              }
            }
          }
          FailOnEmpty(*currentSignal &= currSigAux);
          FailOnEmpty(*currentTilt &= currTilAux);	
          FailOnEmpty(*currentAzim &= currAziAux);
        }
      }
      
      return (Signals.leave()|Tilts.leave()|Azims.leave()) ? OZ_SLEEP : OZ_ENTAILED; 

      failure: 
        Signals.fail(); 
        Tilts.fail(); 
        Azims.fail();
        return OZ_FAILED;
  }
  
  /*
    Parametros 
      1 : Array de variables de dominios finitos para las senales
      2 : Array de dominios finitos para los tilt
      3 : Array de dominios finitos para los azimuths
      4 : Array con los Tipos de distancia entra cada punto y radiobase
      5 : Informaci'on de las ganancias en un vector de 3 dimensiones aplanado        
  */
  OZ_BI_define(fd_matElem,8 , 0) 
  { 
    OZ_EXPECTED_TYPE(OZ_EM_VECT OZ_EM_FD","OZ_EM_VECT OZ_EM_FD","OZ_EM_VECT OZ_EM_FD","OZ_EM_VECT OZ_EM_LIT","OZ_EM_VECT OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT); 
    ExtendedExpect pe; 
    OZ_EXPECT(pe, 0, expectVectorIntVarAny);
    OZ_EXPECT(pe, 1, expectVectorIntVarAny);
    OZ_EXPECT(pe, 2, expectVectorIntVarAny);
    OZ_EXPECT(pe, 3, expectVectorInt);                 
    OZ_EXPECT(pe, 4, expectVectorInt);
    OZ_EXPECT(pe, 5, expectInt);
    OZ_EXPECT(pe, 6, expectInt);
    OZ_EXPECT(pe, 7, expectInt);
    int size_of_vector = OZ_vectorSize(OZ_in(4));
    int size_of_dist_vector = OZ_vectorSize(OZ_in(3));
    int gains_info[size_of_vector]; 
    int distance_types[size_of_dist_vector];

    OZ_getCIntVector(OZ_in(3),distance_types);
    OZ_getCIntVector(OZ_in(4),gains_info);
//std::cout<<"llama al constructor"<<endl;
    return pe.impose(
        new matElemProp
        (OZ_in(0), OZ_in(1),OZ_in(2),distance_types, gains_info,OZ_intToC(OZ_in(5)),OZ_intToC(OZ_in(6)),OZ_intToC(OZ_in(7)))); 

  } OZ_BI_end

  OZ_C_proc_interface *oz_init_module(void) 
  {	
    static OZ_C_proc_interface i_table[] = 
    { 
      {"matElem", 8, 0, fd_matElem}, 
      {0,0,0,0} 
    }; 
   // std::cout<<"maElem propagator loaded\n";     
    return i_table; 
  }
