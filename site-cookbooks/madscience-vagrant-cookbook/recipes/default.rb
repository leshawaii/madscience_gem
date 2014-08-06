#
# Cookbook Name:: madscience-vagrant-cookbook
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

##### First, Install Vagrant and VirtualBox with appropriate versions and plugins.

# Default attributes in a cookbook override default
# attributes in an attributes file, like the one
# in vagrant-cookbook/attributes/default.rb.
node.default['vagrant']['plugins'] = [ 'vagrant-omnibus' ]

case node['platform_family']
when 'fedora'
  if node['kernel']['machine'] == 'x86_64'
    node.default['vagrant']['url'] = 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.rpm'
  else
    node.default['vagrant']['url'] = 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_32.rpm'
  end
when 'rhel'
  if node['kernel']['machine'] == 'x86_64'
    node.default['vagrant']['url'] = 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.rpm'
  else
    node.default['vagrant']['url'] = 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_32.rpm'
  end
when 'debian'
  if node['kernel']['machine'] == 'x86_64'
    node.default['vagrant']['url'] = 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb'
  else
    node.default['vagrant']['url'] = 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_32.deb'
  end
when 'windows'
  # TODO: find real MSI version
  node.default['vagrant']['url'] = 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3.msi'
when 'mac_os_x'
  node.default['vagrant']['url'] = 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3.dmg'
else
  raise "Don't recognize OS family: #{node['platform_family'].inspect}!"
end

case node['platform_family']
when 'mac_os_x'
  node.default['virtualbox']['url'] = 'http://download.virtualbox.org/virtualbox/4.3.12/VirtualBox-4.3.12-93733-OSX.dmg'
when 'windows'
  node.default['virtualbox']['url'] = 'http://download.virtualbox.org/virtualbox/4.3.12/VirtualBox-4.3.12-93733-Win.exe'
  node.default['virtualbox']['version'] = Vbox::Helpers.vbox_version(node['virtualbox']['url'])
when 'debian', 'rhel'
  node.default['virtualbox']['version'] = '4.3'
end


# This will include the OS-appropriate recipe
include_recipe "vagrant"
include_recipe "virtualbox"

##### Second, set up a local directory of deploy credentials if not already present.

# TODO: Test this on Windows
homedir = ENV['HOME'] || ENV['userprofile']
creds_dir = File.join(homedir, ".deploy_credentials")

# TODO: what's this on Windows?
user = ENV['SUDO_USER'] || ENV['USER']

directory creds_dir do
  owner user
  group user
  mode "0700"
end

# TODO: what is Windows equivalent?
execute "generate ssh keys for #{user}." do
  user user
  creates File.join(creds_dir, "id_rsa_4096.pub")
  command "ssh-keygen -t rsa -q -f #{File.join creds_dir, "id_rsa_4096"} -P \"\""
end

# TODO: do what on Windows? Read file in cookbook and then assert contents?
link File.join(creds_dir, "authorized_keys") do
  user user
  group user
  to "id_rsa_4096.pub"
end
