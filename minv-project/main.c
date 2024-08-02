//#define IS86

#ifdef IS86
#include <stdio.h>
#endif
#include "minv.h"

#define N 7

int v[N] = {9, -46, 21, -2, 14, 26, -3};
volatile int m;

int main()
{

  m = minv(v, N);

#ifdef IS86
  printf("%d\n", m);
#endif
  return 0;
}
