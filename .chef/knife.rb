# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "trg"
client_key               "#{current_dir}/private.pem"
chef_server_url          "https://api.chef.io/organizations/trg"
cookbook_path            ["#{current_dir}/../cookbooks", '../cookbooks', './cookbooks']

current_dir = File.dirname(__FILE__)
user_email  = `git config --get user.email`
home_dir    = ENV['HOME'] || ENV['HOMEDRIVE']
org         = ENV['chef_org'] || 'trg'

knife_override = "#{home_dir}/.chef/knife_override.rb"

chef_server_url          "https://api.chef.io/organizations/#{org}"
log_level                :info
log_location             STDOUT

# USERNAME is UPPERCASE in Windows, but lowercase in the Chef server,
# so `downcase` it.
#node_name                ( ENV['USER'] || ENV['USERNAME'] ).downcase
#client_key               "#{home_dir}/.chef/#{node_name}.pem"
#cache_type               'BasicFile'
#cache_options( :path => "#{home_dir}/.chef/checksums" )

# We keep our cookbooks in separate repos under a ~/chef/cookbooks dir
cookbook_path            ["#{current_dir}/../cookbooks", '../cookbooks', './cookbooks']
cookbook_copyright       "TRG, Inc."
cookbook_license         "none"
cookbook_email           "#{user_email}"

# Allow overriding values in this knife.rb
Chef::Config.from_file(knife_override) if File.exist?(knife_override)
