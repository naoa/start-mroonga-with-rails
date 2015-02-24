# -*- coding: utf-8 -*-
#
# Cookbook Name:: mroonga
# Recipe:: default
#
# Copyright (C) 2014, Jun Nishikawa <topaz2@m0n0m0n0.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

case node[:platform]
when 'debian'
  apt_repository "mroonga-#{node[:lsb][:codename]}" do
    uri 'http://packages.groonga.org/debian/'
    components ["#{node[:lsb][:codename]} main"]
    not_if { ::File.exist?("/etc/apt/sources.list.d/mroonga-#{node[:lsb][:codename]}.list") }
  end
  package 'groonga-keyring' do
    options '--allow-unauthenticated'
  end
  %w( mysql-server-mroonga groonga-tokenizer-mecab ).each do |p|
    package p do
      options '--force-yes'
    end
  end
when 'ubuntu'
  %w( software-properties-common lsb-release ).each do |p|
    package p
  end
  apt_repository "mroonga-#{node[:lsb][:codename]}" do
    uri 'http://security.ubuntu.com/ubuntu'
    components ["#{node[:lsb][:codename]}-security main restricted"]
    not_if { ::File.exist?("/etc/apt/sources.list.d/mroonga-#{node[:lsb][:codename]}.list") }
  end
  apt_repository 'groonga' do
    uri 'ppa:groonga/ppa'
    distribution node[:lsb][:codename]
  end
  %w( mysql-server-mroonga groonga-tokenizer-mecab ).each do |p|
    package p
  end
end
