#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_SUITE (Basics)

BOOST_AUTO_TEST_CASE (hello_world) {
    BOOST_REQUIRE_EQUAL ("hello world", "hello world");
}

BOOST_AUTO_TEST_SUITE_END()
