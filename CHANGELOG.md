#### 2019-03-19 - 1.0.2
* Add support for `$usr` and `$pwd` in template.

#### 2018-02-02 - 1.0.1
* Add `$auto_restart` parameter for systemd based restart on-failure.

#### 2016-02-08 - 1.0.0
* Remove obsolete (and now unused by me) Gentoo support.
* Remove separate package class which existed only for special Gentoo support.
* Fix RHEL7+ systemd service by using rhel::systemd::service.

#### 2015-12-16 - 0.2.4
* Include systemd unit file (#1, @jesusrodrigo).

#### 2015-12-01 - 0.2.3
* Fix logrotate entry by using copytruncate, moxi does not reopen its log file.
* Use metadata.json instead of Modulefile.

#### 2014-05-19 - 0.2.2
* Require package before modifying the init script.

#### 2014-03-31 - 0.2.1
* Fix circular dependency created by /opt/moxi permissions fix.

#### 2014-03-31 - 0.2.0
* Add Gentoo support, by downloading and unpacking an rpm file.
* Split package (and Gentoo exec) into package.pp.

#### 2013-11-05 - 0.1.2
* Add cron_restart, useful to enable when noticing memory leaks.
* Add syntax highlighting to README.

#### 2013-04-19 - 0.1.1
* Use @varname syntax in templates to silence puppet 3.2 warnings.

#### 2013-04-15 - 0.1.0
* Update README and use markdown.
* Switch to 2-space indent.

#### 2012-09-19 - 0.0.2
* Add SELinux support when using unix sockets.

#### 2012-06-07 - 0.0.1
* Initial module.

