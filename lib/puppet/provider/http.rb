require "rubygems"
require "json"
require "net/http"

class Puppet::Provider::RazorHttpClient < Puppet::Provider
  @@client = Net::HTTP.new("localhost", 8080)

  def self.type_plural
    "#{self.razor_type}s"
  end

  def initialize(*d, &b)
    super(*d, &b)
    self.class.create_getters self.find_missing_getters
    self.class.create_setters self.find_missing_setters
  end

  def self.create_getters(properties)
    # Define default getters if they haven't already been defined
    properties.each do |property|
      define_method property do
        inst = self.class.collection_get("#{self.class.type_plural}", resource[:name])
        inst[property].to_s
      end
    end
  end

  def self.create_setters(properties)
    properties.each do |property|
      define_method "#{property}=" do |value|
        self.destroy
        self.create
      end
    end
  end

  def find_missing_getters
    self.class.properties().select { |property|
      !self.respond_to? property
    }
  end

  def find_missing_setters
    self.class.properties().select { |property|
      !self.respond_to? "#{property}="
    }
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
    insts = self.collection_list("#{self.type_plural}")
    insts['items'].collect do |instance|
      instance_details = self.collection_get("#{self.type_plural}", instance["name"])
      hash_params = self.format_hash_params(instance_details)
      new(hash_params)
    end
  end

  def self.format_hash_params(instance_details)
    instance_details
  end

  def create
    path = "/api/commands/create-#{self.class.razor_type}"
    data = self.format_create_params
    status_code, body = self.class.http_post(path, data)
    fail("Error creating #{self.class.razor_type} #{resource[:name]}: #{status_code} #{body}") unless status_code == 202
  end

  def format_create_params
    default_create_params
  end

  def default_create_params
    params = {
      :name => resource[:name]
    }
    self.class.properties().each { |prop|
      index = prop.to_sym
      params[index] = resource[index]
    }
    params
  end

  def destroy
    path = "/api/commands/delete-#{self.class.razor_type}"
    data = {
      :name    => resource[:name],
    }
    status_code, body = self.class.http_post(path, data)
    fail("Error destroying #{self.class.razor_type} #{resource[:name]}: #{status_code} #{body}") unless status_code == 202
  end

  def self.http_get(path, as_json=true)
    response = @@client.request_get(path)
    return response.code.to_i, (as_json ? JSON.load(response.body) : response.body)
  end

  def self.http_post(path, data, as_json=true)
    headers = {
      "Content-Type" => "application/json"
    }
    response = @@client.request_post(path, data.to_json, headers)
    return_data = response.body
    if as_json
      begin
        return_data = JSON.load(response.body)
      rescue Exception => e
        self.post_failure(path, response.code, "posted #{data.to_json} Could not parse JSON from: #{response.body}")
      end
    end
    return response.code.to_i, return_data 
  end

  def self.collection_has?(collection_type, identifier)
    path = "/api/collections/#{collection_type}/#{identifier}"
    status_code, body = self.http_get(path, as_json=false)
    if status_code == 200
      true
    elsif status_code == 404
      false
    else
      self.post_failure(path, status_code, body)
    end
  end

  def self.collection_list(collection_type)
    path = "/api/collections/#{collection_type}"
    status_code, body = self.http_get(path)

    self.post_failure(path, status_code, body) unless status_code == 200
    body
  end

  def self.collection_get(collection_type, identifier)
    path = "/api/collections/#{collection_type}/#{identifier}"
    status_code, body = self.http_get(path)

    self.post_failure(path, status_code, body, identifier) unless status_code == 200
    body
  end

  def self.post_failure(path, status_code, body, ident=nil)
    activity = ident ? "retrieving #{self.razor_type} #{ident}" : "contacting razor server"
    fail("Unexpected response #{activity}: from #{path} #{status_code} #{body}")
  end

end
