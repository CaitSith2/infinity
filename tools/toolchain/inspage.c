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

char buf[16384];

void main(int argc, char *argv[])
{
	FILE *f;
	int pagenum;

	if(argc < 4)
		exit(0);

	pagenum = atoi(argv[3]);

	f = fopen(argv[2], "rb");
	if(!f)
		exit(0);
	fread(buf, 16384, 1, f);
	fclose(f);

	f = fopen(argv[1], "r+b");
	if(!f)
		exit(0);
	fseek(f, pagenum * 16384, SEEK_SET);
	fwrite(buf, 16384, 1, f);
	fclose(f);

	printf("Wrote %s into page %d.\n", argv[2], pagenum);
}
