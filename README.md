# ebinnion dotfiles :)

Over the past few years, I've built up a list of aliases, scripts, and config files that are a bit scattered. This repository is an effort to bring some organization to my development environment.

This repository is intended for use by me, so you may not find it too helpful. :)

If you're interested in dotfiles, have a look at [https://dotfiles.github.io/](https://dotfiles.github.io/).

Currently, this repository only contains scripts for creating and tearing down WordPress sites using Laravel Valet. These scripts assume:

- PHP is installed `brew install homebrew/php/php72`
- MySQL is installed and active `brew install mysql`.
    - The script also currently assumes that the MySQL username is `root` and the password is `pass`.
- Laravel Valet has been installed. See instructions here: [https://laravel.com/docs/5.6/valet#installation](https://laravel.com/docs/5.6/valet#installation)
