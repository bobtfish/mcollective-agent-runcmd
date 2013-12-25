module MCollective
  module Agent
    class Runcmd<RPC::Agent
      action "run" do
        pid = `ps aux | grep nginx | grep master | | grep -v grep | awk '{print $2}' | head -n 1`.chomp
        if pid =~ /^\d+$/
          Log.info("Found PID #{pid} for nginx - sending HUP")
          reply[:status] = system("kill -HUP #{pid}")
        else
          Log.warn("Couldn't find PID for nginx")
          reply.fail! "Could not find PID"
        end
      end

      def config
        Config.instance.pluginconf.reject { |k,v| ! /^runcmd\./.match(k) }
      end

    end
  end
end

