#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct Node
{
    int element;
    struct Node *right;
    struct Node *left;
} Node;

typedef int Element;

typedef enum ErrorCode
{
    /* everything as expected */
    ERR_NONE = 0,
    /* the element existed already */
    ERR_ALREADY,
    /* the file could not be opened or an error occured during reading */
    ERR_FILE,
    /* out of memory */
    ERR_MEM
} ErrorCode;

ErrorCode new_node(Element e, Node **node)
{
    *node = (Node *)malloc(sizeof(Node));

    if (*node == NULL)
        return ERR_MEM;

    (*node)->element = e;
    (*node)->left = NULL;
    (*node)->right = NULL;

    return ERR_NONE;
}

ErrorCode try_insert_element(Node **first, Element e)
{
    assert(first != NULL);

    if (*first == NULL)
    {
        return new_node(e, first);
    }

    if ((*first)->element == e)
        return ERR_ALREADY;
    else if ((*first)->element > e)
        return try_insert_element(&(*first)->left, e);
    else
        return try_insert_element(&(*first)->right, e);
}

void dispose_tree(Node **first)
{
    assert(first != NULL);

    if ((*first)->right)
        dispose_tree(&(*first)->right);

    if ((*first)->left)
        dispose_tree(&(*first)->left);

    free((void *)*first);
    *first = NULL;
}

ErrorCode read_numbers(int **numbers, int *count)
{
    ErrorCode error = ERR_NONE;
    FILE *f = NULL;
    int size = 128;

    assert(numbers != NULL);
    assert(*numbers == NULL);

    f = fopen("input.txt", "rb");
    if (f == NULL)
        return ERR_FILE;

    *numbers = malloc(sizeof(Element) * size);

    do
    {
        int num = 0;

        int read = fscanf(f, "%d", &num);
        if (read == EOF)
            break;

        if (read != 1)
        {
            error = ERR_FILE;
            break;
        }

        (*numbers)[*count] = num;

        ++*count;
        if (*count >= size)
        {
            size *= 2;
            *numbers = realloc(*numbers, sizeof(Element) * size);

            if (*numbers == NULL)
            {
                error = ERR_MEM;
                break;
            }
        }
    } while (1);

    fclose(f);

    if (error)
    {
        if (*numbers)
            free(*numbers);
    }
    else
    {
        *numbers = realloc(*numbers, sizeof(Element) * (*count));

        if (*numbers == NULL)
            return ERR_MEM;
    }

    return error;
}

int handle_error(ErrorCode error)
{
    switch (error)
    {
    case ERR_NONE:
        fprintf(stderr, "%s\n", "Error: Did not find a duplicated entry.");

        return 1;

    case ERR_ALREADY:
        return 0;

    case ERR_FILE:
        fprintf(stderr, "%s\n", "Error: Could not open or read file, or it was in an incorrect format.");
        break;

    case ERR_MEM:
        fprintf(stderr, "%s\n", "Error: Not enough memory available.");
        break;
    }

    return error;
}

int main(void)
{
    ErrorCode error = ERR_NONE;
    Node *first = NULL;
    int *numbers = NULL;
    int count = 0;
    int i = 0;
    int acc = 0;
    int done = 0;

    if (!(error = read_numbers(&numbers, &count)))
    {
        do
        {
            for (i = 0; i < count; ++i)
            {
                acc += numbers[i];

                if ((error = try_insert_element(&first, acc)))
                {
                    done = 1;
                    break;
                }
            }
        } while (!done);
    }

    if (error == ERR_ALREADY)
    {
        fprintf(stdout, "%d\n", acc);
    }

    dispose_tree(&first);
    free(numbers);

    return handle_error(error);
}