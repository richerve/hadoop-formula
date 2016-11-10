{%- from 'hadoop/map.jinja' import hadoop with context %}

hadoop_user:
  user.present:
    - name: {{hadoop.user}}
    - system: true

hadoop_group:
  group.present:
    - name: {{hadoop.group}}
    - system: true

hadoop_log_dir:
  file.directory:
    - name: {{hadoop.log_dir}}
    - user: {{hadoop.user}}
    - group: {{hadoop.group}}
    - mode: 775
    - makedirs: True
    - require:
      - group: hadoop

hadoop_run_dir:
  file.directory:
    - name: {{hadoop.pid_dir}}
    - user: {{hadoop.user}}
    - group: {{hadoop.group}}
    - mode: 775
    - makedirs: True
    - require:
      - group: hadoop

hadoop_tarball:
  archive.extracted:
    - name: {{ hadoop.install_dir }}
    - source: {{ hadoop.source }}
    - source_hash: {{ hadoop.source_hash }}
    - if_missing: {{ hadoop.home }}
    - archive_format: tar
    - user: {{hadoop.user}}
    - group: {{hadoop.group}}
    - require_in:
      - symlink: hadoop_etc_link
      - symlink: hadoop_bin_link
      - symlink: hdfs_bin_link
      - symlink: hadoop_profile_link

hadoop_etc_link:
  file.symlink:
    - name: /etc/hadoop
    - target: {{ hadoop.home }}/etc/hadoop

hadoop_bin_link:
  file.symlink:
    - name: /usr/bin/hadoop
    - target: {{ hadoop.home }}/bin/hadoop

hdfs_bin_link:
  file.symlink:
    - name: /usr/bin/hdfs
    - target: {{ hadoop.home }}/bin/hdfs

hadoop_hadoop-env:
  file.managed:
    - name: {{ hadoop.home }}/etc/hadoop/hadoop-env.sh
    - source: salt://hadoop/files/hadoop-env.sh.jinja
    - template: jinja
    - defaults:
        hadoop_java_profile: {{ hadoop.java_profile }}
        hadoop_home: {{ hadoop.home }}
        hadoop_log_dir: {{ hadoop.log_dir }}
        hadoop_pid_dir: {{ hadoop.pid_dir }}
        hadoop_user: {{ hadoop.user }}
    - require:
      - archive: hadoop_tarball

hadoop_profile_link:
  file.symlink:
    - name: /etc/profile.d/hadoop.sh
    - target: {{ hadoop.home }}/etc/hadoop/hadoop-env.sh

hadoop_core-site:
  file.managed:
    - name: {{ hadoop.home }}/etc/hadoop/core-site.xml
    - source: salt://hadoop/files/configuration.xml.jinja
    - template: jinja
    - defaults:
        hadoop_config: {{ hadoop.config.core }}
    - require:
      - archive: hadoop_tarball
