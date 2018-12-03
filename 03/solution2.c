#include <stdio.h>
#include <assert.h>
#include <stdlib.h>

#define FILE_NAME "input.txt"

typedef int Element;

typedef struct Node
{
    Element element;
    int *ids;
    int id_count;

    struct Node *right;
    struct Node *left;
} Node;

void exit_mem()
{
    fprintf(stderr, "Error: Out of memory");
    exit(1);
}

Node *new_node(Element e, int id)
{
    Node *node = (Node *)malloc(sizeof(Node));

    if (node == NULL)
        exit_mem();

    node->element = e;
    node->ids = (int *)malloc(sizeof(int));

    if (node->ids == NULL)
        exit_mem();

    node->id_count = 1;
    node->left = NULL;
    node->right = NULL;

    node->ids[0] = id;

    return node;
}

void insert_element(Node **first, Element e, int id)
{
    assert(first != NULL);

    if (*first == NULL)
        *first = new_node(e, id);
    else if ((*first)->element == e)
    {
        ++(*first)->id_count;

        (*first)->ids = realloc((*first)->ids, sizeof(int) * (*first)->id_count);

        if ((*first)->ids == NULL)
            exit_mem();

        (*first)->ids[(*first)->id_count - 1] = id;
    }
    else if ((*first)->element > e)
        insert_element(&(*first)->left, e, id);
    else
        insert_element(&(*first)->right, e, id);
}

void insert_coordinates(Node **first, int id, Element x, Element y)
{
    insert_element(first, (x << 16) | y, id);
}

void dispose_tree(Node *first)
{
    if (first == NULL)
        return;

    dispose_tree(first->right);
    dispose_tree(first->left);

    free(first);
}

int read_input(Node **first)
{
    FILE *f = fopen(FILE_NAME, "rb");
    int last_id = -1;

    if (f == NULL)
    {
        fprintf(stderr, "Error: Could not open file");
        exit(1);
    }

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
            return last_id;

        last_id = id;

        for (i = x; i < size_x + x; ++i)
            for (j = y; j < size_y + y; ++j)
                insert_coordinates(first, id, i, j);
    } while (1);
}

void reduce_claims(Node *first, int *list)
{
    int i = 0;
    if (first == NULL)
        return;

    if (first->id_count != 1)
        for (i = 0; i < first->id_count; ++i)
            ++list[first->ids[i] - 1];

    reduce_claims(first->right, list);
    reduce_claims(first->left, list);
}

int main(void)
{
    Node *first = NULL;
    int *list = NULL;
    int count = read_input(&first);
    int i = 0;

    list = malloc(sizeof(int) * count);

    if (list == NULL)
        exit_mem();

    for (i = 0; i < count; ++i)
        list[i] = 0;

    reduce_claims(first, list);

    for (i = 0; i < count; ++i)
        if (list[i] == 0)
            fprintf(stdout, "%d\n", i + 1);

    dispose_tree(first);
    first = NULL;

    free(list);
    list = NULL;

    return 0;
}