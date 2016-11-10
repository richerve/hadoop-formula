{%- from 'hadoop/map.jinja' import hadoop with context %}

include:
  - hadoop.hdfs

hdfs_datanode_data_dir:
  file.directory:
    - name: {{ hadoop.config.hdfs['dfs.datanode.data.dir']|replace("file://", "") if hadoop.config.hdfs['dfs.namenode.name.dir'].startswith('file://') }}
    - user: {{ hadoop.user }}
    - group: {{ hadoop.group }}
    - makedirs: true
    - require_in:
      - file: hdfs_hdfs-site
          
hdfs_datanode_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/hadoop-datanode.service
    - source: salt://hadoop/files/hadoop-datanode.systemd.jinja
{%- endif %}
    - template: jinja
    - defaults:
        java_profile: {{ hadoop.java_profile }}
        hadoop_env: {{ hadoop.home }}/etc/hadoop/hadoop-env.sh
        hadoop_user: {{ hadoop.user }}
        hadoop_group: {{ hadoop.group }}
    - require:
      - file: hdfs_datanode_data_dir
      - file: hadoop_hadoop-env

hdfs_datanode_service:
  service.running:
    - name: hadoop-datanode
    - enable: True
    - watch:
      - file: hdfs_datanode_service_unit
      - file: hadoop_hadoop-env
      - file: hdfs_hdfs-site
