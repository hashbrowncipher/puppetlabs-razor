Puppet::Type.newtype(:razor_tag) do
  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the tag; used internally by Razor to identify the tag"
  end

  newproperty(:rule, :array_matching => :all) do
    desc "The rules that determine whether the tag matches a node."
  end
end
