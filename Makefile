msvc:
		cl /nologo /O2 /Ot /DTEST test.c belt.c
gnu:
		gcc -DTEST -Wall -O2 test.c belt.c -otest	 
clang:
		clang -DTEST -Wall -O2 test.c belt.c -otest	    