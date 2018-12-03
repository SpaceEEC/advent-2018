#include <stdio.h>
#include <assert.h>
#include <stdlib.h>

#define FILE_NAME "input.txt"

typedef int Element;

typedef struct Node
{
    Element element;
    int count;

    struct Node *right;
    struct Node *left;
} Node;

void exit_mem()
{
    fprintf(stderr, "Error: Out of memory");
    exit(1);
}

Node *new_node(Element e)
{
    Node *node = (Node *)malloc(sizeof(Node));

    if (node == NULL)
        exit_mem();

    node->element = e;
    node->count = 1;
    node->left = NULL;
    node->right = NULL;

    return node;
}

void insert_element(Node **first, Element e)
{
    assert(first != NULL);

    if (*first == NULL)
    {
        *first = new_node(e);
        return;
    }

    if ((*first)->element == e)
    {
        ++(*first)->count;
        return;
    }

    if ((*first)->element > e)
    {
        insert_element(&(*first)->left, e);
        return;
    }

    insert_element(&(*first)->right, e);
}

void insert_coordinates(Node **first, Element x, Element y)
{
    insert_element(first, (x << 16) | y);
}

void dispose_tree(Node *first)
{
    if (first == NULL)
        return;

    dispose_tree(first->right);
    dispose_tree(first->left);

    free(first);
}

void read_input(Node **first)
{
    FILE *f = fopen(FILE_NAME, "rb");

    if (f == NULL)
        return;

    do
    {
        int id;
        int x;
        int y;
        int size_x;
        int size_y;

        int i = 0;
        int j = 0;

        if (fscanf(f, "#%d @ %d,%d: %dx%d\n", &id, &x, &y, &size_x, &size_y) != 5)
            return;

        for (i = x; i < size_x + x; ++i)
            for (j = y; j < size_y + y; ++j)
                insert_coordinates(first, i, j);
    } while (1);
}

void count_duplicates(Node *first, int *count)
{
    if (first == NULL)
        return;

    if (first->count != 1)
        ++*count;

    count_duplicates(first->right, count);
    count_duplicates(first->left, count);
}

int main(void)
{
    Node *first = NULL;
    int count = 0;

    read_input(&first);

    count_duplicates(first, &count);

    fprintf(stdout, "%d\n", count);

    dispose_tree(first);
    first = NULL;

    return 0;
}