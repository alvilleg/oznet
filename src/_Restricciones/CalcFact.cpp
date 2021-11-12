#include "CalcFact.h"

CalcFact::CalcFact(int n)
{
  this->n = n
}   
CalcFact::~CalcFact(){}

int * CalcFact::getFact()
{  
  int fact[n+1];
  fact[0]=1;
  for (int i=1; i<=n;i++)
  {
    fact[i] = fact[i-1]*i;
  }
  return fact;
}

