docker-ubuntu
===========

A base image for running just about anything within a container, based on Ubuntu 14.04 LTS (Trusty Tahr)


Process management
------------------

This image includes [supervisord](supervisord) process manager, to make it super simple to start processes and manage them correctly.
[supervisord]: http://supervisord.org


Usage
-----

To use this image include `FROM birkof/ubuntu` at the top of your `Dockerfile`. 


Examples
--------

An example of using this image can be found in the [birkof/nginx-php-fpm-symfony][docker-nps] [Dockerfile][docker-nps-dockerfile].

[docker-nps]: https://hub.docker.com/r/birkof/nginx-php-fpm-symfony/
[docker-nps-dockerfile]: https://github.com/birkof/docker-symfony-nginx-php-fpm/blob/master/Dockerfile