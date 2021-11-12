/***************************************************************************
 *  Autor : Aldemar Villegas
 *  Fecha : Febrero 12 de 2006
 ***************************************************************************/


#include <iostream>
#include <cmath>
#include "mozart_cpi.hh" 
#define FailOnEmpty(X) if((X) == 0) goto failure; 
#define PI 3.14159265 
OZ_BI_proto(fd_azim); 

using namespace std;

class azimProp : public OZ_Propagator 
{ 

  private: 
    static OZ_PropagatorProfile profile;
    OZ_Term _group,_antenna,_anglePpal; 
    int _x1,_x2,_y1,_y2,_dif;

  public:  
   
    azimProp(OZ_Term group,OZ_Term antenna,OZ_Term angle,int x1,int x2,int y1,int y2, int dif );        
    virtual OZ_Return propagate(void);   
    virtual size_t azimProp::sizeOf(void) 
    { 
      return sizeof(azimProp); 
    }

    virtual void azimProp::gCollect(void) 
    {       
      OZ_gCollectTerm(_group);          
      OZ_gCollectTerm(_antenna);          
      OZ_gCollectTerm(_anglePpal);          
    } 
	
	
    virtual void azimProp::sClone(void) 
    { 
      OZ_sCloneTerm(_anglePpal); 
      OZ_sCloneTerm(_group);     
      OZ_sCloneTerm(_antenna);
    }
		
    virtual OZ_Term azimProp::getParameters(void) const 
    {     
      return OZ_cons(_anglePpal, 
                   OZ_cons(_group, 
                           OZ_cons(_antenna, OZ_nil()))); 
    }   	

