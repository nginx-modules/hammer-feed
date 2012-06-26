# vim:set ft= ts=4 sw=4 et fdm=marker:

BEGIN {
    $ENV{TEST_NGINX_USE_HUP} = 1;
}

use lib 'lib';
use Test::Nginx::Socket;

#worker_connections(1014);
#master_process_enabled(1);
#log_level('warn');

repeat_each(2);

plan tests => repeat_each() * (blocks() * 3);

#no_diff();
no_long_string();
#master_on();
#workers(2);

no_shuffle();

run_tests();

__DATA__

=== TEST 1: initialize the fields in shdict
--- http_config
    lua_shared_dict dogs 1m;
--- config
    location = /test {
        content_by_lua '
            local dogs = ngx.shared.dogs
            dogs:set("foo", 32)
            dogs:set("bah", 10502)
            local val = dogs:get("foo")
            ngx.say(val, " ", type(val))
            val = dogs:get("bah")
            ngx.say(val, " ", type(val))
        ';
    }
--- request
GET /test
--- response_body
32 number
10502 number
--- no_error_log
[error]



=== TEST 2: retrieve the fields in shdict after HUP reload
--- http_config
    lua_shared_dict dogs 1m;
--- config
    location = /test {
        content_by_lua '
            local dogs = ngx.shared.dogs

            -- dogs:set("foo", 32)
            -- dogs:set("bah", 10502)

            local val = dogs:get("foo")
            ngx.say(val, " ", type(val))
            val = dogs:get("bah")
            ngx.say(val, " ", type(val))
        ';
    }
--- request
GET /test
--- response_body
32 number
10502 number
--- no_error_log
[error]

