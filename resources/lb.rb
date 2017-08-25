resource_name :lb

property :role, String, default: 'default'

action :attach do

  file '/etc/nginx/conf.d/default.conf' do
    action :delete
  end

  template '/etc/nginx/conf.d/lb.conf' do
    source 'lb.conf'
    # owner 'root'
    # group 'root'
    # mode '0755'
  end

  template '/etc/nginx/nginx.conf' do
    source 'nginx.conf'
    # owner 'root'
    # group 'root'
    # mode '0755'
  end


  directory '/etc/nginx/upstreams' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  nodes = search(:node, "role:#{role}")

  nodes.each do |node|
    file "/etc/nginx/upstreams/#{node['network']['interfaces']['enp0s8']['routes'][0]['src']}.conf" do
      content "server #{node['network']['interfaces']['enp0s8']['routes'][0]['src']};"
      action :create
    end
  end

  service "nginx" do
    action :restart
  end 
end

action :detach do

  nodes = search(:node, "role:#{role}")

  nodes.each do |node|
    file "/etc/nginx/upstreams/#{node['network']['interfaces']['enp0s8']['routes'][0]['src']}.conf" do
      action :delete
    end
  end

  service "nginx" do
    action :restart
  end
end