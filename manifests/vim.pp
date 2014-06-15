# == Class: user_profile::vim
#
# Full description of class profile here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class {'user_profile::vim':}
#
# === Authors
#
# Dustin Brown <dustinjamesbrown@gmail.com>
#
# === Copyright
#
# Copyright 2014 Dustin Brown, unless otherwise noted.
#
class user_profile::vim inherits user_profile::params {

  #Create .vimrc file in home directory
	file {"${user_profile::vim::home_dir}/.vimrc":
		ensure => present,
		source => "puppet:///modules/user_profile/vimrc",
	}

  #Ensure the .vim directory exists as other files/directories will exist in it.
  file {"${user_profile::params::home_dir}/.vim":
    ensure => directory,
  }

  #Bulk directory add/ensure
  file {["${user_profile::params::home_dir}/.vim/bundle",
         "${user_profile::params::home_dir}/.vim/plugin",
         "${user_profile::params::home_dir}/.vim/syntax"]:

    ensure  => directory,
    require => File["${user_profile::params::home_dir}/.vim"],
  }

  #Sym link autoload directory to correct location -- This is limited because the git repo
  # for autoload is actually called pathogen.  So when the git clone is created, it creates
  # a nested autoload directory.  The official installation instructions use curl to install but
  # that would require an exec for puppet.
  file {"${user_profile::params::home_dir}/.vim/autoload":
    ensure  => link,
    require => Vcsrepo["${user_profile::params::home_dir}/.vim/autoload_repo"],
    target  => "${user_profile::params::home_dir}/.vim/autoload_repo/autoload",
  }

  #Git repo for pathogen autoloader
  vcsrepo {"${user_profile::params::home_dir}/.vim/autoload_repo":
    ensure   => latest,
    provider => git,
    require  => File["${user_profile::params::home_dir}/.vim"],
    source   => 'https://github.com/tpope/vim-pathogen.git',
  }

  #Reduce the amount of requires for following git repos
  Vcsrepo {
    require => File["${user_profile::params::home_dir}/.vim/bundle"],
  }

  #Git repo for syntastic plugin
  vcsrepo {"${user_profile::params::home_dir}/.vim/bundle/syntastic":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/scrooloose/syntastic.git',
  }

  #Git repo for puppet plugin
  vcsrepo {"${user_profile::params::home_dir}/.vim/bundle/puppet":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/rodjek/vim-puppet.git',
  }

  #Git repo for tabular plugin
  vcsrepo {"${user_profile::params::home_dir}/.vim/bundle/tabular":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/godlygeek/tabular.git',
  }
}
