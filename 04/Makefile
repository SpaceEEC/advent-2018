# Pascal
PC			= fpc
P_FLAGS	= -gs -MDelphi

# C
CC			= gcc
CFLAGS		= -c -g -ansi -pedantic -Wall -Wextra -Werror


pascal:
	$(PC) $(P_FLAGS) solution1.pas
	rm solution1.o
	$(PC) $(P_FLAGS) solution2.pas
	rm solution2.o

c:
	$(CC) $(CFLAGS) solution.c
	$(CC) solution.o -o solution
	rm solution.o

clean:
	rm solution1.exe
	rm solution2.exe