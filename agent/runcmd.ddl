metadata :name => "runcmd",
         :description => "Run _fixed_ commands on the agent, which come from config",
         :author => "Tomas Doran",
         :license => "Apache2",
         :version => "0.0.1",
         :url => "https://github.com/bobtfish/mcollective-runcmd",
         :timeout => 10

action "run", :description => "Run a specific command" do
  display :always

  output :status,
    :description => "The command exit code",
    :display_as  => "Exit code"

end

