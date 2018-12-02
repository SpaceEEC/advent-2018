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
	$(CC) $(CFLAGS) solution1.c
	$(CC) solution1.o -o solution1
	rm solution1.o

	$(CC) $(CFLAGS) solution2.c
	$(CC) solution2.o -o solution2
	rm solution2.o

clean:
	rm solution1.exe
	rm solution2.exe