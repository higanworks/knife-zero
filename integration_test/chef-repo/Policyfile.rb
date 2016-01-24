name "integration_test"

default_source :community
run_list "kzi::default"
named_run_list :replay, "kzi::default"

cookbook "kzi", path: "policy-cookbooks/kzi"
