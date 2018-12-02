#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#define INPUT_FILE "input.txt"
#define LINE_LENGTH 27
#define INITIAL_LINE_COUNT 8

typedef enum ErrorCode
{
    /* everything as expected */
    ERR_NONE = 0,
    /* the file could not be opened or an error occured during reading */
    ERR_FILE,
    /* out of memory */
    ERR_MEM,
    /* did not find a pair of ids */
    ERR_NOT_FOUND
} ErrorCode;

/**
 * Prints the with the error code associated string to stderr.
 * 
 * @param[in] error The error code to print.
 **/
void print_error(ErrorCode error);
/**
 * Reads all lines into a char array.
 * 
 * @param[in,out] f Pointer to opened file handle.
 * @param[out] lines Pointer to array of read chars.
 * @param[out] lines_count Pointer to amount of lines read.
 * 
 * @pre f != NULL
 * @pre lines != NULL
 * @pre *lines == NULL
 * @pre lines_count != NULL
 * 
 * @returns A non 0 error if something went wrong.
 **/
ErrorCode read_all_lines(FILE *f, char **lines, int *lines_count);
/**
 * Finds the two strings which differs by one char.
 * If no pair was found str1 and str2 will remain unchanged.
 * 
 * @param[in] lines Array of characters to read
 * @param[in] lines_count Amount of lines in `lines`.
 * @param[out] str1 The first id
 * @param[out] str2 The second id
 * 
 * @pre lines != NULL
 * @pre str1 != NULL
 * @pre str2 != NULL
 **/
void find_diff_str(const char *lines, int lines_count, const char **str1, const char **str2);
/**
 * Compares two strings and returns the amount of differing chars.
 * 
 * @param[in] str1 The first id
 * @param[in] str2 The second id
 * 
 * @pre lines != NULL
 * @pre str1 != NULL
 * @pre str2 != NULL
 * 
 * @returns The amount of differing chars
 **/
int string_diff(const char *str1, const char *str2);
/**
 * Gets the final string, getting rid of the differing char.
 * 
 * @param[out] out The final id
 * @param[in] str1 The first id
 * @param[in] str2 The second id
 * 
 * @pre out != NULL
 * @pre str1 != NULL
 * @pre str2 != NULL
 **/
void extract_string(char *out, const char *str1, const char *str2);

int main(void)
{
    ErrorCode error = ERR_NONE;
    FILE *f = fopen(INPUT_FILE, "rb");
    int lines_count = INITIAL_LINE_COUNT;
    char *lines = NULL;

    if (f == NULL)
        error = ERR_FILE;

    if (!error)
        error = read_all_lines(f, &lines, &lines_count);

    if (!error)
    {
        const char *str1 = NULL;
        const char *str2 = NULL;

        find_diff_str(lines, lines_count, &str1, &str2);

        if (str1 && str2)
        {
            char res[LINE_LENGTH] = {0};
            extract_string(res, str1, str2);

            fprintf(stdout, "%s\n", res);
        }
        else
            error = ERR_NOT_FOUND;
    }

    if (f != NULL)
        fclose(f);

    if (lines != NULL)
        free(lines);

    if (error)
        print_error(error);

    return error;
}

void print_error(ErrorCode error)
{
    switch (error)
    {
    case ERR_NONE:
        break;

    case ERR_FILE:
        fprintf(stderr, "%s\n", "Error: Could not open or read file, or it was in an incorrect format.");
        break;

    case ERR_MEM:
        fprintf(stderr, "%s\n", "Error: Not enough memory available.");
        break;

    case ERR_NOT_FOUND:
        fprintf(stderr, "%s\n", "Error: Did not find a pair of ids.");
        break;
    }
}

ErrorCode read_all_lines(FILE *f, char **lines, int *lines_count)
{
    int actual_lines_count = 0;

    assert(f != NULL);
    assert(lines != NULL);
    assert(*lines == NULL);
    assert(lines_count != NULL);

    *lines = malloc(LINE_LENGTH * *lines_count);

    if (lines == NULL)
        return ERR_MEM;

    do
    {
        char *line = *lines;
        line += actual_lines_count * LINE_LENGTH;

        if (fscanf(f, "%26s", line) != 1)
            break;

        ++actual_lines_count;

        if (actual_lines_count >= *lines_count)
        {
            *lines_count *= 2;
            *lines = realloc(*lines, LINE_LENGTH * *lines_count);

            if (*lines == NULL)
                return ERR_MEM;
        }
    } while (1);

    *lines = realloc(*lines, LINE_LENGTH * actual_lines_count);
    if (*lines == NULL)
        return ERR_MEM;
    *lines_count = actual_lines_count;

    return ERR_NONE;
}

void find_diff_str(const char *lines, int lines_count, const char **str1, const char **str2)
{
    const char *first;
    int i = 0;

    assert(lines != NULL);
    assert(str1 != NULL);
    assert(str2 != NULL);

    if (lines_count == 0)
        return;

    first = lines;

    lines += LINE_LENGTH;

    for (i = 0; i < lines_count - 1; ++i)
    {
        int offset = i * LINE_LENGTH;
        if (string_diff(first, lines + offset) == 1)
        {
            *str1 = first;
            *str2 = lines + offset;

            return;
        }
    }

    find_diff_str(lines, lines_count - 1, str1, str2);
}

int string_diff(const char *str1, const char *str2)
{
    int diff = 0;

    assert(str1 != NULL);
    assert(str2 != NULL);

    while (*str1 && *str2)
    {
        if (*str1 != *str2)
            ++diff;

        ++str1;
        ++str2;
    }

    return diff;
}

void extract_string(char *out, const char *str1, const char *str2)
{
    int index = 0;

    assert(out != NULL);
    assert(str1 != NULL);
    assert(str2 != NULL);

    while (*str1 && *str2)
    {
        if (*str1 == *str2)
            out[index++] = *str1;

        ++str1;
        ++str2;
    }
}