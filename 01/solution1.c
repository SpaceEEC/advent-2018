#include <stdio.h>

int main(void)
{
    FILE* f = fopen("input.txt", "rb");
    int acc = 0;
    
    if (f == NULL) {
        fprintf(stdout, "Error: File could not be opened.");

        return 1;
    }

    do
    {
        int element = -1;
        if (fscanf(f, "%d", &element) == EOF)
            break;

        acc += element;
    } while(1);

    fprintf(stdout, "%d\n", acc);

    return 0;
}