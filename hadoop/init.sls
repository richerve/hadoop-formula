{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- set hadoop_users = hadoop.get('users', {}) %}

hadoop:
  group.present:
    - gid: {{ hadoop_users.get('hadoop', '6000') }}

{%- if grains['os_family'] == 'RedHat' %}
redhat-lsb:
  pkg.installed
{%- endif %}

create-common-folders:
  file.directory:
    - user: root
    - group: hadoop
    - mode: 775
    - names:
      - {{ hadoop.log_root }}
      - /var/run/hadoop
      - /var/lib/hadoop
    - require:
      - group: hadoop
    - makedirs: True

{%- if hadoop.log_root != hadoop.default_log_root %}
/var/log/hadoop:
  file.symlink:
    - target: {{ hadoop.log_root }}
{%- endif %}

vm.swappiness:
  sysctl:
    - present
    - value: 0

vm.overcommit_memory:
  sysctl:
    - present
    - value: 0

unpack-hadoop-dist:
{%- if hadoop.source_hash %}
  archive.extracted:
    - name: {{ hadoop['prefix'].rsplit("/", 1)[0] }}
    - source: {{ hadoop.source_url }}
    - source_hash: md5={{ hadoop.source_hash }}
    - if_missing: {{ hadoop.prefix }}
    - archive_format: tar
{%- else %}
  cmd.run:
    - name: curl '{{ hadoop.source_url }}' | tar xz --no-same-owner
    - cwd: /usr/lib
    - unless: test -d {{ hadoop['prefix'] }}/lib
{%- endif %}
    - require_in:
      - alternatives: hadoop-home-link
      - alternatives: hadoop-bin-link
      - alternatives: hdfs-bin-link
      - alternatives: mapred-bin-link
      - alternatives: yarn-bin-link

hadoop-bin-link:
  alternatives.install:
    - link: /usr/bin/hadoop
    - path: {{ hadoop.prefix }}/bin/hadoop
    - priority: 30

hdfs-bin-link:
  alternatives.install:
    - link: /usr/bin/hdfs
    - path: {{ hadoop.prefix }}/bin/hdfs
    - priority: 30

mapred-bin-link:
  alternatives.install:
    - link: /usr/bin/mapred
    - path: {{ hadoop.prefix }}/bin/mapred
    - priority: 30

yarn-bin-link:
  alternatives.install:
    - link: /usr/bin/yarn
    - path: {{ hadoop.prefix }}/bin/yarn
    - priority: 30

{%- if hadoop.cdhmr1 %}

{{ hadoop.alt_home }}/share/hadoop/mapreduce:
  file.symlink:
    - target: {{ hadoop.alt_home }}/share/hadoop/mapreduce1
    - force: True

rename-bin:
  cmd.run:
    - name: mv {{ hadoop.alt_home }}/bin {{ hadoop.alt_home }}/bin-mapreduce2
    - unless: test -L {{ hadoop.alt_home }}/bin

rename-config:
  cmd.run:
    - name: mv {{ hadoop.alt_home }}/etc/hadoop {{ hadoop.alt_home }}/etc/hadoop-mapreduce2
    - unless: test -L {{ hadoop.alt_home }}/etc/hadoop

{{ hadoop.alt_home }}/bin:
  file.symlink:
    - target: {{ hadoop.alt_home }}/bin-mapreduce1
    - force: True

{{ hadoop.alt_home }}/etc/hadoop:
  file.symlink:
    - target: {{ hadoop.alt_home }}/etc/hadoop-mapreduce1
    - force: True

{%- endif %}

/etc/profile.d/hadoop.sh:
  file.managed:
    - source: salt://hadoop/files/hadoop.sh.jinja
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      hadoop_home: {{ hadoop.prefix }}
      hadoop_config: {{ hadoop.config_dir }}

{{ hadoop.config_dir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755

{{ hadoop.config_dir }}/hadoop-env.sh:
  file.managed:
    - source: salt://hadoop/conf/hadoop-env.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      java_home: {{ hadoop.java_home }}
      hadoop_home: {{ hadoop.prefix }}
      hadoop_config: {{ hadoop.config_dir }}

{%- if grains.os == 'Ubuntu' %}
/etc/default/hadoop:
  file.managed:
    - source: salt://hadoop/files/hadoop.jinja
    - mode: '644'
    - template: jinja
    - user: root
    - group: root
    - context:
      java_home: {{ hadoop.java_home }}
      hadoop_home: {{ hadoop.prefix }}
      hadoop_config: {{ hadoop.config_dir }}
{%- endif %}
