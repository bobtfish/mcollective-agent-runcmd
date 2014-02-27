metadata :name => "runcmd",
         :description => "Run _fixed_ commands on the agent, which come from config",
         :author => "Tomas Doran",
         :license => "Apache2",
         :version => "0.0.2",
         :url => "https://github.com/bobtfish/mcollective-runcmd",
         :timeout => 6000

action "run", :description => "Run a specific command" do
  display :always

  input :command,
    :description => "The keyword for the command from the config file",
    :display_as  => "Command name",
    :optional    => false,
    :prompt      => "Command: ",
    :type        => :string,
    :validation  => '^[a-zA-Z\-_\d]+$',
    :maxlength   => 50

  output :status,
    :description => "The command exit code",
    :display_as  => "Exit code"

  output :output,
    :description => "The command stdout",
    :display_as  => "STDOUT"
  output :error,
    :description => "The command stderr",
    :display_as  => "STDERR"
end

