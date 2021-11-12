#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "pruebaRef.h"
using namespace std;

pruebaRef::pruebaRef(int *str){

  int * res;
  cout<< str[2]<<endl;
  res = str;
  res[2] = 1000;
}
