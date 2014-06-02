require 'capistrano/template'

# don't pollute global namespace
extend Capistrano::Template::Helpers::DSL

import File.join(__dir__, 'template', 'tasks', 'template_defaults.rake')
