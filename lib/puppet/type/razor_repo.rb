Puppet::Type.newtype(:razor_repo) do
  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the repository; used internally by Razor to identify the repo"
  end

  newproperty(:url) do
    desc "Where the installation materials for this repo can be found"
    validate do |value|
      unless Pathname.new(value).absolute? || URI.parse(value).is_a?(URI::Generic)
        fail("Invalid URL #{value}")
      end
    end
  end

  newparam(:iso) do
    desc "Whether or not the location specified by `url` is an ISO or not"
    defaultto false
    newvalues(true, false)
  end

  newproperty(:task) do
    desc "The task associated with this repo"
  end

end
