======
hadoop
======

Formula to set up and configure hadoop components

Features
========

- Download, install and configure core hadoop components. Using the official Apache Foundation distribution
  - HDFS
- Setup an HDFS namenode
- Setup an HDFS datanode

Formula Dependencies
====================

- Java formula (recommended)

This formula needs java installed and the JAVA_HOME variable defined in a file, the file where is defined is */etc/profile.d/java.sh* by default but can be changed with the *hadoop:java_profile* pillar entry.

For testing purposes and to use it on test-kitchen, I've included a java-formula in the deps folder. It is a submodule cloned from github.com/Heystaks/java-formula

In practice is possible to use that same java formula to deploy it before the hadoop-formula or you can use any other method that you want and specify the *hadoop:java_profile* parameter

Default values
==============

.. include:: hadoop/defaults.yaml
   :code: yaml

.. note:: All the values can be overriden in pillar using the same structure

Available states
================

.. contents::
    :local:

``hadoop``
----------

- Downloads the hadoop tarball from *hadoop:source* and installed it in *install_dir* with the *version* added
- Installs the package, creates the *hadoop:user* and *hadoop:group* for all other components to share.
- Symlink common files like configuration to etc, environment to /etc/profile.d and binaries to /usr/bin
- Configure core-site.xml according to the options in *hadoop:config:core*

Parameters (can be overriden in pillar)::
   
   hadoop:
     user: hadoop
     group: hadoop
     version: hadoop-2.7.3
     source: 'http://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz'
     source_hash: sha1=b84b898934269c68753e4e036d21395e5a4ab5b1
     install_dir: /opt
     log_dir: /var/log/hadoop
     pid_dir: /var/run/hadoop
     java_profile: /etc/profile.d/java.sh
     config:
       core:
         fs.defaultFS: "hdfs://localhost"

``hadoop.hdfs.namenode``
------------------------

Setup an HDFS namenode instance

It includes `hadoop`_ to install the distribution if not present

Pillar parameters::
   
   hadoop:
     config:
       hdfs:
         dfs.namenode.name.dir: "file:///tmp/hdfs/nn"
         dfs.namenode.datanode.registration.ip-hostname-check: "false"
         dfs.replication: "1"
         dfs.namenode.http-address: "192.168.33.135:50070"
         dfs.namenode.secondary.http-address: "192.168.33.135:50090"

``hadoop.hdfs.datanode``
------------------------

Setup an HDFS datanode instance

It includes hadoop to install the distribution if not present

Pillar parameters::
   
   hadoop:
     config:
       hdfs:
         dfs.datanode.data.dir: "file:///tmp/hdfs/dn"
         dfs.replication: "1"
         dfs.namenode.http-address: "192.168.33.135:50070"
         dfs.namenode.secondary.http-address: "192.168.33.135:50090"

Configuration
=============

The hadoop formula exposes the general (cluster-independent) part of the main configuration files (core-site.xml, hdfs-site.sml) as pillar keys.

Example::

    hadoop:
      config:
       hdfs:
         dfs.datanode.data.dir: "file:///tmp/hdfs/dn"
         dfs.replication: "1"

Where the *hdfs* part will appear in core-site.xml as::

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///tmp/hdfs/dn</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>


Saltstack formulas
==================

See the full `Salt Formulas installation and usage instructions <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.
