// Modified version to create test cases for kdb wrapper
//  (C) Copyright Gennadiy Rozental 2001-2008.
//  (C) Copyright Gennadiy Rozental & Ullrich Koethe 2001.
//  Distributed under the Boost Software License, Version 1.0.
//  (See accompanying file LICENSE_1_0.txt or copy at 
//  http://www.boost.org/LICENSE_1_0.txt)

//  See http://www.boost.org/libs/test for the library home page.

// Boost.Test
# include <boost/test/floating_point_comparison.hpp>
# include <boost/test/unit_test.hpp>
using namespace boost::unit_test;
using boost::test_tools::close_at_tolerance;
using boost::test_tools::percent_tolerance;

// BOOST
# include <boost/lexical_cast.hpp>
# include <boost/mpl/bool.hpp>
namespace mpl = boost::mpl;

// BOOSt Phoenix
# include <boost/phoenix/scope.hpp>
# include <boost/phoenix/core.hpp>
# include <boost/phoenix/operator.hpp>
# include <boost/phoenix/function.hpp>
namespace phoenix = boost::phoenix;

# include <boost/foreach.hpp>

// STL
# include <functional>
# include <iostream>
# include <iomanip>
# include <memory>
# include <stdexcept>

// KX

# include <kdb/kdb.hpp>
namespace qtype= kx::qtype;
//____________________________________________________________________________//

struct account {
    account() : m_amount(0.0) {}

    void deposit(double amount) { m_amount += amount; }
    void withdraw(double amount)
    {
        if(amount > m_amount) throw std::logic_error("You don't have that much money!");
        m_amount -= amount;
    }
    double balance() const { return m_amount; }

private:
    double m_amount;
};

//____________________________________________________________________________//

struct account_test {
    account_test( double init_value ) { m_account.deposit( init_value ); }

    account m_account;  // a very simple fixture

    void test_init()
    {
        // different kinds of non-critical tests
        // they report the error and continue

        // standard assertion
        // reports 'error in "account_test::test_init": test m_account.balance() >= 0.0 failed' on error
        BOOST_CHECK( m_account.balance() >= 0.0 );

        // customized assertion
        // reports 'error in "account_test::test_init": Initial balance should be more then 1, was actual_value' on error
        BOOST_CHECK_MESSAGE( m_account.balance() > 1.0,
                             "Initial balance should be more then 1, was " << m_account.balance() );

        // equality assertion (not very wise idea use equality check on floating point values)
        // reports 'error in "account_test::test_init": test m_account.balance() == 5.0 failed [actual_value != 5]' on error
        BOOST_CHECK_EQUAL( m_account.balance(), 5.0 );

        // closeness assertion for floating-point numbers (symbol (==) used to mark closeness, (!=) to mark non closeness )
        // reports 'error in "account_test::test_init": test m_account.balance() (==) 10.0 failed [actual_value (!=) 10 (1e-010)]' on error
        BOOST_CHECK_CLOSE( m_account.balance(), 10.0, /* tolerance */ 1e-10 );
    }

    void test_deposit()
    {
        // these 2 statements just to show that usage manipulators doesn't hurt Boost.Test output
        std::cout << "Current balance: " << std::hex << (int)m_account.balance() << std::endl;
        std::cerr << "Current balance: " << std::hex << (int)m_account.balance() << std::endl;

        float curr_ballance = (float)m_account.balance();
        float deposit_value;

        std::cout << "Enter deposit value:\n";
        std::cin  >> deposit_value;

        m_account.deposit( deposit_value );

        // correct result validation; could fail due to rounding errors; use BOOST_CHECK_CLOSE instead
        // reports "test m_account.balance() == curr_ballance + deposit_value failed" on error
        BOOST_CHECK( m_account.balance() == curr_ballance + deposit_value );

        // different kinds of critical tests

        // reports 'fatal error in "account_test::test_deposit": test m_account.balance() >= 100.0 failed' on error
        BOOST_REQUIRE( m_account.balance() >= 100.0 );

        // reports 'fatal error in "account_test::test_deposit": Balance should be more than 500.1, was actual_value' on error
        BOOST_REQUIRE_MESSAGE( m_account.balance() > 500.1,
                               "Balance should be more than 500.1, was " << m_account.balance());

        // reports 'fatal error in "account_test::test_deposit": test std::not_equal_to<double>()(m_account.balance(), 999.9) failed
        //          for (999.9, 999.9)' on error
        BOOST_REQUIRE_PREDICATE( std::not_equal_to<double>(), (m_account.balance())(999.9) );

        // reports 'fatal error in "account_test::test_deposit": test close_at_tolerance<double>( 1e-9 )( m_account.balance(), 605.5)
        //          failed for (actual_value, 605.5)
        BOOST_REQUIRE_PREDICATE( close_at_tolerance<double>( percent_tolerance( 1e-9 ) ),
                                 (m_account.balance())(605.5) );
    }

