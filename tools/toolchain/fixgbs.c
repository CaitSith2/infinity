/*
 * Copyright (C) 1999-2001 Affinix Software, LLC
 *
 * This file is part of Infinity.
 *
 * This file may be used under the terms of the Creative Commons Attribution-
 * NonCommercial-ShareAlike 4.0 International License as published by Creative
 * Commons.
 *
 * Alteratively, this file may be used under the terms of the GNU General
 * Public License as published by the Free Software Foundation, either version
 * 3 of the License, or (at your option) any later version.
 *
 * In addition, as a special exception, Affinix Software gives you certain
 * additional rights. These rights are described in the LICENSE file in this
 * package.
 */

#include<stdio.h>
#include<string.h>
#include<memory.h>
#include<malloc.h>

unsigned char *buf;
char title[16] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x80};

#define OP_JP  0xC3;

int find_deadbeef(unsigned char **addr, int size)
{
   int n;
   unsigned char *buf;
   char str[4] = { 0x47, 0x42, 0x53, 0x01 };

   buf = *addr;
   for(n = 0; n < size - 5; ++n) {
      if(!memcmp(buf + n, str, 4)) {
         return n;
      }
   }
   return 0;
}

void main(int argc, char *argv[])
{
   FILE *f;
   unsigned int total;
   int total2;
   unsigned char high, low;
   int size, n, x, dest, len;
   int addr;

   if(argc < 3)
      exit(0);

   f = fopen(argv[1], "r+b");
   if(!f)
      exit(0);
   fseek(f, 0l, SEEK_END);
   size = ftell(f);
   buf = malloc(size);
   if(!buf)
      exit(0);
   rewind(f);
   fread(buf, size, 1, f);
   fclose(f);
   
   f = fopen(argv[2],"wb");
   addr = find_deadbeef(&buf,size);
   printf("addr = %d\nsize = %d\nsize to be written = %d\n",addr,size,size-addr);
   fwrite(buf + addr, 1, size-addr, f);
   fclose(f);

   printf("%s patched\n", argv[1]);
}
