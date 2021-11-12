#include <iostream.h>
#include "CalcFact.h"
void main(char * argc, int c)
{
  CalcFact cf = CalcFact(10);
  int *f= cf.getFact();
  for(int i=0;i<=10;i++)
  {
    cout<<i<<" ";
  }
}