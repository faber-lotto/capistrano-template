require 'capistrano/template'
require 'sshkit/all'

# don't pollute global namespace
extend Capistrano::Template::Helpers::DSL

SSHKit::Backend::Netssh.send(:include, Capistrano::Template::Helpers::DSL)

# rubocop: disable  Lint/HandleExceptions
begin
  require 'sshkit/backend/printer'
  SSHKit::Backend::Printer.send(:include, Capistrano::Template::Helpers::DSL)
rescue LoadError
end
# rubocop: enable  Lint/HandleExceptions

import File.join(__dir__, 'template', 'tasks', 'template_defaults.rake')
