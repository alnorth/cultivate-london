# -*- mode: ruby -*-
# vi: set ft=ruby :

# apt caching code from https://gist.github.com/millisami/3798773
def local_cache(box_name)
  cache_dir = File.join(File.expand_path('~/.vagrant.d'),
                        'cache',
                        'apt',
                        box_name)
  partial_dir = File.join(cache_dir, 'partial')
  FileUtils.mkdir_p(partial_dir) unless File.exists? partial_dir
  cache_dir
end

Vagrant::Config.run do |config|
  # See online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise32"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  cache_dir = local_cache(config.vm.box)

  config.vm.share_folder "v-cache",
                         "/var/cache/apt/archives/",
                         cache_dir

  config.vm.forward_port 3000, 3000

  config.vm.provision :shell, :path => "vm-setup/setup_dev_vm.sh"
end
