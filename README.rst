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
