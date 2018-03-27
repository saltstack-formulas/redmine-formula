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
