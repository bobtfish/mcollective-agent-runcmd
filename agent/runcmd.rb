require 'etc'
require 'erb'

module MCollective
  module Agent
    class Runcmd<RPC::Agent
      action "run" do
        validate :command, String
        data = run_command request
        reply[:status] = data[:status]
        reply[:output] = data[:output]
        reply[:error] = data[:error]
      end

      def run_command (request_and_params)
        command = request_and_params[:command]
        cmdline = config["runcmd.#{command}"]

        dir = config["runcmd.#{command}.cwd"] || '/'
        user = config["runcmd.#{command}.user"] || 'root'
        if cmdline
          Log.info("Found cmd #{command} running: #{cmdline}")

          interpolated_cmdline = ERB.new(cmdline).result(ERBCtx.new(request_and_params).get_binding)

          Log.info("After interpolated: #{interpolated_cmdline}")

          Dir.chdir(dir) do
            u = (user.is_a? Integer) ? Etc.getpwuid(user) : Etc.getpwnam(user)

            # stdout, stderr pipes
            rout, wout = IO.pipe
            rerr, werr = IO.pipe

            # Fork the child process. Process.fork will run a given block of code
            # in the child process.
            child_pid = Process.fork do
              rout.close
              rerr.close
              $stdout.reopen(wout)
              $stderr.reopen(werr)
              # We're in the child. Set the process's user ID.
              Process.uid = u.uid
              system(interpolated_cmdline)
            end
            # close write ends so we could read them
            wout.close
            werr.close

            Process.wait(child_pid)
            last_exit_status = $?.exitstatus

            stdout = rout.readlines.join("\n")
            stderr = rerr.readlines.join("\n")

            # dispose the read ends of the pipes
            rout.close
            rerr.close
            { :status => last_exit_status, :output => stdout, :error => stderr }
          end
        else
          Log.info("Did not find #{command}")
          { :status => -256, :output => '', :error => "Did not find #{command}" }
        end
      end

      def as_user(user, &block)
        # Find the user in the password database.
        u = (user.is_a? Integer) ? Etc.getpwuid(user) : Etc.getpwnam(user)

        # stdout, stderr pipes
        rout, wout = IO.pipe
        rerr, werr = IO.pipe

        # Fork the child process. Process.fork will run a given block of code
        # in the child process.
        child_pid = Process.fork do
          rout.close
          rerr.close
          $stdout.reopen(wout)
          $stderr.reopen(werr)
          # We're in the child. Set the process's user ID.
          Process.uid = u.uid
 
          # Invoke the caller's block of code.
          block.call(user)
          exit 0
        end
        # close write ends so we could read them
        wout.close
        werr.close

        Process.wait(child_pid)
        last_exit_status = $?.exitstatus

        stdout = rout.readlines.join("\n")
        stderr = rerr.readlines.join("\n")

        # dispose the read ends of the pipes
        rout.close
        rerr.close
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
    class ERBCtx
      def initialize(request)
        request.data.each_pair do |key, value|
          raise("Value #{value} for key #{key.to_s} not simple, avoiding quoting issues or shell injection by just bailing, sorry") unless value =~ /^[\w-]+$/
          instance_variable_set('@' + key.to_s, value)
        end
      end

      def get_binding
        binding
      end
    end
  end
end

