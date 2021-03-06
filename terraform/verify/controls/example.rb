
# load data from Terraform output
content = inspec.profile.file('terraform.json')
params = JSON.parse(content)

# store ip in variable
INSTANCE_IP = params['instance_ip_addr']['value']

describe http("http://#{INSTANCE_IP}:3000") do
  its('status') { should eq 200 }
  its('body') { should match /Please do a search/ }
end

describe http("http://#{INSTANCE_IP}:3000/search?search_string=money") do
  its('body') { should match /My restaurants are never opened on Thanksgiving/ }
end

describe http("http://#{INSTANCE_IP}:3000/search?search_string=pqtqrrlmot") do
  its('body') { should match /No matching quote was found/ }
end

describe http("http://#{INSTANCE_IP}:3000/search?search_string=represents+something+bigger") do
  its('body') { should match /A bug is never just a mistake./ }
end
