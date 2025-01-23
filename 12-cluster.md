---
title: Exploring Remote Resources
teaching: 25
exercises: 10
---

::::::::::::::::::::::::::::::::::::::: objectives

- Survey system resources using `nproc`, `free`, and the queuing system
- Compare \& contrast resources on the local machine, login node, and worker nodes
- Learn about the various filesystems on the cluster using `df`
- Find out `who` else is logged in
- Assess the number of idle and occupied nodes

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- How does my local computer compare to the remote systems?
- How does the login node compare to the compute nodes?
- Are all compute nodes alike?

::::::::::::::::::::::::::::::::::::::::::::::::::

## Look Around the Remote System

If you have not already connected to {{ site.remote.name }}, please do so now:

```bash
{{ site.local.prompt }}  ssh {{ site.remote.user }}@{{ site.remote.login }}
```

Take a look at your home directory on the remote system:

```bash
{{ site.remote.prompt }} ls
```

::::::::::::::::::::::::::::::::::::::  challenge

## What's different between your machine and the remote?

Open a second terminal window on your local computer and run the `ls` command
(without logging in to {{ site.remote.name }}). What differences do you see?

:::::::::::::::  solution

## Solution

You would likely see something more like this:

```bash
{{ site.local.prompt }} ls
```

```output
Applications Documents    Library      Music        Public
Desktop      Downloads    Movies       Pictures
```

The remote computer's home directory shares almost nothing in common with
the local computer: they are completely separate systems!



:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

Most high-performance computing systems run the Linux operating system, which
is built around the UNIX [Filesystem Hierarchy Standard][fshs]. Instead of
having a separate root for each hard drive or storage medium, all files and
devices are anchored to the "root" directory, which is `/`:

```bash
{{ site.remote.prompt }} ls /
```

```output
bin   etc   lib64  proc  sbin     sys  var
boot  {{ site.remote.homedir | replace: "/", "" }}  mnt    root  scratch  tmp  working
dev   lib   opt    run   srv      usr
```

The "{{ site.remote.homedir | replace: "/", "" }}" directory is the one where
we generally want to keep all of our files. Other folders on a UNIX OS contain
system files and change as you install new software or upgrade your OS.

:::::::::::::::::::::::::::::::::::::::::  callout

## Using HPC filesystems

On HPC systems, you have a number of places where you can store your files.
These differ in both the amount of space allocated and whether or not they
are backed up.

- **Home** -- often a *network filesystem*, data stored here is available
  throughout the HPC system, and often backed up periodically. Files stored
  here are typically slower to access, the data is actually stored on another
  computer and is being transmitted and made available over the network!
- **Scratch** -- typically faster than the networked Home directory, but not
  usually backed up, and should not be used for long term storage.
- **Work** -- sometimes provided as an alternative to Scratch space, Work is
  a fast file system accessed over the network. Typically, this will have
  higher performance than your home directory, but lower performance than
  Scratch; it may not be backed up. It differs from Scratch space in that
  files in a work file system are not automatically deleted for you: you must
  manage the space yourself.
  

::::::::::::::::::::::::::::::::::::::::::::::::::

## Nodes

Individual computers that compose a cluster are typically called *nodes*
(although you will also hear people call them *servers*, *computers* and
*machines*). On a cluster, there are different types of nodes for different
types of tasks. The node where you are right now is called the *login node*,
*head node*, *landing pad*, or *submit node*. A login node serves as an access
point to the cluster.

As a gateway, the login node should not be used for time-consuming or
resource-intensive tasks. You should be alert to this, and check with your
site's operators or documentation for details of what is and isn't allowed. It
is well suited for uploading and downloading files, setting up software, and
running tests. Generally speaking, in these lessons, we will avoid running jobs
on the login node.

Who else is logged in to the login node?

```bash
{{ site.remote.prompt }} who
```

This may show only your user ID, but there are likely several other people
(including fellow learners) connected right now.

:::::::::::::::::::::::::::::::::::::::::  callout

## Dedicated Transfer Nodes

If you want to transfer larger amounts of data to or from the cluster, some
systems offer dedicated nodes for data transfers only. The motivation for
this lies in the fact that larger data transfers should not obstruct
operation of the login node for anybody else. Check with your cluster's
documentation or its support team if such a transfer node is available. As a
rule of thumb, consider all transfers of a volume larger than 500 MB to 1 GB
as large. But these numbers change, e.g., depending on the network connection
of yourself and of your cluster or other factors.


::::::::::::::::::::::::::::::::::::::::::::::::::

The real work on a cluster gets done by the *compute* (or *worker*) *nodes*.
compute nodes come in many shapes and sizes, but generally are dedicated to long
or hard tasks that require a lot of computational resources.

All interaction with the compute nodes is handled by a specialized piece of
software called a scheduler (the scheduler used in this lesson is called
{{ site.sched.name }}). We'll learn more about how to use the
scheduler to submit jobs next, but for now, it can also tell us more
information about the compute nodes.

For example, we can view all of the compute nodes by running the command
`{{ site.sched.info }}`.

```bash
{{ site.remote.prompt }} {{ site.sched.info }}
```

