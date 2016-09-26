desc 'Upload a rendered erb-template'
task :setup do
  on roles :all do
    # searchs for template other.template.name.erb in :templating_paths
    # renders the template and upload it to "~/execute_some_thing.sh" on all hosts
    # when the new rendered content is changed or the remote file does not exists
    # after this the mode is changed to 0750
    template 'other.template.name',
             './execute_some_thing.sh',
             0o750,
             'deploy',
             'deploy',
             locals: { 'local1' => 'value local 1' }

    puts "PATH: #{pwd_path}"

    within '/var/www' do

      puts "PATH: #{pwd_path}"


      template 'other.template.name',
               './execute_some_thing.sh',
               0o750,
               'deploy',
               'deploy',
               locals: { 'local1' => 'value local 1' }

    end
  end
end
