require File.expand_path(File.join(File.dirname(__FILE__), '..', 'http'))
Puppet::Type.type(:razor_tag).provide(:http, :parent => Puppet::Provider::RazorHttpClient) do
  def self.properties
    ["rule"]
  end

  def self.razor_type
    "tag"
  end

  def self.type_plural
    "tags"
  end

  def rule
    inst = self.class.collection_get("#{self.class.type_plural}", resource[:name])
    inst["rule"]
  end
end
