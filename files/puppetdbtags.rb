#!/opt/puppet/bin/ruby

require 'puppetdb'
require 'aws-sdk'
require 'yaml'

config = YAML::load(File.open('/etc/puppetlabs/puppet/puppetdbtags.yaml'))

AWS.config({
  :access_key_id => config['access_key_id'],
  :secret_access_key => config['secret_access_key'],
  :region => config['aws_region']
})


client = PuppetDB::Client.new({
  :server => "https://#{config['puppetdb']}:8081",
  :pem => {
    'key' => config['private_key'],
    'cert' => config['cert'],
    'ca_file' => config['ca_file']
  }
})

def retrieve_services(certname, conn)
  services = Array.new
  response = conn.request(
    'resources',
	  [:and,
	       	[:'=', 'certname', "#{certname}" ],
		  [:'=', 'type', 'Service'],
		  [:'=', ['parameter', 'ensure'], 'running']
  ])
  response.data.each { |x| services.push(x['title']) }
  return services
end

def find_instances(conn)
  instances = Hash.new
  response = conn.request(
    'facts',
    [:'=', 'name', 'ec2_instance_id'] )
  response.data.each { |x| instances[x['value']] = x['certname'] }
  return instances
end

def update_tags(instances)
  ec2 = AWS::EC2.new
  instances.each do |instance, tags|
    ec2.tags.create(ec2.instances[instance], 'puppet_managed_services', value: tags.join(","))
  end
end

instance_tags = Hash.new

# all that matters is instance-id for updating tags anyway
find_instances(client).each do |instance, certname|
  instance_tags[instance] = retrieve_services(certname, client)
end

puts instance_tags

update_tags(instance_tags)
