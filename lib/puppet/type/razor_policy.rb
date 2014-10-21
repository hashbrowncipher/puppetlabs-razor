Puppet::Type.newtype(:razor_policy) do
  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the policy; used internally by Razor to identify the policy"
  end

  newproperty(:repo) do
    desc "The name of the repo this policy should use."
    munge do |value|
      if value.is_a?(String)
        { "name" => value }
      else
        value
      end
    end
  end

  newproperty(:enabled) do
    desc "Whether or not the policy is enabled."
    defaultto :true
    newvalues(:true, :false)
  end

  newproperty(:task) do
    desc "The name of the task this policy should use."

    munge do |value|
      if value.is_a?(String)
        { "name" => value }
      else
        value
      end
    end
  end

  newproperty(:broker) do
    desc "The name of the broker this policy should use."

    munge do |value|
      if value.is_a?(String)
        { "name" => value }
      else
        value
      end
    end
  end

  newproperty(:hostname_pattern) do
    desc "A pattern for the host names of the nodes bound to the policy"
  end

  newproperty(:root_password) do
    desc "The root password for machines imaged using this policy"
  end

  newproperty(:max_count) do
    desc "The maximum number of machines that should be imaged using this policy"
    munge do |value|
      if value.nil?
        Nil
      else
        value.to_i
      end
    end
  end

  newproperty(:tags, :array_matching => :all) do
    desc "An array of the tags that should be used for matching this policy."
  end

  newproperty(:node_metadata) do
    desc "Metadata that will be merged with the node information."
  end
end
