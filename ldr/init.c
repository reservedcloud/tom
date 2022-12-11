
#include "x86.h"

VOID BldrEntryPoint(){
	TestX86();
	char* lol = (char*)0xb8000;
	lol[0] = 's';
	lol[2] = 'e';
	lol[4] = 'x';
	
	while(1);
}