    virtual OZ_PropagatorProfile *getProfile(void) const 
    { 
      return &profile; 
    } 	
};
  OZ_PropagatorProfile azimProp::profile;
  
  azimProp::azimProp(OZ_Term group,OZ_Term antenna,OZ_Term angle,int x1,int x2,int y1,int y2,int dif) : _group(group),_antenna(antenna), _anglePpal(angle),_x1(x1),_x2(x2),_y1(y1),_y2(y2),_dif(dif)
  {
    _x1   = x1;
    _x2   = x2; 
    _y1   = y1;
    _y2   = y2;
    _dif  = dif;
  } 	
	    	
  OZ_Return azimProp::propagate(void) 
  {     
   
    OZ_FDIntVar  group(_group), antenna(_antenna);
    OZ_FDIntVar angle(_anglePpal); 
    OZ_FiniteDomain groupAux(fd_empty), antennaAux(fd_empty); 
    OZ_FiniteDomain angleAux(fd_empty);
    double angRads,azimRel;    
    double x2Def;
    double y2Def;             
    double dx;//-x1;
    double dy;//-y1;
    int cuadrante,y2,x2,ant,groupAzim,angDegrees;
    int cuantosGrupo =0, ultimoAngulo;
    
    //cout <<" quedan " << angle->getSize();
//     if (angle->getSize() == 1)
//     {
    
    for(int j=angle->getMinElem(); j != -1; j = angle->getNextLargerElem(j))
      {
        //Código que conecta las variables
        // se calcula el azimuth relativo, se incluye en el grupo que corresponda
        // se determina la antena que le da cobertura al punto      
        /**Se trasladan las coordenadas**/       
	      ultimoAngulo = j;
	      x2= _x2-_x1;
      	y2=_y2-_y1;                    
      	/**Se hace la rotación con relación al ángulo principal de azimuth de la radiobase**/    
	      angRads=(j-60)*(PI/180); 
	//cout<<"angulo en radianes "<<angRads<<endl;   
	x2Def= x2*cos(angRads)+y2*sin(angRads);
	//cout<<"x2Def "<<x2Def<<endl; 
	y2Def= -x2*sin(angRads)+y2*cos(angRads);             
	//cout<<"y2Def "<<y2Def<<endl; 
	dx=x2Def;
	//cout<<"4 "<<x2Def<<endl;         
	dy=y2Def;        
	//cout<<"5 "<<y2Def<<endl;        
	
	if(dx==0.0)
          {
            if(dy==0.0)
	      {
		//cout<<"7 "<<endl; 
		cuadrante= 1;
	      }
            if(dy > 0.0) 
	      {
		cuadrante= 2;
		//cout<<"8 "<<endl; 
	      }
            else
	      {
		//cout<<"9 "<<endl; 
		cuadrante= 4;
	      }
          }
	else if(dx > 0.0)
          {
            if(dy>=0.0)
	      {
		//cout<<"10 "<<endl; 
		cuadrante= 1;
	      }
            else
	      {
		//cout<<"11 "<<endl; 
		cuadrante =4;  
	      }
          }

	else if(dx <0.0)
	{
	  if(dy<=0.0)
	  {
 
		cuadrante= 3;
	  }
          else
	  {
		//cout<<"14 "<<angRads<<endl; 
		cuadrante= 2;      
          }
        }
	else
          {
            //cout<<"No debia "<<endl; 
          }
//           cout<<"cuadrante "<<cuadrante<<" x1 "<<_x1<<" y1 "<<_y1<<" x2 "<<x2<<" y2 "<<y2<<"  "<<angRads<<endl;      
          if(dy==0.0 || dx==0.0)
          {
            azimRel= (cuadrante-1)*90;
//             cout<<"sobre los ejes "<<cuadrante<<" azimRel "<<azimRel<<endl;
          }    
	  else
          {
            //cout<<"15 "<<angRads<<endl; 
	    if(cuadrante==1||cuadrante==3){
            	angDegrees = (int)(fabs((atan( dx/dy))*(180/PI)));
            	azimRel= (90*cuadrante - angDegrees);            
	    }else{
            	angDegrees = (int)(fabs((atan( dy/dx))*(180/PI)));
            	azimRel= (90*cuadrante - angDegrees);            
	    }
//             cout<<"cuadrante "<<cuadrante<<" azimRel "<<azimRel<<endl;
          }	      
	
        //cout<<"angDegrees No debe "<<angDegrees<<endl;  
	
//         cout<<"azim Rel "<<azimRel<<endl; 
        groupAzim= (int)(((int)(azimRel)%120)/_dif);      
        //cout<<"no debe groupAzim "<<groupAzim<<endl; 
        ant = (int)(((int)(azimRel) % 360)/120)+1;
	//Siempre se agrega
	angleAux+=j;
        //cout<<"no debe ant "<<ant<<endl; 
        if (group->isIn(groupAzim))
        {
          //cout<<"no debe azimRel "<<azimRel<<endl; 
          //cout<<"agrega al dominio a j "<<j<<endl; 
          angleAux+=j;
          //cout<<"agrega al dominio al grupo "<<groupAzim<<endl; 
          groupAux+=groupAzim;
          //cout<<"no debe azimRel "<<azimRel<<endl; 
          /*if(antenna->isIn(ant))
	    {*/
            //cout<<"agrega antena no debe ant"<<ant<<endl; 
            antennaAux+=ant;
	    //}
          cuantosGrupo++;
        }
      }
   
    //      cout<<"grupo "<<endl; 
      FailOnEmpty(*group &= groupAux); 
      //cout<<"antenna "<<ant<<endl; 
      FailOnEmpty(*antenna &= antennaAux);	
      //cout<<"25 "<<angRads<<endl; 
      FailOnEmpty(*angle &= angleAux);
	             
      //cout <<"cuantosGrupo "<<cuantosGrupo<<endl;
      //cout <<"el angulo es "<<angDegrees<<endl;
      //cout <<"el ultimo angulo es "<<ultimoAngulo<<endl;

      return (group.leave() |antenna.leave()|angle.leave()) ? OZ_SLEEP : OZ_ENTAILED; 
      failure: 
        antenna.fail(); 
        group.fail(); 
        angle.fail();
        return OZ_FAILED; 
//     }
    //cout<<"26 "<<angRads<<endl; 
    //cout<<" grupo "<<group.leave()<<"antena "<<antenna.leave()<<"angle "<<angle.leave()<<endl; 
    
  }
  
  OZ_BI_define(fd_azim,8 , 0) 
  { 
    OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_FD","OZ_EM_FD","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT); 
    OZ_Expect pe; 
    OZ_EXPECT(pe, 0, expectIntVar); 
    OZ_EXPECT(pe, 1, expectIntVar); 
    OZ_EXPECT(pe, 2, expectIntVar); 
    OZ_EXPECT(pe, 3, expectInt);
    OZ_EXPECT(pe, 4, expectInt);
    OZ_EXPECT(pe, 5, expectInt);
    OZ_EXPECT(pe, 6, expectInt);
    OZ_EXPECT(pe, 7, expectInt);  
    
    int entrada3 =OZ_intToC(OZ_in(3));// (OZ_in(3)-14)/16;
    int entrada4 =OZ_intToC(OZ_in(4));// (OZ_in(4)-14)/16;
    int entrada5 =OZ_intToC(OZ_in(5));// (OZ_in(5)-14)/16;
    int entrada6 =OZ_intToC(OZ_in(6));// (OZ_in(6)-14)/16;
    int entrada7 =OZ_intToC(OZ_in(7));// (OZ_in(7)-14)/16;
      
    return pe.impose(
    			new azimProp
			(OZ_in(0), OZ_in(1),OZ_in(2),entrada3,entrada4,entrada5,entrada6,entrada7)); 

  } OZ_BI_end
        
  OZ_C_proc_interface *oz_init_module(void) 
  {	
    static OZ_C_proc_interface i_table[] = 
    { 
      {"azim", 8, 0, fd_azim}, 
      {0,0,0,0} 
    }; 
    printf("azim propagator loaded\n");     
    return i_table; 
  }
