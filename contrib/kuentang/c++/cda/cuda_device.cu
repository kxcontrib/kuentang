
// thrust library
# include <thrust/host_vector.h>
# include <thrust/device_vector.h>
# include <thrust/sort.h>
# include <thrust/copy.h>
# include <thrust/random.h>
# include <thrust/iterator/counting_iterator.h>
# include <thrust/functional.h>
# include <thrust/transform_reduce.h>

// boost library

// stl
# include <iterator>
# include <random>
# include "cuda_device.hpp"




__host__ __device__
unsigned int hash(unsigned int a)
{
    a = (a+0x7ed55d16) + (a<<12);
    a = (a^0xc761c23c) ^ (a>>19);
    a = (a+0x165667b1) + (a<<5);
    a = (a+0xd3a2646c) ^ (a<<9);
    a = (a+0xfd7046c5) + (a<<3);
    a = (a^0xb55a4f09) ^ (a>>16);
    return a;
}

struct urd : public thrust::unary_function<unsigned int,float>
{
  __host__ __device__
  float operator()(unsigned int thread_id)
  {
    unsigned int seed = hash(thread_id);
    //thrust::default_random_engine rng(seed);
    thrust::minstd_rand rng(seed);
    thrust::uniform_real_distribution<float> u(0,1);
    return u(rng);
  }
};

struct nrd : public thrust::unary_function<unsigned int,float>
{

  __host__ __device__
  float operator()(unsigned int thread_id)
  {
    unsigned int seed = hash(thread_id);
    thrust::minstd_rand rng(seed);
    //thrust::default_random_engine rng(seed);
	thrust::random::experimental::normal_distribution<float> u(0.0f,1.0f);

    return u(rng);
  };


};

namespace cuda {

void sort_on_device(thrust::host_vector<int>& h_vec)
{
    // transfer data to the device
    thrust::device_vector<int> d_vec = h_vec;
    thrust::sort(d_vec.begin(), d_vec.end());
    thrust::copy(d_vec.begin(), d_vec.end(), h_vec.begin());
}

void randn_(double* begin, double* end)
{
	std::ptrdiff_t  ptrdiff = std::distance(begin,end);
	thrust::device_vector<float> dv(ptrdiff);
	thrust::transform(thrust::counting_iterator<int>(0),thrust::counting_iterator<int>(ptrdiff),dv.begin(),nrd());
	thrust::copy(dv.begin(),dv.end(),begin);
}

double sum_(float* begin, float* end)
{
	thrust::device_vector<float> dv(begin,end);
	return thrust::reduce(dv.begin(),dv.end(),0.0f,thrust::plus<float>());
}

double vwap_(float* pbegin, float* pend,float* tbegin, float* tend)
{
	thrust::device_vector<float> p(pbegin,pend);
	thrust::device_vector<float> t(tbegin,tend);
	float z = thrust::inner_product(p.begin(),p.end(),t.begin(),0.0f) ;
	float u = thrust::reduce(t.begin(),t.end(),0.0f,thrust::plus<float>());
	return z / u;
}

} // cuda

