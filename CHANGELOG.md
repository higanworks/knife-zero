# Changelog of knife-zero

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

- Feature: run Chef-Client by Seach query.


## v0.0.2

- initial release
- Feature: bootstrap with chefzero via tcp-forward
