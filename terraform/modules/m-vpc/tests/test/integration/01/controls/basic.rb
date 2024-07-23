public_ip = command("dig TXT +short o-o.myaddr.l.google.com @ns1.google.com").stdout.delete("\n").delete_prefix('"').delete_suffix('"') 

control 'reach_google' do 
  describe host('google.com', port: 80, protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
  end
end

control 'public_subnet' do
  describe http('http://169.254.169.254/latest/meta-data/public-ipv4/') do
    its('body') { should match /[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/ }
    its('body') { should cmp public_ip }
  end
end


control 'private_subnet' do
  describe http('http://169.254.169.254/latest/meta-data/public-ipv4/') do
    its('body') { should match /[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/ }
    its('body') { should_not cmp public_ip }
  end
end

control 'isolated_subnet' do
  describe host('google.com', port: 80, protocol: 'tcp') do
    it { should_not be_reachable }
  end
end
