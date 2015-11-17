# Changelog of knife-zero

## Unreleased

## v1.10.0

- Feature: Add new option `--client-version [latest|VERSION]` for reinstall chef-client.

## v1.9.2

- Monkey: include Fixed host parsing to work with ipv6 addresses net-ssh/net-ssh-multi#9
    - https://github.com/net-ssh/net-ssh-multi/pull/9

## v1.9.1

- Compatibility: Keep same behavior of --json-attribute-file option.
    - use patche only before 12.5.2

## v1.9.0

- Change: use nil to ssh_user on bootstraping by default.
    - compatibility for 12.5 and ssh/config
- Remove: add new attribute knife_zero.ssh_url at bootstrap.

## v1.8.7

- Follow master: environment _default is not set by default since 12.5
- Replace string letelals to instance of String.

## v1.8.6

- Feature: add new attribute knife_zero.ssh_url at bootstrap.

## v1.8.5

- Bug: allow more than 2 white lists. HT: @kaznishi

## v1.8.4

- Patched `net-ssh-multi`s from "1.1.0", "1.2.0" to "1.1.0", "1.2.0", "1.2.1"
    - and create issue #62

## v1.8.3

- include Chef#3900 until merge.
    - add option --json-attribute-file FILE

## v1.8.2

- Cleanup: Swap chef_client and converge.

## v1.8.1

- Follow Chef: check first_boot_attribute_from_file flag for knife_zero.host attribute(normal).

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
