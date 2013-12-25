module MCollective
  module Agent
    class Runcmd<RPC::Agent
      action "run" do
        pid = `ps aux | grep nginx | grep master | awk '{print $2}'`.chomp
        if pid =~ /^\d+$/
          reply[:status] = system("kill -HUP #{pid}")
        else
          reply.fail! "Could not find PID"
        end
      end

      def config
        Config.instance.pluginconf.reject { |k,v| ! /^runcmd\./.match(k) }
      end

    end
  end
end

