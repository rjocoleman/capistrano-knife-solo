namespace :knife do
  task :bootstrap do
    on roles(:all) do |host|
      run_locally do
        require 'pry';binding.pry
        options = ['']
        options << "#{fetch(:knife_args)}" if fetch(:knife_args)
        Chef::Knife::SoloBootstrap.new.run options
      end
    end
  end
end

namespace :load do
  task :defaults do
    set :knife_args, ''
  end
end
