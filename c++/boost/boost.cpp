# include <kdb/kdb.hpp>
# include <random>
# include <boost/random/mersenne_twister.hpp>
# include <boost/random/normal_distribution.hpp>

# include <boost/phoenix/core.hpp>
# include <boost/phoenix/bind/bind_function_object.hpp>

boost::random::mt19937 gen;

kx::K foo(kx::K x)
{
	int i = 1;
	return kx::ki(x->i+1); 
}

kx::K randn(kx::K k)
{
	kx::vector<kx::qtype::float_> result(kx::value<kx::qtype::int_>(k));
	boost::random::normal_distribution<double> dist;
	std::generate(result.begin(),result.end(),boost::phoenix::bind(dist,gen));

	return result();
}