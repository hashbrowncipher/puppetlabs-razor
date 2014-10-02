require File.expand_path(File.join(File.dirname(__FILE__), '..', 'http'))
Puppet::Type.type(:razor_repo).provide(:http, :parent => Puppet::Provider::RazorHttpClient) do

  def self.properties
    ["url", "task"]
  end

  def self.razor_type
    "repo"
  end

  def self.format_hash_params(instance_details)
    name = instance_details["name"]
    url = instance_details["iso_url"] || instance_details["url"]
    iso = url == instance_details["iso_url"]

    {
      :name => name,
      :url => url,
      :iso => iso
    }
  end

  def format_create_params
    url_key = resource[:iso] == :true ? "iso-url" : "url"
    {
      :name         => resource[:name],
      :"#{url_key}" => resource[:url],
      :task         => resource[:task],
    }
  end

  def task
    inst = self.class.collection_get("#{self.class.type_plural}", resource[:name])
    inst["task"]["name"]
  end

  # We have to override the default URL getter because of the fact that URL
  # can come in as either 'url' or 'iso-url'
  def url
    repo = self.class.collection_get("repos", resource[:name])
    repo["url"] || repo["iso_url"]
  end

end
