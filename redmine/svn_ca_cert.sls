{% if grains['os_family'] == 'FreeBSD' %}
redmine_add_cross_signed_cert_nss:
  file.append:
    - name: /usr/local/share/certs/ca-root-nss.crt
    # https://wiki.gandi.net/en/ssl/intermediate
    # https://charlieharvey.org.uk/page/gandi_sha2_intermediate_cert_ssl_tls
    - source: salt://redmine/files/GandiStandardSSLCA2.pem

redmine_cross_signed_cert_openssl:
  file.managed:
    - name: /usr/local/openssl/certs/8544bf03.0
    - makedirs: True
    # https://wiki.gandi.net/en/ssl/intermediate
    # https://charlieharvey.org.uk/page/gandi_sha2_intermediate_cert_ssl_tls
    - source: salt://redmine/files/GandiStandardSSLCA2.pem
{% endif %}
