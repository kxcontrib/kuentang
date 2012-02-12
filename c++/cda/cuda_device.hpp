#pragma once
# include <thrust/host_vector.h>

// function prototype
namespace cuda {
	void sort_on_device(thrust::host_vector<int>& V);
	void randn_(double* begin, double* end);
	double sum_(float* begin, float* end);
	double vwap_(float* pbegin, float* pend,float* tbegin, float* tend);

}