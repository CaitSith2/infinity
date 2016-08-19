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

int find_deadbeef(unsigned char **addr, int size)
{
   int n;
   int warn_load = 0;
   int warn_play = 0;
   int warn_stack = 0;
   
   int load, init, play, stack;
   
   unsigned char *buf;
   char str[4] = { 0x47, 0x42, 0x53, 0x01 };

   buf = *addr;
   for(n = 0; n < size - 5; ++n) {
   	   load = buf[n+6] + (buf[n+7] << 8);
   	   init = buf[n+8] + (buf[n+9] << 8);
   	   play = buf[n+10] + (buf[n+11] << 8);
   	   stack = buf[n+12] + (buf[n+13] << 8);
   	   
   	   warn_load = warn_play = 0;
      if(!memcmp(buf + n, str, 4)) {
      	  if(buf[n+5] > buf[n+4]) continue;	//First song exceeds number of songs, not permitted.
      	  if ((stack < 0xC000) || (stack > 0xDFFF)) continue;	//Stack not in system ram
      	  if (init < load) continue;	//Init address in undefined memory.
      	  if (load >= 0x8000) continue;	//Load address NOT in rom space.
      	  if (init >= 0x8000) continue;	//Init address NOT in rom space.
      	  if (play < load)
      	  {
      	  	  if (play < 0x4000) continue;	//Play address is definitely in undefined memory.
      	  	  warn_play = play;
      	  }
      	  if (load < 0x400) warn_load = load;
      	  if (load >= 0x4000) warn_load = load;
      	  if (play >= 0x8000) warn_play = play;
      	  
      	  
      	  if (warn_load)
      	  {
      	  	  if (load < 0x400)
      	  	  	  printf("Warning: Load address < 0x400; GBS won't be convertable to rom.\n");
      	  	  else
      	  	  	  printf("Warning: Load address NOT in bank 0\n");
      	  }
      	  if (warn_play)
      	  {
      	  	  if (play >= 0x8000)
      	  	  	  printf("Warning: GBS play address located in RAM\n");
      	  	  else
      	  	  	  printf("Warning: Play address less than load address\n");
      	  }
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
