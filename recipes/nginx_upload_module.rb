#
# Cookbook Name:: nginx
# Recipe:: nginx_upload_module
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

udm_src_filename = ::File.basename(node['nginx']['upload_module']['source_url'])
udm_src_filepath = "#{Chef::Config['file_cache_path']}/#{udm_src_filename}"
udm_extract_path = "#{Chef::Config['file_cache_path']}/nginx_upload_module/#{node['nginx']['upload_module']['source_checksum']}"

remote_file udm_src_filepath do
  source node['nginx']['upload_module']['source_url']
  checksum node['nginx']['upload_module']['source_checksum']
  owner 'root'
  group 'root'
  mode 0644
end

bash "extract_upload_module" do
  cwd ::File.dirname(udm_src_filepath)
  code <<-EOH
    mkdir -p #{udm_extract_path}
    tar zxf #{udm_src_filename} -C #{udm_extract_path}
    mv #{udm_extract_path}/*/* #{udm_extract_path}/
  EOH

  not_if { ::File.exists?(udm_extract_path) }
end

node.run_state['nginx_configure_flags'] =
    node.run_state['nginx_configure_flags'] | ["--add-module=#{udm_extract_path}", "--with-cc-opt='-Wno-error'"]
