redmine
=======

Install and configure one or multiple redmine instances.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``redmine.managed``
-------------------

includes:

- ``redmine.svn_ca_cert``
- ``redmine.install``
- ``redmine.plugins``
- ``redmine.apache.config_snippets``

``redmine.install``
-------------------

Clones the repo, calls bundler and rake.
Is able to handle multiple instances.

``redmine.plugins``
-------------------

Clones the plugin repo, calls bundler and rake, sets up plugins.
Is able to handle multiple instances with multiple plugins.

``redmine.svn_ca_cert``
-----------------------

(Currently FreeBSD only. Include before ``redmine.install``!)

This is a bit hacky. Although ca_root_nss is installed,
subversion does not trust Redmine's SVN server.

By adding a cross-signed cert this is changed.

``redmine.apache.config_snippets``
----------------------------------

Requires ``apache-formula`` to be available.

Add this to your apache config:

``Include /etc/apache2/conf-available/redmine-${INSTANCE_NAME}.conf``

``redmine.apache.gitolite_config_snippets``
-------------------------------------------

Requires ``apache-formula`` to be available.

Add this to your apache config:

``Include /etc/apache2/conf-available/redmine-${INSTANCE_NAME}-gitolite.conf``


Running Tests
=============

This test runner was implemented using the formula-test-harness_ project.

Tests will be run on the following base images:

* ``simplyadrian/allsalt:centos_master_2017.7.2``
* ``simplyadrian/allsalt:debian_master_2017.7.2``
* ``simplyadrian/allsalt:opensuse_master_2017.7.2``
* ``simplyadrian/allsalt:ubuntu_master_2016.11.3``
* ``simplyadrian/allsalt:ubuntu_master_2017.7.2``

Local Setup
-----------

.. code-block:: shell

   pip install -U virtualenv
   virtualenv .venv
   source .venv/bin/activate
   make setup

Run tests
---------

* ``make test-centos_master_2017.7.2``
* ``make test-debian_master_2017.7.2``
* ``make test-opensuse_master_2017.7.2``
* ``make test-ubuntu_master_2016.11.3``
* ``make test-ubuntu_master_2017.7.2``

Run Containers
--------------

* ``make local-centos_master_2017.7.2``
* ``make local-debian_master_2017.7.2``
* ``make local-opensuse_master_2017.7.2``
* ``make local-ubuntu_master_2016.11.3``
* ``make local-ubuntu_master_2017.7.2``


.. _formula-test-harness: https://github.com/intuitivetechnologygroup/formula-test-harness
