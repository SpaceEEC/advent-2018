#include <stdio.h>
#include <assert.h>

#define INPUT_FILE "input.txt"
#define ARRAY_SIZE ('z' - 'a' + 1)

int read(FILE *f, int *two, int *three)
{
    unsigned int i = 0;
    char res[ARRAY_SIZE] = {0};

    assert(f != NULL);
    assert(two != NULL);
    assert(three != NULL);

    do
    {
        int c = fgetc(f);

        if (c == EOF)
            return EOF;

        if (c == '\n')
            break;

        ++res[c - 'a'];
    } while (1);

    for (i = 0; i < sizeof(res); ++i)
    {
        if (res[i] == 2)
            *two = 1;

        if (res[i] == 3)
            *three = 1;
    }

    return 1;
}

int main(void)
{
    FILE *f = fopen(INPUT_FILE, "rb");
    int two = 0;
    int three = 0;

    if (f == NULL)
    {
        fprintf(stdout, "Error: File could not be opened.");

        return 1;
    }

    do
    {
        int two2 = 0;
        int three2 = 0;
        if (read(f, &two2, &three2) == EOF)
            break;

        two += two2;
        three += three2;
    } while (1);

    fclose(f);

    printf("%d\n", two * three);

    return 0;
}