    void test_withdraw()
    {
        float curr_ballance = (float)m_account.balance();

        m_account.withdraw(2.5);

        // correct result validation; could fail due to rounding errors; use BOOST_CHECK_CLOSE instead
        // reports "test m_account.balance() == curr_ballance - 2.5 failed" on error
        BOOST_CHECK( m_account.balance() == curr_ballance - 2.5 );

        // reports 'error in "account_test::test_withdraw": exception std::runtime_error is expected' on error
        BOOST_CHECK_THROW( m_account.withdraw( m_account.balance() + 1 ), std::runtime_error );

    }
};

//____________________________________________________________________________//

struct account_test_suite : public test_suite {
    account_test_suite( double init_value ) : test_suite("account_test_suite") {
        // add member function test cases to a test suite
        boost::shared_ptr<account_test> instance( new account_test( init_value ) );

        test_case* init_test_case     = BOOST_CLASS_TEST_CASE( &account_test::test_init, instance );
        test_case* deposit_test_case  = BOOST_CLASS_TEST_CASE( &account_test::test_deposit, instance );
        test_case* withdraw_test_case = BOOST_CLASS_TEST_CASE( &account_test::test_withdraw, instance );

        deposit_test_case->depends_on( init_test_case );
        withdraw_test_case->depends_on( deposit_test_case );

        add( init_test_case, 1 );
        add( deposit_test_case, 1 );
        add( withdraw_test_case );
    }
};

struct kdb_test
{
	kdb_test(std::string const& localhost, int port) 
		: localhost_(localhost)
		, port_(port)
	{};
	std::string const localhost_;
	int const port_;
	int c_;

	void test_init()
	{
		// Here we check the connection is established.
		c_ = kx::khp(localhost_.c_str(),port_);
		BOOST_REQUIRE_MESSAGE(c_ > 0,"Cannot build connection to kdb+ instance. A KDB+ instance is needed.");
		//kx::K r = kx::k(c_,(kx::S)0);
		//int a = 0;
	}

	void test_value()
	{
		// Here we check that the value function is there
		BOOST_CHECK(kx::value<qtype::boolean_>(kx::k(c_,"1b",(kx::K)0))==mpl::true_());
		BOOST_CHECK(kx::value<qtype::boolean_>(kx::k(c_,"0b",(kx::K)0))==mpl::false_());
		BOOST_CHECK(kx::value<qtype::float_>(kx::k(c_,"1f",(kx::K)0))==1.0);
		BOOST_CHECK(kx::value<qtype::float_>(kx::k(c_,"2.0",(kx::K)0))==2.0);
		BOOST_CHECK(boost::gregorian::from_undelimited_string("20110503")== kx::value<qtype::date_>(kx::k(c_,"2011.05.03",(kx::K)0)) );
		BOOST_CHECK(boost::gregorian::from_undelimited_string("18651203")== kx::value<qtype::date_>(kx::k(c_,"1865.12.03",(kx::K)0)) );
		BOOST_CHECK(boost::posix_time::time_from_string("2012-01-20 12:25:59.123")== kx::value<qtype::datetime_>(kx::k(c_,"2012.01.20T12:25:59.123",(kx::K)0)) );
		BOOST_CHECK(boost::posix_time::time_from_string("2000-01-01 23:59:59.000")== kx::value<qtype::datetime_>(kx::k(c_,"2000.01.01T23:59:59.000",(kx::K)0)) );

	}

