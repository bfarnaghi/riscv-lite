#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main (int argc, char **argv)
{
  int init_val;
  FILE *fp_in;
  FILE *fp_key;
  FILE *fp_out;

  int msg;
  int cnt;
  int key;
  int enc;
  int dec;

  /// command line check
  if (argc != 5)
  {
    printf("Use: %s <group_number> <input_file> <key_file> <output_file>\n", argv[0]);
    exit(1);
  }

  /// read group number and initialize the generator
  init_val = atoi(argv[1]);
  srand(init_val);

  /// open message file
  fp_in = fopen(argv[2], "r");
  if (fp_in == NULL)
  {
    printf("Error: cannot open %s\n");
    exit(2);
  }

  /// open key and output files
  fp_key = fopen(argv[3], "w");
  fp_out = fopen(argv[4], "w");

  /// loop on message file
  cnt = 0;
  while (fscanf(fp_in, "%x", &msg) != EOF)
  {
    /// get new key
    if (cnt == 0)
    {
      key = rand();     
      fprintf(fp_key, "%08x\n", key);
    }

    /// enc
    enc = msg ^ key;
    /// dec
    dec = enc ^ key;
    /// check
    if (dec != msg)
    {
      printf("Error dec=%x is different from msg=%x\n", dec, msg);
      exit(3);
    }
    fprintf(fp_out, "%08x\n", enc);

    /// update counter
    cnt++;
    cnt %= 4;
  }

  fclose(fp_in);
  fclose(fp_key);
  fclose(fp_out);
  return 0;
}
