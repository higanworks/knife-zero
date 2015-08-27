# Changelog of knife-zero

## Unreleased

## v1.8.0

- Feature: set bootstraped host to knife_zero.host attribute(normal) #57

## v1.7.1

- Misc: change option name from --without-chef-run to --[no-]converge #25

## v1.7.0

- Bug: ignored knife[:use_sudo] by converge, #22 #42
- Feature: Append white_list to client.rb at bootstrap. #43
- Feature: Add --without-chef-run to zero bootstrap #44

## v1.6.0

- Feature: #32 create alias converge to chef_client, and recommended it by README.
- Refactor: almostoptions are derived from core.
    - PR #38 HT: @patcon

## v1.5.1

- Bug: `--ssh-user` arg doesn't override `knife[:ssh_user]`.
    - PR #35 HT: @patcon

## v1.5.0

- Feature: Support bootstrap as vault client(chef-vault).

## v1.4.0

- Change: remote listen by local chef-zero port + 10000
- Feature: override Remote Chef-Zero port.

## v1.3.0

- return dummy key to validation.
- remove bootstrap template chef-full-localmode. use chef-full by default.
- create around alias for validation_key and start_chef to bootstrap_context.
- set true to Chef::Config[:knife_zero] for bootstrap_context.

## v1.2.1

- set rescue for debug during ssh session.

## v1.2.0

- change filename knife/chef_client to zero_chef_client
- New function diagnose

## v1.1.6

- Minor update: update bootstrap template for chef 11,12

## v1.1.5

- Fix: remove debug code.

## v1.1.4

- Feature: support ssh/config on bootstrapping.

## v1.1.3

- Feature: allow plural bootstrapping

## v1.1.2

- Bugfix: delete version line from bootstrap template

## v1.1.1

- Bugfix: use ::Chef::VERSION instead of chef_version

## v1.1.0

- Upgrade: Remove chef version dependency.

## v1.0.1

- Feature: Support override run-list for zero chef_client.

## v1.0.0

- Code cleanup: use Chef::Knife::SSH framework. HT: @Yasushi
- Patch: Support forwarding in Net::SSH::Multi::PendingConnection. HT: @Yasushi

## v0.2.0

- Feature: Support Why-run.

## v0.1.3

- Bug: require zero_base HT: @Yasushi

## v0.1.2

- Update: Issue #2 Support sudo for zero chef-client

## v0.1.1

- Bug: Issue #1 NoMethodError: undefined method 'split' for nil:NilClass at bootstrap

## v0.1.0 (yanked)

- Feature: run Chef-Client by Search query.


## v0.0.2

- initial release
- Feature: bootstrap with chefzero via tcp-forward
