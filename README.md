# Capistrano-Knife-Solo

Integrates Capistrano (v3.1+) with [Knife Solo](http://matschaffer.github.io/knife-solo/)
to automate the preparation and provisioning of nodes via Chef Solo.

Capistrano-Knife-Solo uses the configured servers and roles from Capistrano,
it feeds them directly into Knife Solo/Chef for node deployment.

This assumes that a Chef role exists to match the defined Capistrano roles (excluding `:all`).

Should work with other Capistrano plugins that dynamically add servers
such as [Cap-EC2](https://github.com/forward3d/cap-ec2)

Note:
By default Capistrano-Knife-Solo ignores any existing Chef/Knife role definitions.
A role is automatically assinged to match the Capistrano roles and these are
programatically inserted into each node's run list.


## Limitations (PRs welcome)

* Capistrano (SSHKit) supports multiple SSH key files. Knife Solo only accepts 
one identity file. Make sure that the correct key is the first configured in Cap.

* Chef Environments are not supported.


## Installation

*  `gem install capistrano-knife-solo` or add the gem to your project's Gemfile.

*  Add this line to your Capfile: `require 'capistrano-knife-solo'`


## Usage

Some tasks are added to Capistrano - these are scoped by stage:

```
$ bundle exec cap -T
...
cap knife:bootstrap # Prepare then cook a node/role with Chef
cap knife:clean     # Clean a node/role with Chef
cap knife:cook      # Cook a node/role with Chef
cap knife:prepare   # Prepare a node/role with Chef
```

e.g. to run Chef on all staging servers
`cap staging knife:cook`

All the [Capistrano filtering options](http://capistranorb.com/documentation/advanced-features/host-filtering/) are supported.

If you wanted to automatically run Chef before each deploy you could add `before 'deploy:starting', 'knife:cook'` to your `deploy.rb` tasks.


## Configuration

Several configuration values exist, the defaults are listed below.

```ruby
set :knife_check_disable, false # Check for chef-solo before deploy:check
set :knife_args, nil # the equivalent of command line arguments to knife solo

set :knife_startup_script, nil # The startup script on the remote server containing variable definitions
set :knife_sudo_command, nil # remote sudo command, if not sudo
set :knife_host_key_verify, false # don't verify ssh key
set :knife_cookbook_path, %w{cookbooks site-cookbooks} # cookbook path relative to Capfile
set :knife_berkshelf, true # use Berkshelf to update cookbooks if present
set :knife_librarian, true # use librarian-chef to update cookbooks if present
```


## Contributing

1. [Fork it](https://github.com/rjocoleman/capistrano-knife-solo/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Similar

* [https://github.com/bmuller/toquen/](https://github.com/bmuller/toquen/)
* [http://lee.hambley.name/2013/06/11/using-capistrano-v3-with-chef.html](http://lee.hambley.name/2013/06/11/using-capistrano-v3-with-chef.html)
