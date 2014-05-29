PuppetDB -> AWS tags proof of concept

edit the /etc/puppetlabs/puppet/puppetdbtags.yaml file to contain the AWS auth credentials, puppetdb hostname, and certificates needed (this defaults to a Puppet Enteprise path, if you were to install on a PE master).

It sets up a cron job to run the files/puppetdbtags.rb script every 30 minutes, which will check puppetdb for nodes with the "ec2\_instance\_id" fact, then retrieve the services that are indicated as 'running' in the puppetdb catalog for that node, and then adds a tag of 'puppet\_managed\_services' to that node in AWS with a comma seperated list of services.


