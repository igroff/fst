# File System Templates

## What?
  It's a super simple mechanism to create, maintain, and version stock filesystem
  layouts or 'templates'. The idea being that all sorts of things are done on
  top of a common [directory] layout, such as building npm packages, express apps,
  web sites, etc. thus having a repeatable template for starting these projects
  would be awesome.  

## Why?
  There are systems out there that do something like this, but they're generally
  aimed at some more specific use case. This system is designed with the only
  assumption being that you're going to interact with 'file system stuff'.

### Installation
      fst install <repo url>

  Installation is about as simple as it can get, fst copies itself to ~/.bin (making it if it doesn't exist) and clones your template repo specified.  fst will use ~/.fst as it's working directory, and this is the location that your repo will be cloned for use by fst.  Install WILL REPLACE your existing repo in ~/.fst (i.e. it will remove the existing one and clone anew).


##### Create a Template from a Directory
      fst --store <dirname> [--name <template name>] 

  Creates or updates a template from the directory named \<dirname\>, optionally one can specify a name <template name> that will be used to name the template.  If no template name is provided the name of the directory from <dirname> will be used.  
  
  In the case of an update ( the provided template name matches that of an existing template ), the changes will be applied over the existing template. Don't worry the old one is still there in the event of something awful this is, afterall built on top of git.

##### Use a Template
      fst <template name> [<destination dir>]

  Unpacks a template to the directory specified by <destination dir>. If the
  directory specified exists, the template will unpack 'over' it replacing items
  where conflicts occur.  If <destination dir> is not provided, the template
  will be unpacked into the current directory within a directory named the
  same as the template overlaying any existing directory and contents of the same
  name.


##### Show me my Templates
      fst

  Displays all the templates that fst knows about as it is currently configured.
