namespace :knife do
  desc 'Prepare a node/role with Chef Solo'
  task :prepare do
    on roles(:all), in: :parallel do |host|
      run_locally do
        solo = Chef::Knife::SoloPrepare.new
        Chef::Knife::SoloPrepare.load_deps
        CapistranoKnifeSolo::Helpers.chef_config
        solo.name_args = CapistranoKnifeSolo::Helpers.knife_args(host)
        solo.config = CapistranoKnifeSolo::Helpers.knife_config(host)
        solo.run
      end
    end
  end

  desc 'Cook a node/role with Chef Solo'
  task :cook => [:check] do
    Rake::Task['knife:cookbook_managers'].invoke
    on roles(:all), in: :parallel do |host|
      run_locally do
        solo = Chef::Knife::SoloCook.new
        Chef::Knife::SoloCook.load_deps
        CapistranoKnifeSolo::Helpers.chef_config
        solo.name_args = CapistranoKnifeSolo::Helpers.knife_args(host)
        solo.config = CapistranoKnifeSolo::Helpers.knife_config(host)
        solo.run
      end
    end
  end

  desc 'Clean a node/role with Chef Solo'
  task :clean do
    on roles(:all), in: :parallel do |host|
      run_locally do
        solo = Chef::Knife::SoloClean.new
        Chef::Knife::SoloClean.load_deps
        CapistranoKnifeSolo::Helpers.chef_config
        solo.name_args = CapistranoKnifeSolo::Helpers.knife_args(host)
        solo.config = CapistranoKnifeSolo::Helpers.knife_config(host)
        solo.run
      end
    end
  end

  # cookbook managers want to run for each knife solo run, for each node.
  # this task runs them manually first once, if they're enabled, and then disables them for future knife runs in this session.
  task :cookbook_managers do
    manager = Chef::Knife::SoloCook.new
    CapistranoKnifeSolo::Helpers.chef_config
    manager.berkshelf_install if fetch(:knife_berkshelf)
    set :knife_berkshelf, false
    manager.librarian_install if fetch(:knife_librarian)
    set :knife_librarian, false
  end

  # check if `chef-solo` is an executable command on the path of remote server
  task :check do
    unless fetch(:knife_check_disable)
      on roles(:all), in: :parallel do |host|
        unless test "command -v chef-solo >/dev/null 2>&1"
          error "#{host}: chef-solo not found, aborting."
          abort "chef-solo was not present on atleast one server. Run 'cap #{fetch(:stage)} knife:prepare'"
        end
      end
    end
  end
  before 'deploy:check', 'knife:check'

  desc 'Prepare then cook a node/role with Chef'
  task :bootstrap => [:prepare, :cook]
end

namespace :load do
  task :defaults do
    set :knife_check_disable, false
    set :knife_args, nil

    set :knife_startup_script, nil
    set :knife_sudo_command, nil
    set :knife_host_key_verify, false
    set :knife_cookbook_path, %w{cookbooks site-cookbooks}
    set :knife_node_path, "#{fetch(:tmp_dir)}/capistrano-knife-solo"
    set :knife_berkshelf, true
    set :knife_librarian, true
  end
end
