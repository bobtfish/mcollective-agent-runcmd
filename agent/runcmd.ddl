metadata :name => "runcmd",
         :description => "Run _fixed_ commands on the agent, which come from config",
         :author => "Tomas Doran",
         :license => "Apache2",
         :version => "0.0.2",
         :url => "https://github.com/bobtfish/mcollective-runcmd",
         :timeout => 600

action "run", :description => "Run a specific command" do
  display :always

  input :command,
    :description => "The keyword for the command from the config file",
    :display_as  => "Command name"

  output :status,
    :description => "The command exit code",
    :display_as  => "Exit code"

  output :output,
    :description => "The command stdout/stderr",
    :display_as  => "Exit code"
end

