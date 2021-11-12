#include <iostream>
#include <cmath>

#include "mozart_cpi.hh"
#include "ExtendedExpect.h"
#include "Iterator_OZ_FDIntVar.h" 
#include "ErlangB.h"


#define FailOnEmpty(X) if((X) == 0) goto failure;


using namespace std;

OZ_BI_proto(fd_bloqueo); 


class BloqueoProp : public OZ_Propagator { 


private: 
	static OZ_PropagatorProfile profile;
	
	//ErlangB* _erlangB;
	OZ_Term  _objetive;

	int    _size;
	int    _umbral;
	int*   _canales;
	int*   _pob_antena;
	double * _trafico;
  double _maxTrafico;
public:

	BloqueoProp(int pob_Punto[], int rbs_Punto[], int ant_Punto[], int size_Punto[], int  canales[],
                             int intTrafEnt[], int intTrafDec[], OZ_Term objetive, int umbral,int size,int puntoSize, int antPuntoSize, double maxTrafico, int vecinas[]): _objetive(objetive),  _canales(canales)
	{
	 //cout<<"Constructor bloqueo "<<endl;     
		_size = size;
		_umbral = umbral;
		//_erlangB = new ErlangB();
		_maxTrafico = maxTrafico;
		//Pasa a double la intensidad de tr'afico de los puntos
		double tmp;
		double * intTrafico;
		intTrafico = new double[puntoSize];

		//transforma a double el valor obtenido
		if (puntoSize != 0) 
			for(int i=puntoSize; i--; ){
				tmp = intTrafDec[i];
				
				while(tmp >= 1) tmp = tmp/10.0;
				
				intTrafico[i] = intTrafEnt[i] + tmp;
			}
		

		
		//Intensidad de tr'afico que soporta la antena
		_trafico = new double[_size];
		for(int i=_size; i--;)  _trafico[i]=0;

		//Calcula la intensidad de trafico para cada antena
		int rb=0;
		int punto=0;
		int antena=0;
		int index = 0;
		int next=size_Punto[punto]-1;
		
		for(int i=0;i<antPuntoSize;i++){
			//Valida si se analiza un nuevo punto
			if(i>next){
				punto++;
				next += size_Punto[punto];
			}
			

			//Determina las radio-base y antena actual
			rb = rbs_Punto[i]-1;
			antena = ant_Punto[i]-1;
			
			//acumula la poblacion del punto
			index = ((rb*3)+antena);
			if(antena >= 0){
			   _trafico[index] += 
			   ( (static_cast<double>(pob_Punto[punto]))/ (static_cast<double>(vecinas[punto])))*intTrafico[punto];
			}
		}
		//cout<<"Termina Constructor bloqueo "<<endl;     
	}


	~BloqueoProp()
	{
		//delete _erlangB;
	}


	virtual size_t sizeOf(void) { 
		return sizeof(BloqueoProp);
	} 
	
	
	virtual OZ_PropagatorProfile *getProfile(void) const {
		return &profile;
	} 


	virtual OZ_Term getParameters(void) const
	{
		return  OZ_cons(_objetive, OZ_nil()); 
	}


	virtual void gCollect(void){
		OZ_gCollectTerm(_objetive); 
		//cout << "gcollect copy erlang" << endl;
		//_erlangB  =  _erlangB->copy();
		//cout << "gcollect fin" << endl;
	}


	virtual void sClone(void){
		OZ_sCloneTerm(_objetive);
		//cout << "clone copy erlang" << endl;
		//_erlangB  =  _erlangB->getRef();
		//cout << "clone fin " << endl;
	}
	

