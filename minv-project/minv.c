#include"minv.h"

#define myabs(x) (((x) < 0) ? (-(x)) : (x))

int minv(int *v, int N)
{
  int i;
  int m;

  m = myabs(v[0]);
  for (i=1; i<N; i++)
  {
    if (m > myabs(v[i]))
      m = myabs(v[i]);
  }
  
  return m;
}

