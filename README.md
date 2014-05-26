[![Gem Version](https://badge.fury.io/rb/capistrano-template.svg)](http://badge.fury.io/rb/capistrano-template)

# Capistrano::Template 

A capistrano 3 plugin that aids in rendering erb templates and
uploads the content to the server if the file does not exists at
the remote host or the content did change. 

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-template'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-template

## Usage

In your Capfile:

```ruby
 require 'capistrano/capistrano_plugin_template'
 
 ```
 
 In your task or stage file:
 
 ```ruby
 
   desc 'Upload a rendered erb-template'
   task :setup do     
     on roles :all       
       template 'assets.host.site'
     end
     
     on roles :all       
       template 'other.template.name', 'execute_some_thing.sh', 0750
     end
          
   end
 
 ```

## Settings

This settings can be changed in your Capfile, deploy.rb or stage file.

| Variable              | Default              | Description                                                           |
|-----------------------|----------------------|-----------------------------------------------------------------------|
|`templating_digster`   | `templating_digster` | Checksum algorythmous for rendered template to check for remote diffs |
|`templating_digest_cmd`| <code>%Q{test "Z$(openssl md5 %&lt;path&gt;s &#124; sed "s/^.*= *//")" = "Z%&lt;digest&gt;s" }</code> | Remote command to validate a digest. Format placeholders path is replaces by full `path` to the remote file and `digest` with the digest calculated in capistrano. |
|`templating_mode_test_cmd` | <code>%Q{ [ "Z$(printf "%%.4o" 0$(stat -c "%%a" %&lt;path&gt;s 2&gt;/dev/null &#124;&#124;  stat -f "%%A" %&lt;path&gt;s))" != "Z%&lt;mode&gt;s" ] }</code> | Test command to check the remote file permissions. |
| `templating_paths` | <code>["config/deploy/templates/#{fetch(:stage)}/%&lt;host&gt;s","config/deploy/templates/#{fetch(:stage)}", "config/deploy/templates/shared/%&lt;host&gt;s","config/deploy/templates/shared"]</code>| Folder to look for a template to render. |


## Contributing

1. Fork it ( http://github.com/<my-github-username>/capistrano-template/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
