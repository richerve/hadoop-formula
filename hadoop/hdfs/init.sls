{%- from 'hadoop/map.jinja' import hadoop with context %}

include:
  - hadoop

hdfs_hdfs-site:
  file.managed:
    - name: {{ hadoop.home }}/etc/hadoop/hdfs-site.xml
    - source: salt://hadoop/files/configuration.xml.jinja
    - template: jinja
    - defaults:
        hadoop_config: {{ hadoop.config.hdfs }}
    - require:
      - archive: hadoop_tarball
