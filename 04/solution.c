/**
 * Both parts in one file since the difference of the two files would be minimal.
 * 
 * Only difference between both parts is the do_reduce_treeX (X in (1,2)) function.
 **/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define FILE_NAME "input.txt"
#define DATE_LENGTH (10 + 1) /* yyyy-MM-dd */
#define TIME_LENGTH (5 + 1)  /* hh-mm */
#define MINUTES 60
/* plus null terminator */

typedef enum EVENT_TYPE
{
    /* first char of respective strings */
    BEGAN = 'G',
    FELL_ASLEEP = 'f',
    WOKE_UP = 'w'
} EVENT_TYPE;

typedef struct Event
{
    char date[DATE_LENGTH];
    char time[TIME_LENGTH];
    EVENT_TYPE type;
    int guard;
} Event;

void exit_mem()
{
    fprintf(stderr, "Error: Out of memory.");
    exit(1);
}

void read_events(Event **events, int *event_count)
{
    FILE *f = NULL;
    int read_events = 0;

    assert(events != NULL);
    assert(event_count != NULL);

    f = fopen(FILE_NAME, "rb");

    if (f == NULL)
    {
        fprintf(stderr, "Error: Could not open file.");
        exit(1);
    }

    *events = (Event *)malloc(sizeof(Event) * 8);
    if (*events == NULL)
        exit_mem();

    *event_count = 8;

    do
    {
        Event tmp = {0};

        int res = fscanf(f, "[%10s %5s] %cuard #%d", (char *)tmp.date, (char *)tmp.time, (char *)&tmp.type, &tmp.guard);

        if (res == EOF)
            break;

        if (res != 3 && res != 4)
            assert(/* panic */ 0);

        do
        {
            int c = fgetc(f);
            if (c == '\n' || c == EOF)
                break;
        } while (1);

        (*events)[read_events] = tmp;
        ++read_events;

        if (read_events >= *event_count)
        {
            *event_count *= 2;
            *events = realloc(*events, sizeof(Event) * *event_count);

            if (*events == NULL)
                exit_mem();
        }
    } while (1);

    *events = realloc(*events, sizeof(Event) * read_events);
    *event_count = read_events;
}

int compare_events(const void *event1, const void *event2)
{
    int val = strcmp(((Event *)event1)->date, ((Event *)event2)->date);

    if (val == 0)
        return strcmp(((Event *)event1)->time, ((Event *)event2)->time);

    return val;
}

typedef struct Guard
{
    int id;
    int sleep;
    int distribution[MINUTES];

    struct Guard *right;
    struct Guard *left;
} Guard;

Guard *new_guard(int id)
{
    Guard *guard = (Guard *)malloc(sizeof(Guard));
    if (guard == NULL)
        exit_mem();

    memset(guard, 0, sizeof(Guard));
    guard->id = id;

    return guard;
}

void assign_range(Guard *guard, const char *start, const char *stop)
{
    int start_m = 0;
    int stop_m = 0;
    int i = 0;

    assert(guard != NULL);
    assert(start != NULL);
    assert(stop != NULL);

    /* skip "hh:" */
    if (sscanf(start + 3, "%d", &start_m) != 1 || sscanf(stop + 3, "%d", &stop_m) != 1)
        assert(/* panic */ 0);

    for (i = start_m; i < stop_m; ++i)
    {
        ++guard->sleep;
        ++guard->distribution[i];
    }
}

void insert_span(Guard **first, int id, const char *start, const char *stop)
{
    assert(first != NULL);
    assert(start != NULL);
    assert(stop != NULL);

    if (*first == NULL)
    {
        *first = new_guard(id);
        assign_range(*first, start, stop);
    }
    else if ((*first)->id == id)
        assign_range(*first, start, stop);
    else if ((*first)->id > id)
        insert_span(&(*first)->left, id, start, stop);
    else
        insert_span(&(*first)->right, id, start, stop);
}

void dispose_tree(Guard *first)
{
    if (first == NULL)
        return;

    dispose_tree(first->right);
    dispose_tree(first->left);

    free(first);
}

Guard *reduce_tree(Guard *first, Guard *(cmp)(Guard *, Guard *))
{
    Guard *tmp = first;

    assert(first != NULL);
    assert(cmp != NULL);

    if (first->right)
        tmp = cmp(tmp, reduce_tree(first->right, cmp));

    if (first->left)
        tmp = cmp(tmp, reduce_tree(first->left, cmp));

    return tmp;
}

Guard *do_reduce_tree1(Guard *a, Guard *b)
{
    assert(a != NULL);
    assert(b != NULL);

    if (a->sleep > b->sleep)
        return a;

    return b;
}

Guard *do_reduce_tree2(Guard *a, Guard *b)
{
    int i = 0;
    int max = 0;

    assert(a != NULL);
    assert(b != NULL);

    for (i = 0; i < MINUTES; ++i)
        if (a->distribution[i] > max)
            max = a->distribution[i];

    for (i = 0; i < MINUTES; ++i)
        if (b->distribution[i] > max)
            return b;

    return a;
}

void insert_spans(Event *events, int event_count, Guard **guards)
{
    int i = 0;

    assert(events != NULL);
    assert(guards != NULL);

    do
    {
        int guard = 0;

        if (events[i].type != BEGAN)
            assert(/* panic */ 0);

        guard = events[i].guard;

        ++i;
        do
        {
            if (events[i].type == BEGAN)
                break;

            if (events[i].type != FELL_ASLEEP)
                assert(/* panic */ 0);

            if (events[i + 1].type != WOKE_UP)
                assert(/* panic */ 0);

            insert_span(guards, guard, events[i].time, events[i + 1].time);

            i += 2;
        } while (i < event_count);
    } while (i < event_count);
}

int main(void)
{
    /* events read from a file */
    Event *events = NULL;
    int event_count = 0;
    /* guards bst */
    Guard *guards = NULL;
    /* found guard */
    Guard *guard = NULL;
    /* minute index */
    int i = 0;
    /* highest value */
    int max = 0;
    /* highest index / minute */
    int highest = 0;

    read_events(&events, &event_count);

    qsort(events, event_count, sizeof(Event), compare_events);

    insert_spans(events, event_count, &guards);

    /* part 1 */
    guard = reduce_tree(guards, do_reduce_tree1);

    for (i = 0; i < MINUTES; ++i)
    {
        if (guard->distribution[i] > max)
        {
            highest = i;
            max = guard->distribution[i];
        }
    }
    fprintf(stdout, "Part 1: %d\n", guard->id * highest);

    /* part 2 */
    guard = reduce_tree(guards, do_reduce_tree2);

    for (i = 0; i < MINUTES; ++i)
    {
        if (guard->distribution[i] > max)
        {
            highest = i;
            max = guard->distribution[i];
        }
    }
    fprintf(stdout, "Part 2: %d\n", guard->id * highest);

    dispose_tree(guards);
    guards = NULL;

    free(events);
    events = NULL;

    return 0;
}
