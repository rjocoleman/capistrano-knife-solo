require 'chef/knife/solo_prepare'
require 'chef/knife/solo_cook'
require 'chef/knife/solo_clean'
require 'knife-solo/librarian'
require 'knife-solo/berkshelf'

load File.expand_path('../capistrano-knife-solo/tasks/tasks.rake', __FILE__)

module CapistranoKnifeSolo
  class Helpers

    def self.chef_config
      Chef::Config[:knife][:librarian] = fetch(:knife_librarian)
      Chef::Config[:knife][:berkshelf] = fetch(:knife_berkshelf)
      Chef::Config[:node_path] = fetch(:knife_node_path)
      Chef::Config.cookbook_path = fetch(:knife_cookbook_path)
    end

    def self.knife_config(host)
      ssh_options = fetch(:ssh_options, {})
      options = {}
      options[:ssh_user] = ssh_options[:user] if ssh_options[:user]
      options[:ssh_password] = ssh_options[:password] if ssh_options[:password]
      options[:ssh_port] = ssh_options[:port] if ssh_options[:port]
      options[:identity_file] = ssh_options[:keys][0] if ssh_options.fetch(:keys, [])[0]
      options[:forward_agent] = ssh_options[:forward_agent] if ssh_options[:forward_agent]
      options[:startup_script] = fetch(:knife_startup_script) if fetch(:knife_startup_script)
      options[:sudo_command] = fetch(:knife_sudo_command) if fetch(:knife_sudo_command)
      options[:host_key_verify] = fetch(:knife_host_key_verify) if fetch(:knife_host_key_verify)
      options[:run_list] = roles_to_runlist(host)
      return options
    end

    def self.knife_args(host)
      args = []
      if host.user
        args << "#{ host.user }@#{ host.hostname }"
      else
        args << host.hostname
      end
      args << "#{fetch(:knife_args)}" if fetch(:knife_args)
      return args
    end

    def self.roles_to_runlist(host)
      roles = host.properties.roles.reject { |r| r.to_s.start_with?('server-') or r == :all }
      roles.map! {|r| "role[#{r}]"}
      return roles
    end

  end
end

# monkey patches to avoid the permanent creation of a node config
class Chef
  class Knife
    class SoloCook

      alias vendor_cook cook

      def cook
        # run the knife-solo cook command
        vendor_cook
        # clean up after the config we created
        ui.msg "Removing temporary Node config '#{node_config}'..."
        FileUtils.rm_r node_config
      end

      def node_config
        # create the directory first as it's tmp and may not exist
        FileUtils.mkdir_p Pathname.new(Chef::Config[:node_path])
        # don't default to using args for the path
        Pathname.new("#{nodes_path}/#{node_name}.json")
      end

    end
  end
end
