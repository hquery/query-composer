namespace :hquery do
  namespace :users do

    desc %{Grant an existing hQuery user administrator privileges.

    You must identify the user by USERNAME or EMAIL:

    $ rake hquery:users:grant_admin USERNAME=###
    or
    $ rake hquery:users:grant_admin EMAIL=xxx}
    task :grant_admin => :environment do
      RakeUserManager.grant_admin ENV
    end

    desc %{Remove the administrator role from an existing hQuery user.

    You must identify the user by USERNAME or EMAIL:

    $ rake hquery:users:revoke_admin USERNAME=###
    or
    $ rake hquery:users:revoke_admin EMAIL=xxx}
    task :revoke_admin => :environment do
      RakeUserManager.revoke_admin ENV
    end
    
    desc %{Approve an existing hQuery user.

    You must identify the user by USERNAME or EMAIL:

    $ rake hquery:users:approve USERNAME=###
    or
    $ rake hquery:users:approve EMAIL=xxx}
    task :approve => :environment do
      RakeUserManager.approve ENV
    end

    class RakeUserManager
      def self.grant_admin(env)
        user = find_user(env)
        raise "#{user.username} is already an administrator." if user.admin?
        user.approve
        user.grant_admin
        puts "#{user.username} is now an administrator"
      end
      def self.revoke_admin(env)
        user = find_user(env)
        raise "#{user.username} is not an administrator." if not user.admin?
        user.revoke_admin
        puts "#{user.username} is no longer an administrator"
      end
      def self.approve(env)
        user = find_user(env)
        raise "#{user.username} is already approved." if user.approved?
        user.approve
        puts "#{user.username} is now approved"
      end

      private 

      def self.find_user(env)
        raise 'must pass USERNAME or EMAIL' unless env['USERNAME'] || env['EMAIL']
        case
          when env.key?('USERNAME')
            user = User.find_by_username env['USERNAME']
          when env.key?('EMAIL')
            user = User.find_by_email env['EMAIL']
        end
        raise 'There is no such user.' unless user
        user
      end
    end


  end
end

