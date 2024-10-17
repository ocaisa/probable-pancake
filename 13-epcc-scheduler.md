---
title: "EPCC version - Working with the scheduler"
teaching: 50
exercises: 30
---



::: questions
 - "What is a scheduler and why are they used?"
 - "How do I launch a program to run on any one node in the cluster?"
 - "How do I capture the output of a program that is run on a node in the
   cluster?"
:::

::: objectives
 - "Run a simple Hello World style program on the cluster."
 - "Submit a simple Hello World style script to the cluster."
 - "Use the batch system command line tools to monitor the execution of your
   job."
 - "Inspect the output and error files of your jobs."
:::

## Job Scheduler

An HPC system might have thousands of nodes and thousands of users. How do we
decide who gets what and when? How do we ensure that a task is run with the
resources it needs? This job is handled by a special piece of software called
the scheduler. On an HPC system, the scheduler manages which jobs run where and
when.

The following illustration compares these tasks of a job scheduler to a waiter
in a restaurant. If you can relate to an instance where you had to wait for a
while in a queue to get in to a popular restaurant, then you may now understand
why sometimes your job do not start instantly as in your laptop.

![The waiter scheduler](fig/restaurant_queue_manager.svg){caption="" alt="Compare a job scheduler to a waiter in a restaurant"}

The scheduler used in this lesson is Slurm. Although
Slurm is not used everywhere, running jobs is quite similar
regardless of what software is being used. The exact syntax might change, but
the concepts remain the same.

## Running a Batch Job

The most basic use of the scheduler is to run a command non-interactively. Any
command (or series of commands) that you want to run on the cluster is called a
*job*, and the process of using a scheduler to run the job is called *batch job
submission*.

In this case, the job we want to run is just a shell script. Let's create a
demo shell script to run as a test. The landing pad will have a number of
terminal-based text editors installed. Use whichever you prefer. Unsure? `nano`
is a pretty good, basic choice.

```bash
userid@ln03:~> nano example-job.sh
userid@ln03:~> chmod +x example-job.sh
userid@ln03:~> cat example-job.sh
```

```output
#!/bin/bash

echo -n "This script is running on "
hostname
```

::: challenge
## Creating Our Test Job

Run the script. Does it execute on the cluster or just our login node?

```bash
userid@ln03:~> ./example-job.sh
```

::: solution

```output
This script is running on ln03
```
This job runs on the login node.
:::
:::

If you completed the previous challenge successfully, you probably realise that
there is a distinction between running the job through the scheduler and just
"running it". To submit this job to the scheduler, we use the
`sbatch` command.

```bash
userid@ln03:~> sbatch --partition=standard --qos=short example-job.sh
```

```output
sbatch: Warning: Your job has no time specification (--time=) and the default time is short. You can cancel your job with 'scancel <JOB_ID>' if you wish to resubmit.
sbatch: Warning: It appears your working directory may be on the home filesystem. It is /home2/home/ta114/ta114/userid. This is not available from the compute nodes - please check that this is what you intended. You can cancel your job with 'scancel <JOBID>' if you wish to resubmit.
Submitted batch job 286949
```

Ah! What went wrong here? Slurm is telling us that the file system we are currently on, `/home`, is not available
on the compute nodes and that we are getting the default, short runtime. We will deal with the runtime 
later, but we need to move to a different file system to submit the job and have it visible to the 
compute nodes. On ARCHER2, this is the `/work` file system. The path is similar to home but with 
`/work` at the start. Lets move there now, copy our job script across and resubmit:

```bash
userid@ln03:~> cd /work/ta114/ta114/userid
userid@uan01:/work/ta114/ta114/userid> cp ~/example-job.sh .
userid@uan01:/work/ta114/ta114/userid> sbatch --partition=standard --qos=short example-job.sh
```

```output
Submitted batch job 36855
```

That's better! And that's all we need to do to submit a job. Our work is done --- now the
scheduler takes over and tries to run the job for us. While the job is waiting
to run, it goes into a list of jobs called the *queue*. To check on our job's
status, we check the queue using the command
`squeue -u userid`.

```bash
userid@uan01:/work/ta114/ta114/userid> squeue -u userid
```


```output
JOBID USER         ACCOUNT     NAME           ST REASON START_TIME         T...
36856 yourUsername yourAccount example-job.sh R  None   2017-07-01T16:47:02 ...
```

We can see all the details of our job, most importantly that it is in the `R`
or `RUNNING` state. Sometimes our jobs might need to wait in a queue
(`PENDING`) or have an error (`E`).

