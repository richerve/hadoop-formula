include:
  - hadoop.hdfs

{%- from 'hadoop/map.jinja' import map with context %}
{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
# TODO: no users implemented in settings yet
{%- set hadoop_users = hadoop.get('users', {}) %}
{%- set mapred = pillar.get('mapred', {}) %}

{% set mapred_disks = salt['pillar.get']('mapred_data_disks', ['/data']) %}
{% set username = 'mapred' %}
{% set uid = hadoop_users.get(username, '6002') %}
{{ hadoop_user(username, uid) }}

{% set jobtracker_host = salt['mine.get']('roles:hadoop_master', 'network.interfaces', 'grain').keys()|first() -%}
{% set jobtracker_port = salt['pillar.get']('mapred:config:jobtracker_port', '9001') %}

{% for disk in mapred_disks %}
{{ disk }}/mapred:
  file.directory:
    - user: mapred
    - group: root
    - makedirs: True
{% endfor %}

{{ hadoop['alt_config'] }}/mapred-site.xml:
  file.managed:
    - source: salt://hadoop/conf/mapred-site.xml
    - template: jinja
    - context:
      mapred_disks: {{ mapred_disks }}
      mapred: {{ mapred }}
      jobtracker_host: {{ jobtracker_host }}
      jobtracker_port: {{ jobtracker_port }}
      major: {{ hadoop['major_version'] }}

{%- if 'hadoop_master' in salt['grains.get']('roles', []) %}

make-tempdir:
  cmd.run:
    - user: hdfs
    - name: {{ hadoop['dfs_cmd'] }} -mkdir /tmp
    - unless: {{ hadoop['dfs_cmd'] }} -stat /tmp
    - require:
      - service: hdfs-services

set-tempdir:
  cmd.wait:
    - user: hdfs
    - watch:
      - cmd: make-tempdir
    - names:
      - {{ hadoop['dfs_cmd'] }} -chmod 777 /tmp
      # - {{ hadoop['dfs_cmd'] }} -chmod +t /tmp
{% endif %}

{%- if hadoop['major_version'] == '1' %}
{%- if 'hadoop_master' in salt['grains.get']('roles', []) %}

{{ map.jobtracker_service_script }}:
  file.managed:
    - source: {{ map.service_script_source }}
    - user: root
    - group: root
    - mode: {{ map.service_script_mode }}
    - template: jinja
    - context:
      hadoop_svc: jobtracker
      hadoop_home: hadoop_prefix

hadoop-jobtracker:
  service:
    - running
    - enable: True
{% endif %}

{%- if 'hadoop_slave' in salt['grains.get']('roles', []) %}

{{ map.tasktracker_service_script }}:
  file.managed:
    - source: {{ map.service_script_source }}
    - user: root
    - group: root
    - mode: {{ map.service_script_mode }}
    - template: jinja
    - context:
      hadoop_svc: tasktracker
      hadoop_home: hadoop_prefix

hadoop-tasktracker:
  service:
    - running
    - enable: True
{% endif %}

{% endif %}
