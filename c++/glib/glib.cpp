# include <kdb/kdb.hpp>

# include <boost/phoenix/core.hpp>
# include <boost/phoenix/bind/bind_function_object.hpp>
# include "..\cda\cuda_device.hpp"

kx::K foo(kx::K x)
{
	int i = 1;
	return kx::ki(x->i+1); 
}

kx::K randn(kx::K k)
{
	kx::result_of::value<kx::qtype::int_>::type size = kx::value<kx::qtype::int_>(k);
	kx::raw_vector<kx::qtype::float_> result(size);
	cuda::randn_(result.begin(),result.end());
	return result();
}

kx::K sum(kx::K k)
{
	kx::raw_vector<kx::qtype::real_> result(k);
//	thrust::host_vector<float> hv(result.begin(),result.end());
	double r = cuda::sum_(result.begin(),result.end());
	return kx::kf(r);
}

kx::K vwap(kx::K pp,kx::K tt)
{
	kx::raw_vector<kx::qtype::real_> p(pp);
	kx::raw_vector<kx::qtype::real_> t(tt);
//	thrust::host_vector<float> ppp(p.begin(),p.end());
//	thrust::host_vector<float> ttt(t.begin(),t.end());
	double r = cuda::vwap_(p.begin(),p.end()
						  ,t.begin(),t.end());
	return kx::kf(r);
}