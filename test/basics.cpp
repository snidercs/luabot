// Copyright 2019 Michael Fisher <mfisher@lvtk.org>
// SPDX-License-Identifier: ISC

#include <boost/test/unit_test.hpp>

#include <snider/bot/bot.hpp>

namespace bot = snider::bot;

BOOST_AUTO_TEST_SUITE (Basics)

BOOST_AUTO_TEST_CASE (hello_world) {
    BOOST_REQUIRE_EQUAL("hello world", bot::hello_world());
}

BOOST_AUTO_TEST_SUITE_END()
