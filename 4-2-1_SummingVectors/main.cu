#include "../common/book.h"
#include "cuda_runtime.h"

#define N	10

__global__ void add(int *a, int *b, int *c)
{
	int tid = blockIdx.x;	// Handle the data at this index
	if (tid < N)
	{
		c[tid] = a[tid] + b[tid];
	}
}

int main(void)
{
	int a[N], b[N], c[N];		// Declare vectors
	int *dev_a, *dev_b, *dev_c;	// Device integers

	// Allocate the memory on the GPU
	HANDLE_ERROR(cudaMalloc((void**)&dev_a, N * sizeof(int)));
	HANDLE_ERROR(cudaMalloc((void**)&dev_b, N * sizeof(int)));
	HANDLE_ERROR(cudaMalloc((void**)&dev_c, N * sizeof(int)));

	// Fill the arrays 'a' and 'b' on the CPU
	for (int i = 0; i < N; i++)
	{
		a[i] = -i;
		b[i] = i * i;
	}

	// Copy the arrays 'a' and 'b' to the GPU
	HANDLE_ERROR(cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice));
	HANDLE_ERROR(cudaMemcpy(dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice));

	add<<<N,1>>>(dev_a, dev_b, dev_c);

	// Copy the array 'c' back from the GPU to the CPU
	HANDLE_ERROR(cudaMemcpy(c, dev_c, N * sizeof(int), cudaMemcpyDeviceToHost));

	// Display the results
	for (int i = 0; i < N; i++)
	{
		printf("%d + %d = %d\n", a[i], b[i], c[i]);
	}

	// Free the memory allocated on the GPU
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	return 0;
}