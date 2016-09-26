[![Gem Version](https://badge.fury.io/rb/capistrano-template.svg)](http://badge.fury.io/rb/capistrano-template)
[![Build Status](https://travis-ci.org/faber-lotto/capistrano-template.svg?branch=master)](https://travis-ci.org/faber-lotto/capistrano-template)
[![Code Climate](https://codeclimate.com/github/faber-lotto/capistrano-template.png)](https://codeclimate.com/github/faber-lotto/capistrano-template)
[![Coverage Status](https://coveralls.io/repos/faber-lotto/capistrano-template/badge.png?branch=master)](https://coveralls.io/r/faber-lotto/capistrano-template?branch=master)

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

## Usage example

In your Capfile:

```ruby
 require 'capistrano/capistrano_plugin_template'
 
 ```
 
 In your task or stage file:
 
 ```ruby
 
   desc 'Upload a rendered erb-template'
   task :setup do     
     on roles :all
       # searchs for template assets.host.site.erb in :templating_paths
       # renders the template and upload it to "#{release_path}/assets.host.site" on all hosts
       # when the new rendered content is changed or the remote file does not exists
       template 'assets.host.site', locals: { 'local1' => 'value local 1'}
     end
     
     on roles :all       
       # searchs for template other.template.name.erb in :templating_paths
       # renders the template and upload it to "~/execute_some_thing.sh" on all hosts
       # when the new rendered content is changed or the remote file does not exists
       # after this the mode is changed to 0750
       # owner is changed to "deployer:www-run"
       template 'other.template.name', '~/execute_some_thing.sh', 0750, 'deployer', 'www-run' ,locals: { 'local1' => 'value local 1'}
     end
          
   end
 
 ```
 
 In your config/deploy/templates/shared/assets.host.site.erb
 
 ```ruby
 # generated by capistrano
 ##########################
 
 server {
    listen 80;
 
   client_max_body_size 4G;
   keepalive_timeout 10;
 
   error_page 500 502 504 /500.html;
   error_page 503 @503;
 
   server_name <%= host.properties.fetch(:host_server_name) %>;
   root <%= remote_path_for(current_path) %>/public;
 
   location ^~ /assets/ {
     gzip_static on;
     expires max;
     add_header Cache-Control public;
 
     if ($request_filename ~* ^.*?\.(eot)|(ttf)|(woff)|(svg)|(otf)$){
       add_header Access-Control-Allow-Origin *;
     }
   }
 
   location = /50x.html {
     root html;
   }
 
   location = /404.html {
     root html;
   }
 
 
   if ($request_method !~ ^(GET|HEAD|PUT|POST|DELETE|OPTIONS)$ ){
     return 405;
   }
 
   if (-f $document_root/system/maintenance.html) {
     return 503;
   }
 
   location ~ \.(php|html)$ {
     return 405;
   }
 }
 
 
 ```

## Settings

This settings can be changed in your Capfile, deploy.rb or stage file.

| Variable              | Default                               | Description                           |
|-----------------------|---------------------------------------|---------------------------------------|
|`templating_digster`   | <code> -&gt;(data){ OpenSSL::Digest::MD5.hexdigest(data)} </code> | Checksum algorythmous for rendered template to check for remote diffs |
|`templating_digest_cmd`| <code>%Q{test "Z$(openssl md5 %&lt;path&gt;s &#124; sed 's/^.*= *//')" = "Z%&lt;digest&gt;s" }</code> | Remote command to validate a digest. Format placeholders path is replaces by full `path` to the remote file and `digest` with the digest calculated in capistrano. |
|`templating_mode_test_cmd` | <code>%Q{ &#91; "Z$(printf "%%.4o" 0$(stat -c "%%a" %&lt;path&gt;s 2&gt;/dev/null &#124;&#124;  stat -f "%%A" %&lt;path&gt;s))" != "Z%&lt;mode&gt;s" &#93; }</code> | Test command to check the remote file permissions. |
|`templating_user_test_cmd` | <code>%Q{ &#91; "Z$(stat -c "%%U" %&lt;path&gt;s 2&gt;/dev/null)" != "Z%&lt;user&gt;s" &#93; }</code> | Test command to check the remote file permissions. |
| `templating_paths` | <code>&#91;"config/deploy/templates/#{fetch(:stage)}/%&lt;host&gt;s",</code> <br> <code> "config/deploy/templates/#{fetch(:stage)}",</code> <br> <code> "config/deploy/templates/shared/%&lt;host&gt;s",</code> <br> <code> "config/deploy/templates/shared"&#93;</code>| Folder to look for a template to render. `<host>` is replaced by the actual host. |


## Contributing

1. Fork it ( http://github.com/faber-lotto/capistrano-template/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
