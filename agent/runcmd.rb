require 'etc'

module MCollective
  module Agent
    class Runcmd<RPC::Agent
      action "run" do
        validate :command, String
        data = run_command request[:command]
        reply[:status] = data[:status]
        reply[:output] = data[:output]
      end

      def run_command (command)
        cmdline = config["runcmd.#{command}"]
        dir = config["runcmd.#{command}.cwd"] || '/'
        user = config["runcmd.#{command}.user"] || 'root'
        if cmdline
          Log.info("Found cmd #{command} running: #{cmdline}")
          Dir.chdir(dir) do
            code = as_user(user) { system "#{cmdline}" }
          end
        else
          Log.info("Did not find #{command}")
          code = -256
        end
        { :status => code, :output => '' }
      end

      def as_user(user, &block)
        # Find the user in the password database.
        u = (user.is_a? Integer) ? Etc.getpwuid(user) : Etc.getpwnam(user)
 
        # Fork the child process. Process.fork will run a given block of code
        # in the child process.
        child_pid = Process.fork do
          # We're in the child. Set the process's user ID.
          Process.uid = u.uid
 
          # Invoke the caller's block of code.
          block.call(user)
          exit 0
        end
        Process.wait(child_pid)
        $?.exitstatus
      end 
#        pid = `ps aux | grep nginx | grep master | grep -v grep | awk '{print $2}' | head -n 1`.chomp
#        if pid =~ /^\d+$/
#          Log.info("Found PID #{pid} for nginx - sending HUP")
#          reply[:status] = system("kill -HUP #{pid}")
#        else
#          Log.warn("Couldn't find PID for nginx")
#          reply.fail! "Could not find PID"
#        end

      def config
        Config.instance.pluginconf.reject { |k,v| ! /^runcmd\./.match(k) }
      end

    end
  end
end

