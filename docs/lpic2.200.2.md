## Predict Future Resource Needs (200.2) 

Candidates should be able to monitor resource usage to predict future
resource needs.

Key Knowledge Areas:

-   Use monitoring and measurement tools to monitor IT infrastructure
    usage

-   Predict capacity break point of a configuration

-   Observe growth rate of capacity usage

-   Graph the trend of capacity usage.

-   Awareness of monitoring solutions such as
    [Icanga2](https://www.icinga.org/products/icinga-2/),
    [Nagios](http://www.nagios.org),
    [collectd](http://www.collectd.org),
    [MRTG](http://oss.oetiker.ch/mrtg/) and
    [Cacti](http://www.cacti.net).

The following is a partial list of used files, terms and utilities:

-   diagnose

-   predict growth

-   resource exhaustion

##  Diagnose resource usage

Using the tools and knowledge presented in the previous two chapters, it
should be possible to diagnose the usage of resources for specific
components or processes. One of the tools mentioned was [`sar`](#sar),
which is capable of recording measurements over a longer period of time.
Being able to use the recorded data for trend analysis is one of the
advantages of using a tool that is able to log measurements.

##  Monitor IT infrastructure

One of the tools that can be used to monitor an IT infrastructure is
*collectd*. collectd is a daemon which collects system performance
statistics periodically and provides mechanisms to store the values in a
variety of ways. It gathers statistics about the system it is running on
and stores this information. Those statistics can then be used to find
current performance bottlenecks (i.e. performance analysis) and predict
future system load (i.e. capacity planning). collectd is written in C
for performance and portability, allowing it to run on systems without
scripting language or cron daemon, such as embedded systems. Note that
collectd only collects data, to display the collected data addtional
tools are required.

Also other monitoring tools like
[Icinga2](https://www.icinga.com/products/infrastructure_monitoring/),
[Nagios](http://www.nagios.org), [MRTG](http://oss.oetiker.ch/mrtg/) and
[Cacti](http://www.cacti.net) can be used to measure, collect and
display resource performance statistics. Using a montoring tool can help
you identify possible bottlenecks related to the measured resources but
can also help you predict future growth.

##  Predict future growth

By analyzing and observing the data from measurements, over time it
should be possible to predict the *statistical* growth of resource
needs. We deliberately say statistical growth here, because there are
many circumstances which can influence resource needs. The demand for
fax machines and phone lines has suffered from the introduction of
e-mail, for instance. But numerical or statistical based growth
estimations also suffer from the lack of linearity: When expanding due
to increased demand the expansion often incorporates a variety of
services. The demand for these services usually doesn't grow at the
same speed for all provided services. This means that measurement data
should not just be analysed, but also evaluated regarding to judge its
relevance.

The steps to predict future needs can be done as follows:

-   Decide what to measure.

-   Use the appropriate tools to measure and record relevant data to
    meat your goals.

-   Analyze the measurement results, starting with the biggest
    fluctuations.

-   Predict future needs based on the analysis.

##  Resource Exhaustion

When a resource cannot deliver to the request in an orderly fashion
anymore, it is exhausted. The demand and delivery are not aligned
anymore, and the availability of resources will become a problem.
Resource Exhaustion can lead to a denial-of-service. Apart from
disrupting the availability of a resource, devices which are configured
to "fail open" can be tricked by exhausting it's resources. Some
switches fall back to forwarding all traffic to all ports when the ARP
table becomes flooded, as an example.

Most of the time, a single resource which gets exhausted will be
extractable from collected measurement data. This is what we call a
*bottleneck*: a single point within the system narrows throughput and
slows down everything below. It is important to have a clear
understanding of the bigger picture here. Simply resolving a specific
bottleneck will only shift the problem, if you increase the capacity of
one component another component will become the limiting factor as soon
as it hits it's capacity limit.

Therefore it is important to identify as many bottlenecks as possible
right away during analysis.
