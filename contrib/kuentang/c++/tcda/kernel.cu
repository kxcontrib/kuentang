/*
* This program uses the device CURAND API to calculate what
* proportion of pseudo - random ints have low bit set.
*/
# include <stdio.h>
# include <stdlib.h>
# include <cuda.h>
# include "curand_kernel.h"
# include <vector>

# define CUDA_CALL(x) do { if ((x) != cudaSuccess ) {	\
printf (" Error at %s:%d\n", __FILE__ , __LINE__ );		\
return EXIT_FAILURE ;}} while (0)						\

__global__ void setup_kernel ( curandState * state )
{
//	int id = threadIdx .x + blockIdx .x * c_thread;
	int x = threadIdx.x + blockIdx.x*blockDim.x ; 
	int y = threadIdx.y + blockIdx.y*blockDim.y ;
	int offset = x+y*blockDim.x*gridDim.x;
	curand_init (1234 , offset, 0, & state [offset]);
}

__global__ void generate_kernel ( curandState* state , float* result )
{
	int x = threadIdx.x + blockIdx.x*blockDim.x ; 
	int y = threadIdx.y + blockIdx.y*blockDim.y ;
	int offset = x+y*blockDim.x*gridDim.x;

	curandState localState = state [offset ];
//	result [offset] = curand_normal (& localState );
	result [offset] = offset;
}

__global__ void look( int* threadIdxx
					, int* threadIdxy
					, int* blockIdxx
					, int* blockIdxy
					, int* blockDimx
					, int* blockDimy
					, int* gridDimx
					, int* gridDimy
					, int* doffset
					)
{
	int x = threadIdx.x + blockIdx.x*blockDim.x ; 
	int y = threadIdx.y + blockIdx.y*blockDim.y ;
	int offset = x+y*blockDim.x*gridDim.x;

	threadIdxx[offset]=threadIdx.x;
	threadIdxy[offset]=threadIdx.y;
	blockIdxx[offset] = blockIdx.x;
	blockIdxy[offset] = blockIdx.y;
	blockDimx [offset] = blockDim.x ;
	blockDimy [offset] = blockDim.y ;
	gridDimx [offset]= gridDim.x;
	gridDimy [offset]= gridDim.y;
	doffset[offset]= offset;
}



