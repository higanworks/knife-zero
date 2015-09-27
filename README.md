# Knife-Plugin Zero

- current_master: [![Circle CI](https://circleci.com/gh/higanworks/knife-zero/tree/master.svg?style=svg)](https://circleci.com/gh/higanworks/knife-zero/tree/master)
- integration_with_edge_chef: [![Circle CI](https://circleci.com/gh/higanworks/knife-zero/tree/integration_testedge.svg?style=svg)](https://circleci.com/gh/higanworks/knife-zero/tree/integration_testedge)

[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/higanworks/knife-zero?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Gem Version](https://badge.fury.io/rb/knife-zero.svg)](http://badge.fury.io/rb/knife-zero)
[![Stories in Ready](https://badge.waffle.io/higanworks/knife-zero.svg?label=ready&title=Ready)](http://waffle.io/higanworks/knife-zero) 
[![Stories in Progress](https://badge.waffle.io/higanworks/knife-zero.svg?label=In%20Progress&title=In%20Progress)](http://waffle.io/higanworks/knife-zero) 

Run chef-client at remote node with chef-zero(local-mode) via HTTP over SSH port forwarding.

- It doesn't have to transport cookbooks via scp,rsync or something.
- It can collect node object into local chef-repo.
- It supports all functions of chef(C/S).
- You have only to manage one chef-repo.

- [Knife-Zero Document](https://knife-zero.github.io)
- [Knife-Zero Document(Ja)](https://knife-zero.github.io/ja/)

## Requirements

- Must support AllowTcpForward 

## Installation

Relocated: [Installation | Knife-Zero Document](http://knife-zero.github.io/10_install/)


## Usage

```
** ZERO COMMANDS **
knife zero bootstrap FQDN (options)
knife zero chef_client QUERY (options) | It's same as converge
knife zero converge QUERY (options)
knife zero diagnose # show configuration from file
```

### Configuration file

You need to make sure the knife.rb file in your chef-repo (in the chef-repo root or .chef directory) is adapted to use chef-zero.

For example, at `.chef/knife.rb`. At least the following contents are needed:
```
chef_repo_path   File.expand_path('../../' , __FILE__)
cookbook_path    [File.expand_path('../../cookbooks' , __FILE__), File.expand_path('../../site-cookbooks' , __FILE__)]
```

If you used knife serve or knife zero, this makes sure chef-zero is started with the contents of the chef-repo directory instead of as an empty server.

### knife zero bootstrap

Install Chef to remote node and run chef-client under chef-zero via tcp-forward.

Supported options are mostly the same as `knife bootstrap`.
And it supports why-run(`-W, --why-run`)and Bootstrap without first Chef-Client Run.(--no-converge).

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


## Resolve and sync cookbook via http over ssh tcp-forward by run-list.
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

Search and execute command via ssh by knife ssh.

```
$ knife ssh 'hostname:*' --local-mode uptime --attribute ipaddress 
xxx.xxx.xxx.xxx  08:41:36 up  1:03,  1 user,  load average: 0.00, 0.01, 0.01
xxx.xxx.xxx.xxx  08:41:37 up 143 days,  2:32,  4 users,  load average: 0.00, 0.01, 0.05
```

Bootstrap multi-nodes via GNU Parallel

```
$ parallel -j 5 ./bin/knife zero bootstrap ::: nodeA nodeB nodeC...
```

#### (Hint)Supress Automatic Attributes

knife-zero supports appending [whitelist-attributes](https://docs.chef.io/attributes.html#whitelist-attributes) to client.rb at bootstrap.

For example, set array to `knife.rb`.

```
knife[:automatic_attribute_whitelist] = [
  "fqdn/",
  "ipaddress/",
  "roles/",
  "recipes/",
  "ipaddress/",
  "platform/",
  "platform_version/",
  "cloud/",
  "cloud_v2/"
]
```

It setting will append to client.rb of node via bootstrap.

```
...

automatic_attribute_whitelist ["fqdn/", "ipaddress/", "roles/", "recipes/", "ipaddress/", "platform/", "platform_version/", "cloud/", "cloud_v2/"]
```

It means knife-zero will collects and updates only listed attributes to local file.

```
{
  "name": "knife-zero.example.com",
  "normal": {
    "knife_zero" : {
      "host" : "xxx.xxx.xxx.xxx(bootstraped_target)"
    },
    "tags": [

    ]
  },
  "automatic": {
    "ipaddress": "xxx.xxx.xxx.xxx",
    "roles": [

    ],
    "recipes": [

    ],
    "platform": "ubuntu",
    "platform_version": "14.04",
    "cloud_v2": null
  }
}  
```



### knife zero converge/chef_client (for update)

`knife zero converge QUERY (options)`
`knife zero chef_client QUERY (options) | It's same as converge`

Search nodes from local chef-repo directory, and run chef-client at remote node.

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


$ knife zero converge 'name:*' --attribute ipaddress 

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
    - and cookbook management tool such as `Berkshelf` or `Librarian-Chef`.
1. bundle   
e.g.) `bundle install --path vendor/bundle --binstubs`
1.  install cookbooks to `./cookbooks`. (if you need run recipe.)
1. bootstrap on remote node.  
`./bin/knife zero bootstrap host.example.com [-r "${your-run-list}"]`
1. chef-client will run using resources on local chef-repo.

### Need test on Vagrant ?

Relocated: [Practice with Vagrant | Knife-Zero Document](https://knife-zero.github.io/tips/practice_with_vagrant/)


## Debug for Configuration

`knife zero diagnose` shows configuration from file(Such as knife.rb).

```
$ knife zero diagnose

Chef::Config
====================
---
:local_mode: true
:verbosity: 
:config_file: "/Users/sawanoboriyu/github/higanworks/knife-zero_playground/knife.rb"
:color: true
:log_level: :error
:chef_repo_path: "/Users/sawanoboriyu/github/higanworks/knife-zero_playground"
:log_location: !ruby/object:IO {}
:chef_server_url: http://localhost:8889
:repo_mode: everything

Knife::Config
====================
---
:verbosity: 0
:color: true
:editor: vim
:disable_editing: false
:format: summary
:ssh_user: root
:host_key_verify: true
:config_file: "/Users/sawanoboriyu/github/higanworks/knife-zero_playground/knife.rb"

Zero Bootstrap Config
====================
---
:ssh_user: root
:host_key_verify: true
:distro: chef-full-localmode
:template_file: false
:run_list: []
:first_boot_attributes: {}

Zero ChefClient Config
====================
---
:ssh_user: root
:host_key_verify: true
:concurrency: 
:override_runlist: 
```


## To include from other knife plugins

If you want to integrate knife-zero on machine creation with cloud plugins, you can add zerobootstrap to deps like below.

```
deps do
  require 'chef/knife/zerobootstrap'
  Chef::Knife::ZeroBootstrap.load_deps
  self.options = Chef::Knife::ZeroBootstrap.options.merge(self.options)
end
```

For example, [knife-digital_ocean](https://github.com/higanworks/knife-digital_ocean/blob/79_merge_zero_bootstrap_options/lib/chef/knife/digital_ocean_droplet_create.rb)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/knife-zero/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Licensed under the Apache License, Version 2.0.

