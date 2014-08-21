# Knife-Plugin Zero

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

## Usage

```
** ZERO COMMANDS **
knife zero bootstrap FQDN (options)
```

### Bootstrap

Install Chef to remote node and run chef-client under chef-zero via tcp-forward.

Supported options are mostly the same as `knife bootstrap`.


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

### Update(pending)

Search nodes from local chef-repo directory, and run command at remote node.

Supported options are mostly the same as `knife ssh`.

> Pending


## Contributing

1. Fork it ( https://github.com/[my-github-username]/knife-zero/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Licensed under the Apache License, Version 2.0.

