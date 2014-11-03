include: 
  - mongodb

/etc/mongod.conf:
  file.managed:
  - source: salt://mongodb/configserver/files/etc_mongod.conf.jinja
  - makedirs: True
  - template: jinja
  - user: root
  - group: root
  - mode: 644

/etc/default/mongod:
  file.managed:
  - source: salt://mongodb/configserver/files/default_mongod
  - makedirs: True
  - user: root
  - group: root
  - mode: 644

mongod:
  service:
  - running
  - enable: True
  - watch:
    - file: /etc/mongod.conf
    - file: /etc/default/mongod
  - require: 
    - pkg: mongodb-org
 
