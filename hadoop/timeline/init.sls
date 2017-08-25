{%- from "hadoop/settings.sls" import hadoop with context %}
{%- from "hadoop/yarn/settings.sls" import yarn with context %}
{%- from "hadoop/mapred/settings.sls" import mapred with context %}
{%- from "hadoop/user_macro.sls" import hadoop_user with context %}
{%- from 'hadoop/hdfs_mkdir_macro.sls' import hdfs_mkdir with context %}

{%- if hadoop.major_version|string() == '2' %}
  {%- set username = 'yarn' %}
  {%- set yarn_home_directory = '/user/' + username %}
  {%- set uid = hadoop.users[username] %}
{{ hadoop_user(username, uid) }}

  {% if yarn.is_resourcemanager %}

  {#- add mr-history directories for Hadoop 2 #}
  {%- set yarn_site = yarn.config_yarn_site %}
  {%- set rald = yarn_site.get('yarn.nodemanager.remote-app-log-dir', '/app-logs') %}

{{ hdfs_mkdir(mapred.history_dir, username, username, 755, hadoop.dfs_cmd) }}
{{ hdfs_mkdir(mapred.history_intermediate_done_dir, username, username, 1777, hadoop.dfs_cmd) }}
{{ hdfs_mkdir(mapred.history_done_dir, username, username, 1777, hadoop.dfs_cmd) }}
{{ hdfs_mkdir(yarn_home_directory, username, username, 700, hadoop.dfs_cmd) }}
{{ hdfs_mkdir(rald, username, 'hadoop', 1777, hadoop.dfs_cmd) }}

/etc/init.d/hadoop-historyserver:
  file.managed:
    - source: salt://hadoop/files/{{ hadoop.initscript }}
    - user: root
    - group: root
    - mode: '755'
    - template: jinja
    - context:
      hadoop_svc: historyserver
      hadoop_user: hdfs
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}

hadoop-historyserver:
  service.running:
    - enable: True
  {%- endif %}
{%- endif %}