The best way to check our job's status is with `squeue`. Of
course, running `squeue` repeatedly to check on things can be
a little tiresome. To see a real-time view of our jobs, we can use the `watch`
command. `watch` reruns a given command at 2-second intervals. This is too
frequent, and will likely upset your system administrator. You can change the
interval to a more reasonable value, for example 15 seconds, with the `-n 15`
parameter. Let's try using it to monitor another job.

```bash
userid@uan01:/work/ta114/ta114/userid> sbatch --partition=standard --qos=short example-job.sh
userid@uan01:/work/ta114/ta114/userid> watch -n 15 squeue -u userid
```

You should see an auto-updating display of your job's status. When it finishes,
it will disappear from the queue. Press `Ctrl-c` when you want to stop the
`watch` command.

::: discussion
## Where's the Output?
On the login node, this script printed output to the terminal --- but
when we exit `watch`, there's nothing. Where'd it go?
HPC job output is typically redirected to a file in the directory you
launched it from. Use `ls` to find and read the file.
:::

## Customising a Job

The job we just ran used some of the scheduler's default options. In a
real-world scenario, that's probably not what we want. The default options
represent a reasonable minimum. Chances are, we will need more cores, more
memory, more time, among other special considerations. To get access to these
resources we must customize our job script.

Comments in UNIX shell scripts (denoted by `#`) are typically ignored, but
there are exceptions. For instance the special `#!` comment at the beginning of
scripts specifies what program should be used to run it (you'll typically see
`#!/bin/bash`). Schedulers like Slurm also
have a special comment used to denote special scheduler-specific options.
Though these comments differ from scheduler to scheduler,
Slurm's special comment is `#SBATCH`. Anything
following the `#SBATCH` comment is interpreted as an
instruction to the scheduler.

Let's illustrate this by example. By default, a job's name is the name of the
script, but the `--job-name` option can be used to change the
name of a job. Add an option to the script:

```bash
userid@uan01:/work/ta114/ta114/userid> cat example-job.sh
```

```output
#!/bin/bash
#SBATCH --job-name new_name

echo -n "This script is running on "
hostname
echo "This script has finished successfully."
```

Submit the job and monitor its status:

```bash
userid@uan01:/work/ta114/ta114/userid> sbatch --partition=standard --qos=short example-job.sh
userid@uan01:/work/ta114/ta114/userid> squeue -u userid
```


```output
JOBID USER         ACCOUNT     NAME     ST REASON   START_TIME TIME TIME_LEFT NODES CPUS
38191 yourUsername yourAccount new_name PD Priority N/A        0:00 1:00:00   1     1
```

Fantastic, we've successfully changed the name of our job!

### Resource Requests

But what about more important changes, such as the number of cores and memory
for our jobs? One thing that is absolutely critical when working on an HPC
system is specifying the resources required to run a job. This allows the
scheduler to find the right time and place to schedule our job. If you do not
specify requirements (such as the amount of time you need), you will likely be
stuck with your site's default resources, which is probably not what you want.

The following are several key resource requests:


* `--nodes=<nodes>` - Number of nodes to use
* `--ntasks-per-node=<tasks-per-node>` - Number of parallel processes per node
* `--cpus-per-task=<cpus-per-task>` - Number of cores to assign to each parallel process
* `--time=<days-hours:minutes:seconds>` - Maximum real-world time (walltime)
your job will be allowed to run. The `<days>` part can be omitted.

Note that just *requesting* these resources does not make your job run faster,
nor does it necessarily mean that you will consume all of these resources. It
only means that these are made available to you. Your job may end up using less
memory, or less time, or fewer tasks or nodes, than you have requested, and it
will still run.

It's best if your requests accurately reflect your job's requirements. We'll
talk more about how to make sure that you're using resources effectively in a
later episode of this lesson.

::: callout
## Command line options or job script options?
All of the options we specify can be supplied on the command line (as we
do here for `--partition=standard`) or in the job script (as we have done
for the job name above). These are interchangeable. It is often more convenient
to put the options in the job script as it avoids lots of typing at the command
line.
:::

::: challenge
## Submitting Resource Requests
Modify our `hostname` script so that it runs for a minute, then submit a job
for it on the cluster. You should also move all the options we have been specifying
on the command line (e.g. `--partition`) into the script at this point.

::: solution

```bash
userid@uan01:/work/ta114/ta114/userid> cat example-job.sh
```

```output
#!/bin/bash
#SBATCH --time 00:01:15
#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --reservation=shortqos
echo -n "This script is running on "
sleep 60 # time in seconds
hostname
echo "This script has finished successfully."
```

```bash
userid@ln03:~> sbatch example-job.sh
```

Why are the Slurm runtime and `sleep` time not identical?
:::
:::



::: challenge
## Job environment variables

