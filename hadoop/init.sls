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
    - require:
      - group: hadoop
    - makedirs: True

hadoop_run_dir:
  file.directory:
    - name: /var/run/hadoop
    - user: {{hadoop.user}}
    - group: {{hadoop.group}}
    - mode: 775
    - require:
      - group: hadoop
    - makedirs: True

# hadoop_log_dir:
#   file.directory:
#     - mode: 775
#     - names:
#       - /var/run/hadoop
#       - /var/lib/hadoop
#     - require:
#       - group: hadoop
#     - makedirs: True

# vm.swappiness:
#   sysctl:
#     - present
#     - value: 0
#
# vm.overcommit_memory:
#   sysctl:
#     - present
#     - value: 0

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
      - symlink: hadoop_bin_link
      - symlink: hdfs_bin_link
      # - alternatives: mapred-bin-link
      # - alternatives: yarn-bin-link

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

# mapred-bin-link:
#   alternatives.install:
#     - name: mapred
#     - link: /usr/bin/mapred
#     - priority: 30
#
# yarn-bin-link:
#   alternatives.install:
#     - name: yarn
#     - link: /usr/bin/yarn
#     - priority: 30

hadoop_profile:
  file.managed:
    - name: /etc/profile.d/hadoop.sh
    - source: salt://hadoop/files/hadoop.sh.jinja
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - defaults:
        hadoop_home: {{ hadoop.home }}
        hadoop_config: {{ hadoop.home }}/etc/hadoop

hadoop_hadoop-env:
  file.managed:
    - name: {{ hadoop.home }}/etc/hadoop/hadoop-env.sh
    - source: salt://hadoop/files/hadoop-env.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - defaults:
        hadoop_home: {{ hadoop.home }}
        hadoop_config: {{ hadoop.home }}/etc/hadoop
        hadoop_log_dir: {{ hadoop.log_dir }}
