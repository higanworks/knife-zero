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

Relocated: [Configration | Knife-Zero Document](http://knife-zero.github.io/40_configration/)

### knife zero bootstrap | converge | diagnose

Relocated

- [Getting Started | Knife-Zero Document](http://knife-zero.github.io/20_getting_started/)
- [Subcommands | Knife-Zero Document](http://knife-zero.github.io/30_subcommands/)


#### (Hint)Supress Automatic Attributes

Relocated: [Configration | Knife-Zero Document](http://knife-zero.github.io/40_configration/)


## To include from other knife plugins

Relocated: [To include from other knife plugins | Knife-Zero Document](http://knife-zero.github.io/tips/include_from_other_knife_plugins/)


## Contributing

1. Fork it ( https://github.com/[my-github-username]/knife-zero/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Licensed under the Apache License, Version 2.0.