When Slurm runs a job, it sets a number of environment variables for the job. One of these will
let us check our work from the last problem. The `SLURM_CPUS_PER_TASK` variable is set to the
number of CPUs we requested with `-c`. Using the `SLURM_CPUS_PER_TASK` variable, modify your job
so that it prints how many CPUs have been allocated.

:::

Resource requests are typically binding. If you exceed them, your job will be
killed. Let's use walltime as an example. We will request 30 seconds of
walltime, and attempt to run a job for two minutes.

```bash
userid@uan01:/work/ta114/ta114/userid> cat example-job.sh
```

```output
#!/bin/bash
#SBATCH --job-name long_job
#SBATCH --time 00:00:30
#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --reservation=shortqos

echo "This script is running on ... "
sleep 120 # time in seconds
hostname
echo "This script has finished successfully."
```

Submit the job and wait for it to finish. Once it is has finished, check the
log file.

```bash
userid@uan01:/work/ta114/ta114/userid> sbatch example-job.sh
userid@uan01:/work/ta114/ta114/userid> watch -n 15 squeue -u userid
```


```bash
userid@uan01:/work/ta114/ta114/userid> cat slurm-38193.out
```

```output
This job is running on:
nid001147
slurmstepd: error: *** JOB 38193 ON cn01 CANCELLED AT 2017-07-02T16:35:48 DUE TO TIME LIMIT ***
```

Our job was killed for exceeding the amount of resources it requested. Although
this appears harsh, this is actually a feature. Strict adherence to resource
requests allows the scheduler to find the best possible place for your jobs.
Even more importantly, it ensures that another user cannot use more resources
than they've been given. If another user messes up and accidentally attempts to
use all of the cores or memory on a node, Slurm will either
restrain their job to the requested resources or kill the job outright. Other
jobs on the node will be unaffected. This means that one user cannot mess up
the experience of others, the only jobs affected by a mistake in scheduling
will be their own.

::: callout
## But how much does it cost?
Although your job will be killed if it exceeds the selected runtime,
a job that completes within the time limit is only charged for the
time it actually used. However, you should always try and specify a
wallclock limit that is close to (but greater than!) the expected
runtime as this will enable your job to be scheduled more
quickly.
If you say your job will run for an hour, the scheduler has
to wait until a full hour becomes free on the machine. If it only ever
runs for 5 minutes, you could have set a limit of 10 minutes and it
might have been run earlier in the gaps between other users' jobs.
:::

## Cancelling a Job

Sometimes we'll make a mistake and need to cancel a job. This can be done with
the `scancel` command. Let's submit a job and then cancel it using
its job number (remember to change the walltime so that it runs long enough for
you to cancel it before it is killed!).

```bash
userid@uan01:/work/ta114/ta114/userid> sbatch example-job.sh
userid@uan01:/work/ta114/ta114/userid> squeue -u userid
```


```output
Submitted batch job 38759

JOBID USER         ACCOUNT     NAME           ST REASON   START_TIME TIME TIME_LEFT NODES CPUS
38759 yourUsername yourAccount example-job.sh PD Priority N/A        0:00 1:00      1     1
```

Now cancel the job with its job number (printed in your terminal). Absence of any
job info indicates that the job has been successfully cancelled.

```bash
userid@uan01:/work/ta114/ta114/userid> scancel 38759
# It might take a minute for the job to disappear from the queue...
userid@uan01:/work/ta114/ta114/userid> squeue -u userid
```


```output
JOBID  USER  ACCOUNT  NAME  ST  REASON  START_TIME  TIME  TIME_LEFT  NODES  CPUS
```


::: challenge
## Cancelling multiple jobs
We can also cancel all of our jobs at once using the `-u` option. This will delete all jobs for a
specific user (in this case us). Note that you can only delete your own jobs.
Try submitting multiple jobs and then cancelling them all with `scancel -u yourUsername`.
:::

## Other Types of Jobs

Up to this point, we've focused on running jobs in batch mode.
Slurm also provides the ability to start an interactive session.