```output
PARTITION          AVAIL  TIMELIMIT  NODES  STATE NODELIST
cpubase_bycore_b1*    up   infinite      4   idle node[1-2],smnode[1-2]
node                  up   infinite      2   idle node[1-2]
smnode                up   infinite      2   idle smnode[1-2]
```

A lot of the nodes are busy running work for other users: we are not alone
here!

There are also specialized machines used for managing disk storage, user
authentication, and other infrastructure-related tasks. Although we do not
typically logon to or interact with these machines directly, they enable a
number of key features like ensuring our user account and files are available
throughout the HPC system.

## What's in a Node?

All of the nodes in an HPC system have the same components as your own laptop
or desktop: *CPUs* (sometimes also called *processors* or *cores*), *memory*
(or *RAM*), and *disk* space. CPUs are a computer's tool for actually running
programs and calculations. Information about a current task is stored in the
computer's memory. Disk refers to all storage that can be accessed like a file
system. This is generally storage that can hold data permanently, i.e. data is
still there even if the computer has been restarted. While this storage can be
local (a hard drive installed inside of it), it is more common for nodes to
connect to a shared, remote fileserver or cluster of servers.

![](/fig/node\_anatomy.png){max-width="40%" alt="Node anatomy"}

:::::::::::::::::::::::::::::::::::::::  challenge

## Explore Your Computer

Try to find out the number of CPUs and amount of memory available on your
personal computer.

Note that, if you're logged in to the remote computer cluster, you need to
log out first. To do so, type `Ctrl+d` or `exit`:

```bash
{{ site.remote.prompt }} exit
{{ site.local.prompt }}
```

:::::::::::::::  solution

## Solution

There are several ways to do this. Most operating systems have a graphical
system monitor, like the Windows Task Manager. More detailed information
can be found on the command line:

- Run system utilities
  
  ```bash
  {{ site.local.prompt }} nproc --all
  {{ site.local.prompt }} free -m
  ```

- Read from `/proc`
  
  ```bash
  {{ site.local.prompt }} cat /proc/cpuinfo
  {{ site.local.prompt }} cat /proc/meminfo
  ```

- Run system monitor
  
  ```bash
  {{ site.local.prompt }} htop
  ```

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::  challenge

## Explore the Login Node

Now compare the resources of your computer with those of the login node.

:::::::::::::::  solution

## Solution

```bash
{{ site.local.prompt }} ssh {{ site.remote.user }}@{{ site.remote.login }}
{{ site.remote.prompt }} nproc --all
{{ site.remote.prompt }} free -m
```

You can get more information about the processors using `lscpu`,
and a lot of detail about the memory by reading the file `/proc/meminfo`:

```bash
{{ site.remote.prompt }} less /proc/meminfo
```

You can also explore the available filesystems using `df` to show **d**isk
**f**ree space. The `-h` flag renders the sizes in a human-friendly format,
i.e., GB instead of B. The **t**ype flag `-T` shows what kind of filesystem
each resource is.

```bash
{{ site.remote.prompt }} df -Th
```

::::::::::::::::::::::::::::::::::::::  discussion

## Different results from `df`

- The local filesystems (ext, tmp, xfs, zfs) will depend on whether
  you're on the same login node (or compute node, later on).
- Networked filesystems (beegfs, cifs, gpfs, nfs, pvfs) will be similar
  \-- but may include {{ site.remote.user }}, depending on how it
  is [mounted][mount].
  

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::  callout

## Shared Filesystems

This is an important point to remember: files saved on one node
(computer) are often available everywhere on the cluster!




::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::  challenge

## Explore a Worker Node

Finally, let's look at the resources available on the worker nodes where your
jobs will actually run. Try running this command to see the name, CPUs and
memory available on the worker nodes:

```bash
{{ site.remote.prompt }} sinfo -o "%n %c %m" | column -t
```

::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::  challenge

## Compare Your Computer, the Login Node and the Compute Node

Compare your laptop's number of processors and memory with the numbers you
see on the cluster login node and compute node. What implications do
you think the differences might have on running your research work on the
different systems and nodes?

:::::::::::::::  solution

## Solution

Compute nodes are usually built with processors that have *higher
core-counts* than the login node or personal computers in order to support
highly parallel tasks. Compute nodes usually also have substantially *more
memory (RAM)* installed than a personal computer. More cores tends to help
jobs that depend on some work that is easy to perform in *parallel*, and
more, faster memory is key for large or *complex numerical tasks*.



:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::  callout

## Differences Between Nodes

Many HPC clusters have a variety of nodes optimized for particular workloads.
Some nodes may have larger amount of memory, or specialized resources such as
Graphics Processing Units (GPUs or "video cards").


::::::::::::::::::::::::::::::::::::::::::::::::::

With all of this in mind, we will now cover how to talk to the cluster's
scheduler, and use it to start running our scripts and programs!



[fshs]: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
[mount]: https://en.wikipedia.org/wiki/Mount_\(computing\)


:::::::::::::::::::::::::::::::::::::::: keypoints

- An HPC system is a set of networked machines.
- HPC systems typically provide login nodes and a set of compute nodes.
- The resources found on independent (worker) nodes can vary in volume and type (amount of RAM, processor architecture, availability of network mounted filesystems, etc.).
- Files saved on shared storage are available on all nodes.
- The login node is a shared machine: be considerate of other users.

::::::::::::::::::::::::::::::::::::::::::::::::::