int main (int argc , char * argv [])
{
	int i;
	curandState * devStates ;
	float * devResults , * hostResults ;
	
	int gridsize = 5;
	int blocksize  = 2;

	int num = gridsize*blocksize*blocksize;

	dim3 block(gridsize);
	dim3 threads(blocksize,blocksize);

	cudaDeviceProp prop;
	cudaGetDeviceProperties(&prop,0);
	// ideally we can use 8,5 Million threads to generate the random numbers

	hostResults = (float *) calloc (num, sizeof ( float));

	CUDA_CALL ( cudaMalloc (( void **)& devResults , num* sizeof ( float)));
	CUDA_CALL ( cudaMemset ( devResults , 0, num * sizeof (float)) );
	CUDA_CALL ( cudaMalloc (( void **)& devStates , num *sizeof ( curandState )));

	int  *dthreadIdxx
		, *dthreadIdxy
		, *dblockIdxx
		, *dblockIdxy
		, *dblockDimx
		, *dblockDimy
		, *dgridDimx
		, *dgridDimy
		, *doffset;

	CUDA_CALL ( cudaMalloc (( void **)& dthreadIdxx , num* sizeof ( int)));
	CUDA_CALL ( cudaMalloc (( void **)& dthreadIdxy , num* sizeof ( int)));
	CUDA_CALL ( cudaMalloc (( void **)& dblockIdxx , num* sizeof ( int)));
	CUDA_CALL ( cudaMalloc (( void **)& dblockIdxy , num* sizeof ( int)));
	CUDA_CALL ( cudaMalloc (( void **)& dblockDimx , num* sizeof ( int)));
	CUDA_CALL ( cudaMalloc (( void **)& dblockDimy , num* sizeof ( int)));
	CUDA_CALL ( cudaMalloc (( void **)& dgridDimx , num* sizeof ( int)));
	CUDA_CALL ( cudaMalloc (( void **)& dgridDimy , num* sizeof ( int)));
	CUDA_CALL ( cudaMalloc (( void **)& doffset , num* sizeof ( int)));

	int   *hthreadIdxx = (int *) calloc (num, sizeof ( int));
	int   *hthreadIdxy = (int *) calloc (num, sizeof ( int));
	int   *hblockIdxx = (int *) calloc (num, sizeof ( int));
	int   *hblockIdxy = (int *) calloc (num, sizeof ( int));
	int   *hblockDimx = (int *) calloc (num, sizeof ( int));
	int   *hblockDimy = (int *) calloc (num, sizeof ( int));
	int   *hgridDimx = (int *) calloc (num, sizeof ( int));
	int   *hgridDimy = (int *) calloc (num, sizeof ( int));
	int   *hoffset = (int *) calloc (num, sizeof ( int));


	look<<<block,threads>>>(	  dthreadIdxx
								, dthreadIdxy
								, dblockIdxx
								, dblockIdxy
								, dblockDimx
								, dblockDimy
								, dgridDimx
								, dgridDimy
								, doffset);


	CUDA_CALL ( cudaMemcpy ( hthreadIdxx , dthreadIdxx, num *sizeof (float), cudaMemcpyDeviceToHost ));
	CUDA_CALL ( cudaMemcpy ( hthreadIdxy , dthreadIdxy, num *sizeof (float), cudaMemcpyDeviceToHost ));
	CUDA_CALL ( cudaMemcpy ( hblockIdxx  , dblockIdxx , num *sizeof (float), cudaMemcpyDeviceToHost ));
	CUDA_CALL ( cudaMemcpy ( hblockIdxy  , dblockIdxy , num *sizeof (float), cudaMemcpyDeviceToHost ));
	CUDA_CALL ( cudaMemcpy ( hblockDimx  , dblockDimx , num *sizeof (float), cudaMemcpyDeviceToHost ));
	CUDA_CALL ( cudaMemcpy ( hblockDimy  , dblockDimy , num *sizeof (float), cudaMemcpyDeviceToHost ));
	CUDA_CALL ( cudaMemcpy ( hgridDimx	 , dgridDimx  , num *sizeof (float), cudaMemcpyDeviceToHost ));
	CUDA_CALL ( cudaMemcpy ( hgridDimy   , dgridDimy  , num *sizeof (float), cudaMemcpyDeviceToHost ));
	CUDA_CALL ( cudaMemcpy ( hoffset	 , doffset	  , num *sizeof (float), cudaMemcpyDeviceToHost ));

	std::vector<int> sthreadIdxx(hthreadIdxx,hthreadIdxx+num)
				   , sthreadIdxy(hthreadIdxy,hthreadIdxy+num)
				   , sblockIdxx(hblockIdxx,hblockIdxx+num)
				   , sblockIdxy(hblockIdxy,hblockIdxy+num)
				   , sblockDimx(hblockDimx,hblockDimx+num)
				   , sblockDimy(hblockDimy,hblockDimy+num)
				   , sgridDimx(hgridDimx,hgridDimx+num)
				   , sgridDimy(hgridDimy,hgridDimy+num)
				   , soffset(hoffset,hoffset+num);

	/* Cleanup */
	CUDA_CALL ( cudaFree ( dthreadIdxx));
	CUDA_CALL ( cudaFree ( dthreadIdxy));
	CUDA_CALL ( cudaFree ( dblockIdxx));
	CUDA_CALL ( cudaFree ( dblockIdxy));
	CUDA_CALL ( cudaFree ( dblockDimx));
	CUDA_CALL ( cudaFree ( dblockDimy));
	CUDA_CALL ( cudaFree ( dgridDimx));
	CUDA_CALL ( cudaFree ( dgridDimy));


	free ( hostResults );

	free ( hthreadIdxx);
	free ( hthreadIdxy);
	free ( hblockIdxx);
	free ( hblockIdxy);
	free ( hblockDimx);
	free ( hblockDimy);
	free ( hgridDimx);
	free ( hgridDimy);

	return EXIT_SUCCESS ;
}