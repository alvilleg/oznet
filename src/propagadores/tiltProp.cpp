/***************************************************************************
 *   Copyright (C) 2006 by alvilleg                                        *
 *                                                                         *
 *   This program is frproee software; you can redistribute it and/or modify  *
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


#include <iostream>
#include <cmath>
#include "mozart_cpi.hh" 

#define FailOnEmpty(X) if((X) == 0) goto failure; 
#define PI 3.141592654

using namespace std;

OZ_BI_proto(fd_tilt); 

class tiltProp : public OZ_Propagator { 
  
private: 
  static OZ_PropagatorProfile profile;
  OZ_Term _tiltAnt, _group; 
  int _heigthRB,_heigthAnt, _distance, _dif;
  int _indexPnt;  
public:  
  
  tiltProp(OZ_Term tiltAnt, OZ_Term group,int hAnt, int hRB,int distance, int dif, int indexPnt) : _tiltAnt(tiltAnt), _group(group), _heigthAnt(hAnt), _heigthRB(hRB),_distance(distance),_dif(dif)
  {
    _heigthRB   = hRB;
    _heigthAnt  = hAnt;
    _distance   = distance;
    _dif        = dif;
    _indexPnt   = indexPnt;
  } 
  
  virtual OZ_Return propagate(void);   
  
  virtual size_t sizeOf(void) 
  { 
    return sizeof(tiltProp); 
  }
  
  
  virtual void gCollect(void) 
  { 
    OZ_gCollectTerm(_tiltAnt); 
    OZ_gCollectTerm(_group);     
  } 
  
  
  virtual void sClone(void) 
  { 
    OZ_sCloneTerm(_tiltAnt);
    OZ_sCloneTerm(_group);
  }
  
  
  virtual OZ_Term getParameters(void) const 
  {     
    return OZ_cons(_tiltAnt, 
		   OZ_cons(_group, 
			   OZ_nil())); 
  } 
  
  virtual OZ_PropagatorProfile *getProfile(void) const 
  { 
    return &profile; 
  } 
  
}; 
OZ_PropagatorProfile tiltProp::profile;



OZ_Return tiltProp::propagate(void) 
{   
//   std::cout<<"Inicia propagador del tilt"<<endl;
  OZ_FDIntVar     tiltAnt(_tiltAnt), group(_group); 
  OZ_FiniteDomain tiltAntAux(fd_empty),groupAux(fd_empty); 	  
  double difH,difD,angRadians; 
  int degrees;
  int groupTmp;
  int cuantosGrupo =0;   
  
  
  for (int i = tiltAnt->getMinElem(); i != -1; i = tiltAnt->getNextLargerElem(i)) 
    {    
      angRadians = i*(PI/180);
      difH = _heigthAnt*(1-sin(M_PI_2-angRadians));
      difD = _heigthAnt*cos(M_PI_2-i);
      degrees =(int)(fabs(atan(( (_heigthRB + (_heigthAnt-difH)) /(_distance-difD))) *(180/PI)));
      groupTmp= (degrees/_dif);
      
      if(group->isIn(groupTmp))  
        {
          groupAux+=groupTmp;
          tiltAntAux+=i;
          cuantosGrupo++;        
        }      
    }       
                            
  FailOnEmpty(*tiltAnt &= tiltAntAux); 
  FailOnEmpty(*group &= groupAux);   
  if((*group &= groupAux)>1)
  {
//     std::cout<<"************TILT *** No quedo determinado "<<(*group &= groupAux)<<" tilt antena "<<(*tiltAnt &= tiltAntAux)<<"_indexPnt = > "<<_indexPnt<<endl;
  }
  return 
    (tiltAnt.leave() | group.leave()) ? OZ_SLEEP : OZ_ENTAILED; 
  
 failure: 
  tiltAnt.fail(); 
  group.fail(); 

  return OZ_FAILED;
}


OZ_BI_define(fd_tilt,7 , 0) { 
  OZ_EXPECTED_TYPE(OZ_EM_FD","OZ_EM_FD","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT","OZ_EM_LIT);   
  
  OZ_Expect pe; 	  
  OZ_EXPECT(pe, 0, expectIntVar); 
  OZ_EXPECT(pe, 1, expectIntVar); 
  OZ_EXPECT(pe, 2, expectInt); 
  OZ_EXPECT(pe, 3, expectInt);
  OZ_EXPECT(pe, 4, expectInt);
  OZ_EXPECT(pe, 5, expectInt);
  OZ_EXPECT(pe, 6, expectInt);
  OZ_Term entrada1 = OZ_intToC(OZ_in(2));
  OZ_Term entrada2 = OZ_intToC(OZ_in(3));
  OZ_Term entrada3 = OZ_intToC(OZ_in(4));
  OZ_Term entrada4 = OZ_intToC(OZ_in(5));
  
  return pe.impose(new tiltProp(OZ_in(0), OZ_in(1),entrada1,entrada2,entrada3,entrada4,OZ_intToC(OZ_in(6)))); 
  
} OZ_BI_end



OZ_C_proc_interface *oz_init_module(void) 
{	
  static OZ_C_proc_interface i_table[] = 
    { 
      {"tilt", 7, 0, fd_tilt}, 
      {0,0,0,0} 
    }; 
  
  printf("tilt propagator loaded\n"); 
  return i_table; 
}
