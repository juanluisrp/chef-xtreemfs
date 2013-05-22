# xtreemfs cookbook

This cookbook allows for a quick setup of the [XTREEMFS](http://www.xtreemfs.org/) services in a distributed way.
Up to now, only the Ubuntu versions with [repositories perpared here](http://www.xtreemfs.org/download_pkg.php) are supported in theory, i.e. 9.04 to 12.10.
(In practice, only the more recent versions have been tested.)

# Requirements

- `apt`

# Usage

Just spread the recipes `xtreemfs::dir`, `xtreemfs::mrc` and `xtreemfs::osd` over your servers.
Note that until now, only using _one_ directory service is supported.
Also the convention is followed that the OSD's directories are their _number_, below the `object_base_directory`.
Thus, with `node[:xtreemfs][:osd][:object_base_directory] = "/var/lib/xtreemfs/objs/"` (the default), the storage directories will be laid out as follows:

```bash
/var/lib/xtreemfs/objs/0
/var/lib/xtreemfs/objs/1
/var/lib/xtreemfs/objs/2
...
```

# Attributes

- `node[:xtreemfs][:user]` - the user to run the xtreemfs services ("xtreemfs")
- `node[:xtreemfs][:group]` - its group ("xtreemfs")
- `node[:xtreemfs][:mrc][:dir_service_host]` (defaults to "localhost")
- `node[:xtreemfs][:osd][:count]` - the number of OSD instances on the host (1)
- `node[:xtreemfs][:osd][:first_listen_port]` defaults to 32640
- `node[:xtreemfs][:osd][:first_http_port]` defaults to 30640
- `node[:xtreemfs][:osd][:bind_ip]`, `node[:xtreemfs][:mrc][:bind_ip]`, `node[:xtreemfs][:dir][:bind_ip]` defaulting to `node[:ipaddress]`
- `node[:xtreemfs][:osd][:object_base_directory]` - the directory where objects will be stored ("/var/lib/xtreemfs/objs/")

# Recipes

- `xtreemfs::client`: installs the `xtreemfs-client` package.
- `xtreemfs::dir`: installs the `xtreemfs-server` package and enables the `xtreemfs-dir` service; sets `node[:xtreemfs][:dir][:service]` to true.
- `xtreemfs::mrc`: installs the `xtreemfs-server` package, configures and enables the `xtreemfs-mrc` service; searching for the node with `xtreemfs_dir_service:true`.  Finally, sets `node[:xtreemfs][:mrc][:service]` to true. 
- `xtreemfs::osd`: installs the `xtreemfs-server` package, configures and enables the specified count of OSD instances.  DIR is discovered as in `xtreemfs::mrc`.

# Author

Author:: Hendrik Volkmer (<h.volkmer@cloudbau.de>)
