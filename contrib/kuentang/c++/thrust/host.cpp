# include <thrust/host_vector.h>
# include <thrust/generate.h>
# include <thrust/sort.h>
# include <cstdlib>
# include <iostream>
# include <iterator>
# include <boost/phoenix/phoenix.hpp>

// defines the function prototype
# include "device.h"

int main(void)
{
    // generate 20 random numbers on the host
	std::size_t size = 20;
	std::vector<int> v (size);
    std::generate(v.begin(),v.end(),rand);
	thrust::host_vector<int> h_vec = v;
	
//    thrust::generate(h_vec.begin(), h_vec.end(), rand);

    // interface to CUDA code
    sort_on_device(h_vec);

    // print sorted array
	std::copy(v.begin(), v.end(), std::ostream_iterator<int>(std::cout, "\n"));
	std::cout<<"sorted vector"<<std::endl;
    thrust::copy(h_vec.begin(), h_vec.end(), std::ostream_iterator<int>(std::cout, "\n"));

    return 0;
}

