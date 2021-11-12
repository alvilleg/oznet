#include "CalcFact.h"
#include "constantStruct.h"
#include "pruebaRef.h"

using namespace std;
int main(char * argc, int c)
{
 
  int str[4] = {1,2,3,4};
  pruebaRef pRef= pruebaRef(str);
  cout<<str[2]<<endl;
  
  /*for(int i=0;i<=100;i++)
  {
    //cout<<i<<" "<<f[i]<<endl;
    str[i]=i;
    std::cout<<i<<"  "<<str[i]<<endl;
    //f++;
}*/
  return 0;
}
