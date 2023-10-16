#include <stdio.h>
#include <string.h>
#include <omp.h>
#define N (2048)

float sum;
float a[N][N];
float b[N][N];
float c[N][N];

void matmul()
{
	
	int	i, j, k;
	#pragma omp parallel private(i,j,k)
    #pragma omp for schedule(static, N/omp_get_num_procs())
	for (i = 0; i < N; i += 1) {
		for (j = 0; j < N; j += 1) {
			a[i][j] = 0;
			for (k = 0; k < N; k += 1) {
				a[i][j] += b[i][k] * c[j][k]; //j and k flipped so it loops on col instead of row
			}
		}
	}
}

void init()
{
	int	i, j;

	for (i = 0; i < N; i += 1) {
		for (j = 0; j < N; j += 1) {
			b[i][j] = 12 + i * j * 13;
			c[i][j] = -13 + i + j * 21;
		}
	}
}

void check()
{
	int	i, j;

	for (i = 0; i < N; i += 1)
		for (j = 0; j < N; j += 1)
			sum += a[i][j];
	printf("sum = %lf\n", sum);
}

void transpose_c_mat(){
	float swap_val;
	for (int j = 0; j < N; j += 1) {
			for (int k = 0; k < j; k += 1) {
				swap_val = c[j][k]; 
				c[j][k] = c[k][j];
				c[k][j] = swap_val;
			}
		}
}


int main()
{
	init(); //This could still be sequential.
	transpose_c_mat(); 
	matmul();
	check(); //this could still be sequetial.

	return 0;
}
