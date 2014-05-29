class puppetdbtags {
  package { 'puppetdb-ruby':
    ensure   => present,
    provider => pe_gem,
    before   => Cron['puppetdbtags'],
  }
  package { 'aws-sdk':
    ensure   => present,
    provider => pe_gem,
    before   => Cron['puppetdbtags'],
  }

  file{'/opt/puppet/bin/puppetdbtags.rb':
    ensure => file,
    mode   => 0644,
    owner  => pe-puppet,
    group  => pe-puppet,
    source => "puppet:///modules/puppetdbtags/puppetdbtags.rb",
    before => Cron['puppetdbtags'],
  }

  file{'/etc/puppetlabs/puppet/puppetdbtags.yaml':
    ensure  => file,
    mode    => 0600,
    owner   => pe-puppet,
    group   => pe-puppet,
    source  => "puppet:///modules/puppetdbtags/puppetdbtags.yaml",
    replace => false,
    before  => Cron['puppetdbtags'],
  }

  cron { 'puppetdbtags':
    ensure  => present,
    command => '/opt/puppet/bin/ruby /opt/puppet/bin/puppetdbtags.rb',
    user    => pe-puppet,
    minute  => [ '15', '45'],
  }
}
