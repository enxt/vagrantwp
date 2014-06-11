#Vagrant + Wordpress
##Debian Wheezy64

This is a simple vagrant setup to get loaded with latest Wordpress for develop.

## Overview

We use 64-bit ISO so you may need to update your BIOS to enable virtualization with AMD-V or Intel VT.

## Packages Included

- Apache 2
- PHP 5.5
- MySQL 5.5
- Git
- Mercurial
- Composer (PHP)

## Requirements

- Operating System: Windows, Linux, or OSX.
- [Virtualbox](https://www.virtualbox.org) version 4.3.*
- [Vagrant](http://www.vagrantup.com) version 1.4.*

## Installation

First you need a [Git enabled terminal](#software-suggestions). Then you should **clone this repository** locally.

    $ git clone https://github.com/enxt/vagrantwp.git
    $ vagrant up
    $ vagrant ssh

    # To exit type:
    $ exit

If you want to change your bound address (`192.168.0.101`), edit `Vagrantfile`, change the ip and run:

    $ vagrant reload

If you want to point your Guest Machine (The Virtual Machine OS) to a friendly URL, you could modify your `etc/hosts` file and add the following:

    192.168.0.101  your-server-name

Your should change in the init.sh file, the siteurl variable to your-server-name

    wpemail=youremail@mail.com
    siteurl=your-server-name
    
## Vagrant Credentials

These are credentials setup by default:

- **Host Address**: 192.168.0.101 _(Change in Vagrantfile if you like)_
- **SSH**: vagrant / vagrant _(If root password fails, run `$ sudo passwd` and set one)_
- **MySQL**: root / (none)


## Local Editing

On your Host computer open any file explorer or IDE and navigate to `_this_vagrant_folder_/www/`. 

