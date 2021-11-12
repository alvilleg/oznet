#include "CalcFact.h"
#include <iostream>

using namespace std;

CalcFact::CalcFact(long int n)
{
  cout<<"inicia"<<endl;
  this->n = n;
  cout<<"termina"<<endl;
}   
CalcFact::~CalcFact(){}

void CalcFact::getFact(long int *fact)
{    
  cout<<"inicia calculo "<<fact[0] <<endl;
  fact[0]=1;
  cout<<"asigno el 0" <<endl;
  cout<<" Tamano "<<sizeof(long int)<<endl;
  for (long int i=1; i<=n;i++)
  {
    cout<<"en el calculo"<<i<<endl;
    fact[i] = fact[i-1]*i;
   // cout <<fact[i]<<" "<<endl;
  }
  cout<<"termina calculo"<<endl;
  //cout <<endl;  
}

