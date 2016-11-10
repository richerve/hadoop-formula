{%- from 'hadoop/map.jinja' import hadoop with context %}

include:
  - hadoop.hdfs

hdfs_namenode_name_dir:
  file.directory:
    - name: {{ hadoop.config.hdfs['dfs.namenode.name.dir']|replace("file://", "") if hadoop.config.hdfs['dfs.namenode.name.dir'].startswith('file://') }}
    - user: {{ hadoop.user }}
    - group: {{ hadoop.group }}
    - makedirs: true
    - require_in:
      - file: hdfs_hdfs-site
          
hdfs_namenode_format:
  cmd.run:
    - name: {{ hadoop.home }}/bin/hdfs namenode -format
    - runas: {{ hadoop.user }}
    - creates: /tmp/hdfs/nn/current/VERSION
    - onchanges:
      - file: hdfs_namenode_name_dir

hdfs_namenode_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/hadoop-namenode.service
    - source: salt://hadoop/files/hadoop-namenode.systemd.jinja
{%- endif %}
    - template: jinja
    - defaults:
        java_profile: {{ hadoop.java_profile }}
        hadoop_env: {{ hadoop.home }}/etc/hadoop/hadoop-env.sh
        hadoop_user: {{ hadoop.user }}
        hadoop_group: {{ hadoop.group }}
    - require:
      - file: hadoop_hadoop-env

hdfs_namenode_service:
  service.running:
    - name: hadoop-namenode
    - enable: True
    - watch:
      - file: hdfs_namenode_service_unit
      - file: hdfs_hdfs-site
      - file: hadoop_hadoop-env
