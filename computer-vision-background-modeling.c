#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_IDX_OF_IMGS 10 //141
#define N_OF_ROWS 480
#define N_OF_COLUMNS 640

int main()
{
    int arr[N_OF_ROWS][N_OF_COLUMNS] = {0};
    short int firstFile = 1;

    for (int i = 0; i <= MAX_IDX_OF_IMGS; i++)
    {
        char fileDir[50];
        sprintf(fileDir, "C:/Workspace/Programming/mips-assembly/images/%d.pgm", i);

        printf("Reading file %d/%d...\n", i + 1, MAX_IDX_OF_IMGS + 1);

        FILE *filePtr = fopen(fileDir, "r");

        if (!filePtr)
            return -1;

        fseek(filePtr, 15, SEEK_SET);

        for (int row = 0; row < N_OF_ROWS; row++)
        {
            for (int column = 0; column < N_OF_COLUMNS; column++)
            {
                int temp;
                fscanf(filePtr, "%d", &temp);
                if (firstFile)
                {
                    arr[row][column] = temp;
                }
                else
                {
                    arr[row][column] = (temp + arr[row][column]);
                }
            }
        }
        firstFile = 0;
    }

    FILE *outPutFilePtr = fopen("C:/Workspace/Programming/mips-assembly/images/__output.pgm", "w");

    fprintf(outPutFilePtr, "P2\n640 480\n255\n");

    for (int row = 0; row < N_OF_ROWS; row++)
    {
        for (int column = 0; column < N_OF_COLUMNS; column++)
        {
            fprintf(outPutFilePtr, "%d ", arr[row][column] / (MAX_IDX_OF_IMGS + 1));
        }
    }

    return 0;
}