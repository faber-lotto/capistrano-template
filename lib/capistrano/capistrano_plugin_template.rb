require 'capistrano/template'

include Capistrano::Template::Helpers::DSL

import File.join(__dir__, 'template', 'tasks', 'template_defaults.cap')