There are very frequently tasks that need to be done interactively. Creating an
entire job script might be overkill, but the amount of resources required is
too much for a login node to handle. A good example of this might be building a
genome index for alignment with a tool like
[HISAT2](https://ccb.jhu.edu/software/hisat2/index.shtml). Fortunately, we can
run these types of tasks as a one-off with `srun`.


`srun` runs a single command in the queue system and then exits.
Let's demonstrate this by running the
`hostname` command with `srun`. (We can cancel an `srun` job with `Ctrl-c`.)

```bash
 srun --partition=standard --qos=short --time=00:01:00 hostname
```
```output
nid001976
```

`srun` accepts all of the same options as `sbatch`. However, instead of specifying these in a
script, these options are specified on the command-line when starting a job.

Typically, the resulting shell environment will be the same as that for
`sbatch`.

### Interactive jobs

Sometimes, you will need a lot of resource for interactive use. Perhaps it's our first time running
an analysis or we are attempting to debug something that went wrong with a previous job.
Fortunately, SLURM makes it easy to start an interactive job with `srun`:

```bash
 srun --partition=standard --qos=short --pty /bin/bash
```

You should be presented with a bash prompt. Note that the prompt may change
to reflect your new location, in this case the compute node we are logged on.
You can also verify this with `hostname`.

When you are done with the interactive job, type `exit` to quit your session.

## Running parallel jobs using MPI

As we have already seen, the power of HPC systems comes from *parallelism*, i.e. having lots of
processors/disks etc. connected together rather than having more powerful components than your
laptop or workstation. Often, when running research programs on HPC you will need to run a
program that has been built to use the MPI (Message Passing Interface) parallel library. The MPI
library allows programs to exploit multiple processing cores in parallel to allow researchers
to model or simulate faster on larger problem sizes. The details of how MPI work are not important
for this course or even to use programs that have been built using MPI; however, MPI programs 
typically have to be launched in job submission scripts in a different way to serial programs and
users of parallel programs on HPC systems need to know how to do this. Specifically, launching
parallel MPI programs typically requires four things:

  - A special parallel launch program such as `mpirun`, `mpiexec`, `srun` or `aprun`.
  - A specification of how many processes to use in parallel. For example, our parallel program
    may use 256 processes in parallel.
  - A specification of how many parallel processes to use per compute node. For example, if our
    compute nodes each have 32 cores we often want to specify 32 parallel processes per node.
  - The command and arguments for our parallel program.


::: prereq

## Required Files

The program used in this example can be retrieved using wget or a browser and copied to the remote.

**Using wget**: 
```bash
userid@ln03:~> wget https://epcced.github.io/2023-06-28-uoe-hpcintro/files/pi-mpi.py
```

**Using a web browser**:

[https://epcced.github.io/2023-06-28-uoe-hpcintro/files/pi-mpi.py](https://epcced.github.io/2023-06-28-uoe-hpcintro/files/pi-mpi.py)

:::

To illustrate this process, we will use a simple MPI parallel program that estimates the value of Pi.
(We will meet this example program in more detail in a later episode.) Here is a job submission
script that runs the program across two compute nodes on the cluster. Create a file
(e.g. called: `run-pi-mpi.slurm`) with the contents of this script in it.


```bash
#!/bin/bash

#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --reservation=shortqos
#SBATCH --time=00:05:00

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16

module load cray-python

srun python pi-mpi.py 10000000
```

The parallel launch line for the sharpen program can be seen towards the bottom of the script:


```bash
srun python pi-mpi.py 10000000
```

And this corresponds to the four required items we described above:

  1. Parallel launch program: in this case the parallel launch program is
     called `srun`; the additional argument controls which cores are used.
  2. Number of parallel processes per node: in this case this is 16,
     and is specified by the option `--ntasks-per-node=16` option.
  2. Total number of parallel processes: in this case this is also 16, because
     we specified 1 node and 16 parallel processes per node.
  4. Our program and arguments: in this case this is `python pi-mpi.py 10000000`.

As for our other jobs, we launch using the `sbatch` command.

```bash
userid@uan01:/work/ta114/ta114/userid> sbatch run-pi-mpi.slurm
```

The program generates no output with all details printed to the job log.


::: challenge
## Running parallel jobs
Modify the pi-mpi-run script that you used above to use all 128 cores on
one node.  Check the output to confirm that it used the correct number
of cores in parallel for the calculation.

::: solution
Here is a modified script

```bash
#!/bin/bash

#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --reservation=shortqos
#SBATCH --time=00:00:30

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128

module load cray-python
srun python pi-mpi.py 10000000
```
:::
:::


::: challenge
## Configuring parallel jobs
You will see in the job output that information is displayed about
where each MPI process is running, in particular which node it is
on.

Modify the pi-mpi-run script that you run a total of 2 nodes and 16 processes;
but to use only 8 tasks on each of two nodes.
Check the output file to ensure that you understand the job
distribution.

::: solution
```bash
#!/bin/bash

#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --time=00:00:30

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8

module load cray-python
srun python pi-mpi.py 10000000
```
:::
:::

::: keypoints
 - "The scheduler handles how compute resources are shared between users."
 - "Everything you do should be run through the scheduler."
 - "A job is just a shell script."
 - "If in doubt, request more resources than you will need."
:::
