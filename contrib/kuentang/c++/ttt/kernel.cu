# include <thrust/random.h>
# include <thrust/iterator/counting_iterator.h>
# include <thrust/functional.h>
# include <thrust/transform_reduce.h>
# include <thrust/host_vector.h>
# include <thrust/device_vector.h>

# include <iostream>
# include <iomanip>

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

int main(void)
{
  int M;
  std::cout<<"Anzahl der samples M angeben: "<<std::endl;
  std::cin >> M;

  thrust::device_vector<float> dv(M);
  thrust::transform(thrust::counting_iterator<int>(0),thrust::counting_iterator<int>(M),dv.begin(),nrd());

  thrust::host_vector<float> hv=dv;
  std::cout << std::setprecision(10);
  std::copy(hv.begin(), hv.end(), std::ostream_iterator<float>(std::cout, "\n"));
  //float estimate = thrust::transform_reduce(thrust::counting_iterator<int>(0),
  //                                          thrust::counting_iterator<int>(M),
  //                                          estimate_pi(),
  //                                          0.0f,
  //                                          thrust::plus<float>());

  float mean = thrust::reduce(dv.begin(),dv.end(),0.0f,thrust::plus<float>()) / M;
  float var = thrust::inner_product(dv.begin(),dv.end(),dv.begin(),0.0f) / M;

  std::cout << "mean is approximately " << mean << std::endl;
  std::cout << "var is approximately " << var << std::endl;

  return 0;
}

