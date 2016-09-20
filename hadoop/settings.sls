{% set p  = salt['pillar.get']('hadoop', {}) %}
{% set pc = p.get('config', {}) %}
{% set g  = salt['grains.get']('hadoop', {}) %}
{% set gc = g.get('config', {}) %}

{% macro set_dist_info(name="apache", versions=[]) -%}
    {% for version in versions -%}
        {{name}} + '-' + {{version}} : { 'version': {{version}},
                        'version_name' : 'hadoop-' + {{version}},
                        'source_url'    : g.get('source_url', p.get('source_url', 'http://archive.apache.org/dist/hadoop/core/hadoop-' + {{version}} + 'hadoop-' + {{version}} + '.tar.gz')),
                        'source_hash'   : g.get('source_hash', p.get('source_hash', '')),
                        'major_version' : {{version.split('.')[0]}}
                      },
    {%- endfor %}
{%- endmacro %}

{%- set versions = {} %}
{%- set default_dist_id = 'apache-2.2.0' %}
{%- set dist_id = g.get('version', p.get('version', default_dist_id)) %}

{%- set default_versions = { {{ set_dist_info("apache", versions=["2.2.0", "2.3.0"]) }}
                   }%}

{%- set versions         = p.get('versions', default_versions) %}
{%- set version_info     = versions.get(dist_id, versions['apache-2.7.1']) %}
{%- set alt_home         = salt['pillar.get']('hadoop:prefix', '/usr/lib/hadoop') %}
{%- set real_home        = '/usr/lib/' + version_info['version_name'] %}
{%- set alt_config       = gc.get('directory', pc.get('directory', '/etc/hadoop/conf')) %}
{%- set real_config      = alt_config + '-' + version_info['version'] %}
{%- set real_config_dist = alt_config + '.dist' %}
{%- set default_log_root = '/var/log/hadoop' %}
{%- set log_root         = gc.get('log_root', pc.get('log_root', default_log_root)) %}
{%- set initscript       = 'hadoop.init' %}
{%- set targeting_method = g.get('targeting_method', p.get('targeting_method', 'grain')) %}

{%- if version_info['major_version'] == '1' %}
{%- set dfs_cmd = alt_home + '/bin/hadoop dfs' %}
{%- set dfsadmin_cmd = alt_home + '/bin/hadoop dfsadmin' %}
{%- else %}
{%- set dfs_cmd = alt_home + '/bin/hdfs dfs' %}
{%- set dfsadmin_cmd = alt_home + '/bin/hdfs dfsadmin' %}
{%- endif %}

{%- set java_home        = salt['grains.get']('java_home', salt['pillar.get']('java_home', '/usr/lib/java')) %}
{%- set config_core_site = gc.get('core-site', pc.get('core-site', {})) %}

{%- set hadoop = {} %}
{%- do hadoop.update( {   'dist_id'          : dist_id,
                          'cdhmr1'           : version_info.get('cdhmr1', False),
                          'version'          : version_info['version'],
                          'version_name'     : version_info['version_name'],
                          'source_url'       : version_info['source_url'],
                          'source_hash'      : version_info['source_hash'],
                          'major_version'    : version_info['major_version']|string(),
                          'alt_home'         : alt_home,
                          'real_home'        : real_home,
                          'alt_config'       : alt_config,
                          'real_config'      : real_config,
                          'real_config_dist' : real_config_dist,
                          'initscript'       : initscript,
                          'dfs_cmd'          : dfs_cmd,
                          'dfsadmin_cmd'     : dfsadmin_cmd,
                          'java_home'        : java_home,
                          'log_root'         : log_root,
                          'default_log_root' : default_log_root,
                          'config_core_site' : config_core_site,
                          'targeting_method': targeting_method,
                      }) %}
