# xtreemfs cookbook

This cookbook allows for a quick setup of the [XTREEMFS](http://www.xtreemfs.org/) services in a distributed way.
Up to now, only the Ubuntu versions with [repositories perpared here](http://www.xtreemfs.org/download_pkg.php) are supported in theory, i.e. 9.04 to 12.10.
(In practice, only the more recent versions have been tested.)

# Requirements

- `apt`
- for local testing, `chef-solo-search` and `autoetchosts`

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

All attributes are in the `node[:xtreemfs]` "namespace":

- `user` - the user to run the xtreemfs services ("xtreemfs")
- `group` - its group ("xtreemfs")
- `mrc/dir_service_host` (defaults to "localhost")
- `osd/count` - the number of OSD instances on the host (1)
- `osd/first_listen_port` defaults to 32640
- `osd/first_http_port` defaults to 30640
- `osd/object_base_directory` - the directory where objects will be stored ("/var/lib/xtreemfs/objs/")
- `osd/bind_ip`, `mrc/bind_ip`, `dir/bind_ip` default to `node[:ipaddress]`
- `mrc/listen_port`, `dir/listen_port`, `mrc/http_port`, `dir/http_port` and `dir/snmp_port` default to their XtreemFS defaults
- `mrc/replication` and `dir/replication` - if these services use babudb replication - default to `false`

# Recipes

- `xtreemfs::client`: installs the `xtreemfs-client` package.
- `xtreemfs::dir`: installs the `xtreemfs-server` package and enables the `xtreemfs-dir` service; sets `node[:xtreemfs][:dir][:service]` to true.
- `xtreemfs::mrc`: installs the `xtreemfs-server` package, configures and enables the `xtreemfs-mrc` service; searching for the node with `xtreemfs_dir_service:true`.  Finally, sets `node[:xtreemfs][:mrc][:service]` to true. 
- `xtreemfs::osd`: installs the `xtreemfs-server` package, configures and enables the specified count of OSD instances.  DIR is discovered as in `xtreemfs::mrc`.

# Testing XtreemFS DIR/MRC replication

To test these locally, just spin up the three machines defined in the `Vagrantfile` and the `node` databag:

    vagrant up /x/

Each of these features the DIR and MRC service (both set up to replicate) as well as two OSDs.


# License and Author

Author:: Hendrik Volkmer (<h.volkmer@cloudbau.de>)

Copyright:: 2013, cloudbau GmbH

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
