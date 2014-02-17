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
        if cmdline
          Log.info("Found cmd #{command} running: #{cmdline}")
          code = system "#{cmdline}"
        else
          Log.info("Did not find #{command}")
          code = -256
        end
        { :status => code, :output => '' }
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

