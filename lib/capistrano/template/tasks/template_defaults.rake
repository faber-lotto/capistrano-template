namespace :load do
  task :defaults do
    set :templating_digster, ->{ ->(data){ Digest::MD5.hexdigest(data)} }
    set :templating_digest_cmd, %Q{test "Z$(openssl md5 %<path>s| sed 's/^.*= *//')" = "Z%<digest>s" } # alternative %Q{echo "%<digest>s %<path>s" | md5sum -c --status }  should return true when the file content is the same
    set :templating_mode_test_cmd, %Q{ [ "Z$(printf "%%.4o" 0$(stat -c "%%a" %<path>s 2>/dev/null ||  stat -f "%%A" %<path>s))" != "Z%<mode>s" ] } # mac uses different mode formatter
    set :templating_paths , ->{ ["config/deploy/templates/#{fetch(:stage)}/%<host>s",
                                 "config/deploy/templates/#{fetch(:stage)}",
                                 "config/deploy/templates/shared/%<host>s",
                                 "config/deploy/templates/shared"].map {|partial_path| (partial_path)} }
  end
end


