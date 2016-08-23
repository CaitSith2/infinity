
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>

unsigned char *buf;
unsigned char gbsheader[4] = { 'G','B','S',1};

int findGBSHeader(int offset)
{
	int i;
	for(i=offset;i<16384;i++)
	{
		if(!memcmp(&buf[i],gbsheader,4))
			return i;
	}
	return -1;
}

int findGBSEnd(int size)
{
	int i=size-1;
	while(buf[i]==0xFF)
		i--;
	return i;
}

int main(int argc, char *argv[])
{
	FILE *f;
	int size;
	int i=-1;
	int gbs_header_valid=0;
	unsigned short load_addr,init_addr,play_addr,stack_pointer;
	unsigned char song_count, first_song;
	
	if (argc < 3)
	{
		printf("Usage: %s [rom file] [gbs file]\n",argv[0]);
		return 1;
	}
	f=fopen(argv[1],"rb");
	if(f==NULL)
	{
		printf("Unable to open input rom file %s\n",argv[1]);
		return 1;
	}
	fseek(f,0,SEEK_END);
	size=ftell(f);
	fseek(f,0,SEEK_SET);
	buf=(unsigned char*)malloc(size);
	if(buf==NULL)
	{
		printf("Unable to create buffer\n");
		fclose(f);
		return 1;
	}
	fread(buf,1,size,f);
	fclose(f);
	do
	{
		i=findGBSHeader(i+1);
		if(i>=0)
		{
			song_count=buf[i+4];
			first_song=buf[i+5];
			if(first_song > song_count) continue;
			
			memcpy(&load_addr,&buf[i+6],2);
			if(load_addr != (i+0x70)) continue;
			if(load_addr >= 0x4000) continue;
			
			memcpy(&init_addr,&buf[i+8],2);
			if(init_addr < load_addr) continue;
			if(init_addr >= 0x8000) continue;

			memcpy(&play_addr,&buf[i+10],2);
			if(play_addr < load_addr) continue;
			if(play_addr >= 0x8000) continue;
			
			memcpy(&stack_pointer,&buf[i+12],2);
			if(stack_pointer<0x8000) continue;
			
			gbs_header_valid = 1;
		}
	} while (!gbs_header_valid && i >= 0);
	if(!gbs_header_valid)
	{
		printf("Unable to find a valid GBS header within the rom\n");
		return 1;
	}
	fopen(argv[2],"wb");
	if(f==NULL)
	{
		printf("Unable to open output gbs file %s\n",argv[2]);
		return 1;
	}
	
	fwrite(&buf[i],1,findGBSEnd(size)-i,f);
	fclose(f);
	printf("GBS File %s written\n",argv[2]);
	return 0;
}
