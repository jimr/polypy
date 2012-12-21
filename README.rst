======
Polypy
======

Bootstrap Python 2.5-3.3 environments, complete with ``pip`` & ``distribute`` based virtualenvs.

Handy for setting up fresh Python installs for testing with tox_.

.. _tox: http://testrun.org/tox/latest/

Tested on Ubuntu 12.04. You'll need to install some system packages first, most of which ought to be covered by::

    sudo apt-get build-dep python2.7

Usage
=====

Just run ``setup.sh`` with the version of Python you want to setup.
If it can't find the sources locally under ``src``, it will download them first.
It will appear in the current folder as ``py-X.Y`` and it'll build a new virtualenv under ``venv/X.Y``::

    % ./setup.py 3.3

