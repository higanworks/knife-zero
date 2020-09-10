# Changelog of knife-zero

## Unreleased

none.

## v2.3.2

- follow core changes, they uses autoload.
  - .to_yaml not work in diagnose.

## v2.3.1

- bugfix: alter_project not works due to typo. HT: [@aspyatkin](https://github.com/aspyatkin)
  - [https://github.com/higanworks/knife-zero/issues/133#issuecomment-674530243](https://github.com/higanworks/knife-zero/issues/133#issuecomment-674530243)

## v2.3.0

- use `allowd_` instead.
- ref: [Renamed Client Configuration Options - Chef Infra Client 16.3 released!](https://discourse.chef.io/t/chef-infra-client-16-3-released/17449)

## v2.2.1

- path --validation_key option to resolve crash bootstraping in cinc 15.6 [#138](https://github.com/higanworks/knife-zero/pull/138)

## v2.2.0

- add `--alter-project` to support cinc [#133](https://github.com/higanworks/knife-zero/pull/133)
  - allowed values: 'chef' or 'cinc'
  - in config => `knife[:alter_project]`
- relocate `--node-config` option from `zero converge` to both `zero converge` and `zero bootstrap`.
- remove `-N` for `--node-config` short option.
  - (Duplicate with NAME option)

## v2.1.0

- Allow pass run-list and environments from json-attributes.
  - Related:Split run list and attributes from nodes [#132](https://github.com/higanworks/knife-zero/issues/132)

## v2.0.4

- bugfix: Crash around the end of a concurrent connection [#131](https://github.com/higanworks/knife-zero/pull/131)


## v2.0.3

- Properly quoted policy name [#129](https://github.com/higanworks/knife-zero/pull/129) HT: [@etki](https://github.com/etki)

## v2.0.2(yanked)

## v2.0.1

- Add new option `--chef-license` to converge [#128](https://github.com/higanworks/knife-zero/pull/128)


## v2.0.0

- Support bootstrap changes on Chef Infra Client 15.x
  - without Windows
- drop support chef-client < 15
- add `--connection-user`, `--connection-password`, `--connection-port` options for converge, apply subcommand as wrapper.

## v1.x

- no longer support on master branch.
  - May maintain a bit on 1.x branche. see: https://github.com/higanworks/knife-zero/tree/1.x

## v1.19.3

- replace `https://chef.sh` to `https://omnitruck.chef.io/install.sh` for download chef.

## v1.19.2

- set :fatal to duplicated_fqdns by default [#119](https://github.com/higanworks/knife-zero/pull/119)
  - `duplicated_fqdns` will be included at least in chef 14.

## v1.19.1

- Properly quote policyfile name [#117](https://github.com/higanworks/knife-zero/pull/117)

## v1.19.0

- enable keepalive on Net::SSH::Multi [#116](https://github.com/higanworks/knife-zero/pull/116)
- add option node_config_file to zero converge [#114](https://github.com/higanworks/knife-zero/pull/114)
  - `-N, --node-config PATH_TO_CONFIG`

## v1.18.2

- add -E option support for converge [#112](https://github.com/higanworks/knife-zero/pull/112) HT: [@yusukegoto](https://github.com/yusukegoto)

## v1.18.1

- Set true by default to `Chef::Config[:listen]`
    - it was reversed with chef 13.1.26.

## v1.18.0

- Just allow run under chef-client 13

## v1.17.3

- apply no-color to remote side [#109](https://github.com/higanworks/knife-zero/pull/109) HT: [@yusukegoto](https://github.com/yusukegoto)

## v1.17.2

- pass true as 2nd args for Net::SSH.configuration_for by default. [#106](https://github.com/higanworks/knife-zero/pull/106)

## v1.17.1

- [Bugfix]: change of 1.17.0 crashes nodenameless bootstrapping.

## v1.17.0(Yanked)

- Change: Ask overwrite node object at bootstrap [#101](https://github.com/higanworks/knife-zero/pull/101)
    - New option `--[no-]overwrite`

## v1.16.0

- [Feature] converge with `--json-attributes` [#98](https://github.com/higanworks/knife-zero/pull/98)

## v1.15.3

- [Bugfix] move overridden options of bootstrap into deps.
    - The new change about policy_group breaks knife bootstrap when policies aren't used [#92](https://github.com/higanworks/knife-zero/pull/92)

## v1.15.2

- [Feature] Add option --splay from splay
- [Feature] Add option --skip-cookbook-sync from chef-client v12.8.1
- [Cleanup] inherit named_run_list

## v1.15.1

- Follow Upstream: Support option both identity_file and ssh_identity_file for zero bootstrap. #88

## v1.15.0

- Feature: specified policy_group from option.
    - `knife serve` and `chef push`.

## v1.14.0

- Change: support policy_document_native_api by default. #85
    - this feature depends on chef-dk 0.11.0 or later.

## v1.13.2

- Bug: `--named-run-list` did not be passed to remote chef-client.

## v1.13.1

- Misc: Change chef dependency from "~> 12.6.0" to "~> 12.6" for install 12.7.0 or later.

## v1.13.0

- Feature: Support single Policyfile #80
- Feature: Add new option --appendix-config to zero bootstrap #82

## v1.12.1

- Typo: start_chef_appy => start_chef_apply
- Feature: Import json_attribs option from chef-apply to zero-apply

## v1.12.0

- Feature: New subcommand `zero apply`

## v1.11.1

- Feature: add before_hook
    - before_bootstrap
    - before_converge

## v1.11.0

- Add dependency chef "~> 12.6.0"
- Feature: Allow USER@FQDN format for bootstrap commands #37
- Remove: Option first_boot_attributes compatibility before 12.6.

## v1.10.2

- Bugfix: `--json-attribute` was broken. #73

## v1.10.1

- Fix: knife zero bootstrap broken by knife rehash #70

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
