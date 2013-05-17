# http://tickets.opscode.com/browse/CHEF-3739
# the method proposed there doesn't help since xtreemfs is not in /proc/filesystems
# and cannot (?) be mounted using `mount.fuse`
# (used in recipes/client.rb)
class Chef::Provider::Mount::Mount
  def device_should_exist?
    # On linux /proc/filesystems lists the known filesystems, and some
    # options for them.  format is options\ttype, thus the reverse
    # If we can't read that, fall back to something simple.
    fstype = @new_resource.fstype
    return false if fstype == "xtreemfs"
    begin
      types = Hash[*::File.open("/proc/filesystems", "r").read.split(/\n|\t/).reverse]
    rescue Errno::ENOENT
      types = { "tmpfs" => "nodev", "fuse" => "nodev" }
    end
    not( types.has_key?(fstype) and types[fstype] == "nodev")
  end
end