	void test_vector()
	{
		{
			kx::vector<qtype::float_> vf;
			BOOST_CHECK(vf.empty());
			BOOST_CHECK(vf.size()==0);
		}
		// checking floats
		{
			kx::vector<qtype::float_> vf(kx::k(c_,"{x*x} `float$til 10",(kx::K)0));
			BOOST_CHECK(vf.size()==10);
			BOOST_CHECK(vf.empty()!=true);

			double i = 0.0;
			BOOST_FOREACH( double x, vf )
			{
				BOOST_CHECK_CLOSE(x,i*i,1e-10);
				++i;
			}

			std::vector<double> v(vf.begin(),vf.end());
			i = 0.0;
			BOOST_FOREACH( double x, v )
			{
				BOOST_CHECK_CLOSE(x,i*i,1e-10);
				++i;
			}

			std::transform(vf.begin(),vf.end(),vf.begin(),phoenix::val(1.0));
			BOOST_FOREACH( double x, vf ) BOOST_CHECK_CLOSE(x,1.0,1e-10);

		}
		// checking dates
		{
			kx::vector<qtype::date_> vf(kx::k(c_,"2011.01.03+til 10",(kx::K)0));
			BOOST_CHECK(vf.size()==10);
			BOOST_CHECK(vf.empty()!=true);

			boost::gregorian::date d = boost::gregorian::from_undelimited_string("20110103");
			BOOST_FOREACH( boost::gregorian::date x, vf )
			{

				BOOST_CHECK( x == d);
				d+= boost::gregorian::days(1);
			}
		}
		// checking datetime
		{
			kx::vector<qtype::datetime_> vf(kx::k(c_,"2011.01.03T12:12:12.111+til 21",(kx::K)0));
			BOOST_CHECK(vf.size()==21);
			BOOST_CHECK(vf.empty()!=true);

			boost::posix_time::ptime d = boost::posix_time::time_from_string("2011-01-03 12:12:12.111");
			BOOST_FOREACH( boost::posix_time::ptime x, vf )
			{

				BOOST_CHECK( x == d);
				d+= boost::gregorian::days(1);
			}
		}
	}

	void test_raw_vector()
	{
		{
			kx::raw_vector<qtype::float_> vf;
			BOOST_CHECK(vf.empty());
			BOOST_CHECK(vf.size()==0);
		}
		// checking floats
		{
			kx::raw_vector<qtype::float_> vf(kx::k(c_,"{x*x} `float$til 10",(kx::K)0));
			BOOST_CHECK(vf.size()==10);
			BOOST_CHECK(vf.empty()!=true);

			double i = 0.0;
			BOOST_FOREACH( double x, vf )
			{
				BOOST_CHECK_CLOSE(x,i*i,1e-10);
				++i;
			}

			std::vector<double> v(vf.begin(),vf.end());
			i = 0.0;
			BOOST_FOREACH( double x, v )
			{
				BOOST_CHECK_CLOSE(x,i*i,1e-10);
				++i;
			}

			std::transform(vf.begin(),vf.end(),vf.begin(),phoenix::val(1.0));
			BOOST_FOREACH( double x, vf ) BOOST_CHECK_CLOSE(x,1.0,1e-10);

		}
	}
};


struct kdb_test_suite : public test_suite
{
	kdb_test_suite() : test_suite("kdb_test_suite")
	{
		boost::shared_ptr<kdb_test> instance(new kdb_test("localhost", 2009 ));

		test_case*	init_test_case			= BOOST_CLASS_TEST_CASE(&kdb_test::test_init,instance);
		test_case*  value_test_case			= BOOST_CLASS_TEST_CASE(&kdb_test::test_value,instance);
		test_case*  vector_test_case		= BOOST_CLASS_TEST_CASE(&kdb_test::test_vector,instance);
		test_case*  raw_vector_test_case	= BOOST_CLASS_TEST_CASE(&kdb_test::test_raw_vector,instance);

		value_test_case->depends_on(init_test_case);
		vector_test_case->depends_on(init_test_case);
		raw_vector_test_case->depends_on(init_test_case);
		add(init_test_case);
		add(value_test_case);
		add(vector_test_case);
		add(raw_vector_test_case);
	}
};

//____________________________________________________________________________//

test_suite*
init_unit_test_suite( int argc, char * argv[] ) {
    framework::master_test_suite().p_name.value = "KDB Master test suite";
    framework::master_test_suite().add( new kdb_test_suite( ) );

    return 0;
}

//____________________________________________________________________________//

// EOF