	//OZ_Term canales, OZ_Term poblacion, OZ_Term intTrafico, OZ_Term objetive, int umbral
	virtual OZ_Return propagate(void){
		//cout<<"Propagando ...bloqueo"<<endl;
		OZ_FDIntVar objetive(_objetive);
		OZ_FiniteDomain objetiveAux(fd_empty);
		
		
		int cumple = 0;
		double probBloq = 0;
		double umbralP =  (static_cast<double>(_umbral))/100.0;
    int canalesAux;
		for(int i= _size; i--; )
		{
			canalesAux = _canales[i]/3;
			//probBloq = _erlangB->getProbBloq((_canales[i]/3), _trafico[i]);
			//cout <<"canales  "<< _canales[i] << "  , trafico real"  <<  _trafico[i]<<" trafico maximo " <<_maxTrafico <<"prob bloqueo "<< (probBloq * 100.0) <<endl;
			if(_trafico[i] <= _maxTrafico ) {
				cumple++;
			}
		}
		
		//Lo pasa a porcentaje
		cumple = (static_cast<int>((static_cast<double>(cumple)/_size)*100));

		if(objetive->isIn(cumple))
		{
			objetiveAux += cumple;
		}
//cout<<"Fin Propagando ...bloqueo"<<endl;
		FailOnEmpty(*objetive &= objetiveAux);
		return (objetive.leave()) ? OZ_SLEEP : OZ_ENTAILED;

		
		failure: 

			objetive.fail();
			return OZ_FAILED;
	}


};

  OZ_PropagatorProfile BloqueoProp::profile;


  OZ_BI_define(fd_bloqueo, 12, 0)
  {

    OZ_EXPECTED_TYPE(OZ_EM_VECT OZ_EM_LIT","OZ_EM_VECT OZ_EM_LIT","OZ_EM_VECT OZ_EM_FD","OZ_EM_VECT OZ_EM_LIT","OZ_EM_VECT OZ_EM_LIT","OZ_EM_VECT OZ_EM_LIT","OZ_EM_VECT OZ_EM_LIT","OZ_EM_FD","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_VECT OZ_EM_FD);

    ExtendedExpect extExp;

    OZ_EXPECT(extExp, 0, expectVectorInt);
    OZ_EXPECT(extExp, 1, expectVectorInt);
    OZ_EXPECT(extExp, 2, expectVectorIntVarAny);
    OZ_EXPECT(extExp, 3, expectVectorInt);
    OZ_EXPECT(extExp, 4, expectVectorInt);
    OZ_EXPECT(extExp, 5, expectVectorInt);
    OZ_EXPECT(extExp, 6, expectVectorInt);
    OZ_EXPECT(extExp, 7, expectIntVar);
    OZ_EXPECT(extExp, 8, expectInt);
    OZ_EXPECT(extExp, 9, expectInt);
    OZ_EXPECT(extExp, 10, expectInt);
    OZ_EXPECT(extExp, 11, expectVectorIntVarAny);

    if (OZ_vectorSize(OZ_in(0)) == 0) return extExp.fail();
    if (OZ_vectorSize(OZ_in(1)) == 0) return extExp.fail();
    if (OZ_vectorSize(OZ_in(2)) == 0) return extExp.fail();
    if (OZ_vectorSize(OZ_in(3)) == 0) return extExp.fail();
    if (OZ_vectorSize(OZ_in(4)) == 0) return extExp.fail();
    if (OZ_vectorSize(OZ_in(5)) == 0) return extExp.fail();
    if (OZ_vectorSize(OZ_in(6)) == 0) return extExp.fail();

   // std::cout<<" antes lectura "<<endl;
    
    int size = OZ_vectorSize(OZ_in(4));
    int puntoSize =  OZ_vectorSize(OZ_in(0));
    int antPuntoSize =  OZ_vectorSize(OZ_in(2));

    int pob_Punto[puntoSize];//  = new int[puntoSize];
    int rbs_Punto[antPuntoSize];
    int ant_Punto[antPuntoSize];
    int size_Punto[puntoSize];
    int canales[size];
    int intTrafEnt[puntoSize];
    int intTrafDec[puntoSize];
    //en cada posici'on i almacena la cantidad de vecinas del punto
    //i
    int vecinasPunto[puntoSize];
//    std::cout<<" 2 "<<endl;
    //Estrae los datos enteros pasados por Oz
    OZ_getCIntVector(OZ_in(0),pob_Punto);
    OZ_getCIntVector(OZ_in(1),rbs_Punto);
    OZ_getCIntVector(OZ_in(3),size_Punto);
    OZ_getCIntVector(OZ_in(4),canales);
    OZ_getCIntVector(OZ_in(5),intTrafEnt);
    OZ_getCIntVector(OZ_in(6),intTrafDec);

// std::cout<<" 3 "<<endl;
    //Extrae los identificadores de antena por punto
    int _antena_size = OZ_vectorSize(OZ_in(2));    
// std::cout<<" 3.1 "<<_antena_size<<endl;
    OZ_Term* _antena = OZ_hallocOzTerms(_antena_size);
    
    OZ_Term* _vecinas= OZ_hallocOzTerms(puntoSize);
    OZ_getOzTermVector(OZ_in(11), _vecinas);
// std::cout<<" 3.2 "<<_antena_size<<endl;    
    OZ_getOzTermVector(OZ_in(2), _antena);
// std::cout<<" 3.3  cambiado"<<_antena_size<<endl;   
     OZ_FDIntVar currentVariable;
// std::cout<<" 4"<<endl;

    for (int i = _antena_size; i--; ) {
	   currentVariable.read(_antena[i]);
	   ant_Punto[i] = currentVariable->getMinElem();	
    }
     
    for (int i = puntoSize; i--; ) {     
	   currentVariable.read(_vecinas[i]);
	   vecinasPunto[i] = currentVariable->getMinElem();	
    }
 std::cout<<" 5"<<endl;
    //Obtiene el umbral
    int umbral = OZ_intToC(OZ_in(8));
    double maxTraffic = static_cast<double>(OZ_intToC(OZ_in(9)))+ static_cast<double>(OZ_intToC(OZ_in(10)))/100.0 ;
    
//     std::cout<<" Max trafico "<<maxTraffic<<endl;
//     std::cout<<" final prob bloq"<<maxTraffic<<endl;
    return extExp.impose(
                        new BloqueoProp(pob_Punto, rbs_Punto, ant_Punto, size_Punto, canales,
                                                     intTrafEnt,  intTrafDec,OZ_in(7),umbral,size,puntoSize,antPuntoSize,maxTraffic,vecinasPunto));

  } OZ_BI_end


  OZ_C_proc_interface *oz_init_module(void) 
  {
    static OZ_C_proc_interface i_table[] =
	{
		{"bloqueo", 12, 0, fd_bloqueo},
		{0,0,0,0}
	};
    return i_table;
  }
