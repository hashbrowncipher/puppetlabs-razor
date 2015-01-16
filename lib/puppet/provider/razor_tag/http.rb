require File.expand_path(File.join(File.dirname(__FILE__), '..', 'http'))
Puppet::Type.type(:razor_tag).provide(:http, :parent => Puppet::Provider::RazorHttpClient) do
  def self.properties
    ["rule"]
  end

  def self.razor_type
    "tag"
  end

  def rule
    inst = self.class.collection_get("#{self.class.type_plural}", resource[:name])
    inst["rule"]
  end

  def rule=(new_rule)
    self.class.http_post("/api/commands/update-tag-rule", {
      :name => resource[:name],
      :rule => new_rule,
      :force => true
    })
  end
end
