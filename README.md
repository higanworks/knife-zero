# Knife-Plugin Zero

[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/higanworks/knife-zero?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Gem Version](https://badge.fury.io/rb/knife-zero.svg)](http://badge.fury.io/rb/knife-zero)
[![Stories in Ready](https://badge.waffle.io/higanworks/knife-zero.svg?label=ready&title=Ready)](http://waffle.io/higanworks/knife-zero) 
[![Stories in Progress](https://badge.waffle.io/higanworks/knife-zero.svg?label=In%20Progress&title=In%20Progress)](http://waffle.io/higanworks/knife-zero) 

Run chef-client at remote node with chef-zero(local-mode) via HTTP over SSH port fowarding.

- It doesn't have to transport cookbooks via scp,rsync or something.
- It can collect node object into local chef-repo.
- It supports all functioanly of chef(C/S).
- You have only to manage one chef-repo.

## Requirements

- Must support AllowTcpForward 

## Installation

Add this line to your application's Gemfile:

    gem 'knife-zero'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knife-zero

### With Chef-DK

Install via `chef gem` subcommand.

```
$ chef gem install knife-zero
```

## Usage

```
** ZERO COMMANDS **
knife zero bootstrap FQDN (options)
knife zero chef_client QUERY (options)
```

### knife zero bootstrap

Install Chef to remote node and run chef-client under chef-zero via tcp-forward.

Supported options are mostly the same as `knife bootstrap`.
And it supports why-run(`-W, --why-run`).

#### Example

Bootstrap with run-list.

```
$ bundle exec knife zero bootstrap host.example.com -r hogehoge::default --no-host-key-verify
Connecting to host.example.com
host.example.com Installing Chef Client...
-- snip --
host.example.com Thank you for installing Chef!

host.example.com Starting first Chef Client run...
host.example.com Starting Chef Client, version 11.14.6
host.example.com Creating a new client identity for host.example.com using the validator key.


## Resolv and sync cookbook via http over ssh tcp-forward by run-list.
host.example.com resolving cookbooks for run list: ["hogehoge::default"]
host.example.com Synchronizing Cookbooks:
host.example.com   - hogehoge
host.example.com Compiling Cookbooks...
host.example.com Converging 0 resources
host.example.com 
host.example.com Running handlers:
host.example.com Running handlers complete
host.example.com Chef Client finished, 0/0 resources updated in 4.895561879 seconds


## Creates node object into local.
 $ ls nodes/host.example.com.json 
nodes/host.example.com.json
host.example.com

## Search by knife with --local--mode option.
$ bundle exec knife search node --local-mode
1 items found

Node Name:   host.example.com
Environment: _default
FQDN:        
IP:          xxx.xxx.xxx.xxx
Run List:    recipe[hogehoge::default]
Roles:       
Recipes:     hogehoge::default
Platform:    ubuntu 12.04
Tags:        
```

Search and update node by `knife exec`(I will implement them into plugin.).

```
$ knife exec --local-mode -E 'nodes.all {|n| system "ssh -R8889:127.0.0.1:8889 #{n.ipaddress} chef-client -S http://127.0.0.1:8889" }'
```

Seach and execute command via ssh by knife ssh.

```
$ knife ssh 'hostname:*' --local-mode uptime --attribute ipaddress 
xxx.xxx.xxx.xxx  08:41:36 up  1:03,  1 user,  load average: 0.00, 0.01, 0.01
xxx.xxx.xxx.xxx  08:41:37 up 143 days,  2:32,  4 users,  load average: 0.00, 0.01, 0.05
```

### knife zero chef_client (for update)

`knife zero chef_client QUERY (options)`

Search nodes from local chef-repo directory, and run command at remote node.

Supported options are mostly the same as `knife ssh`.
And it supports below.

- why-run(`-W, --why-run`)
- Override run-list(`-o RunlistItem,RunlistItem, --override-runlist`). It skips save node.json on workstation.

#### Example

```
## Chef-Repo has two nodes
$ knife node list --local-mode
host.example.com
host2.example.com

## add recipe to run_list of host.example.com
$ knife node run_list add host.example.com hogehoge::default --local-mode
host.example.com:
  run_list: recipe[hogehoge::default]


$ knife zero chef_client 'name:*' --attribute ipaddress 

## host.example.com was converged by run_list.
host.example.com Starting Chef Client, version 11.14.6
host.example.com resolving cookbooks for run list: ["hogehoge::default"]
host.example.com Synchronizing Cookbooks:
host.example.com   - hogehoge
host.example.com Compiling Cookbooks...
host.example.com Converging 0 resources
host.example.com 
host.example.com Running handlers:
host.example.com Running handlers complete
host.example.com Chef Client finished, 0/0 resources updated in 3.112708185 seconds


## host2.example.com has no run_list.
host2.example.com Starting Chef Client, version 11.14.2
host2.example.com resolving cookbooks for run list: []
host2.example.com Synchronizing Cookbooks:
host2.example.com Compiling Cookbooks...
host2.example.com [2014-08-24T11:52:15+00:00] WARN: Node ngrok01.xenzai.net has an empty run list.
host2.example.com Converging 0 resources
host2.example.com 
host2.example.com Running handlers:
host2.example.com Running handlers complete
host2.example.com Chef Client finished, 0/0 resources updated in 3.729471856 seconds
```


## Sample Workflow

1. create chef-repo directory.
1. bundle init and add below.
    - `gem 'chef'  `
    - `gem 'knife-zero'`
    - and cookbook management tool such as `Beakshelf` or `Librarian-Chef`.
1. bundle   
e.g.) `bundle install --path vendor/bundle --binstubs`
1.  install cookbooks to `./cookbooks`. (if you need run recipe.)
1. bootstrap on remote node.  
`./bin/knife zero bootstrap host.example.com [-r "${your-run-list}"]`
1. chef-client will run using resources on local chef-repo.

### Need test on Vagrant ?

You can test cookbooks easily by Test-Kitchen before manage remote nodes instead of using knife-zero for vagrant VM.

See [Getting Started knife-zero with test-kitchen](https://github.com/higanworks/knife-zero-with-kitchen).


## Contributing

1. Fork it ( https://github.com/[my-github-username]/knife-zero/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Licensed under the Apache License, Version 2.0.

