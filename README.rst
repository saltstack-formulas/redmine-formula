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

``redmine.install``
-------------------

Clones the repo, calls bundler and rake, sets up plugins.
Is able to handle multiple instances.

``redmine.svn_ca_cert``
-----------------------

(Currently FreeBSD only.)

This is a bit hacky. Although ca_root_nss is installed,
subversion does not trust Redmine's SVN server.

By adding a cross-signed cert this is changed.
