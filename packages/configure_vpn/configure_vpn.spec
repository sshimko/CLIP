Name:	%{pkgname}
Version: %{version}
Release: %{release}
Summary: CLIP vpn configuration utilities.
Requires: kernel
Requires: libreswan
Requires: nss-tools

License: GPL or BSD
Group: System Environment/Base

BuildRequires: make, bash
BuildRoot: %{_tmppath}/%{name}-root

Source0: %{pkgname}-%{version}.tgz

%description
This package contains utilities for configuring CLIP vpn

%prep
%setup -q -n %{pkgname}

%build
make

%install
rm -rf $RPM_BUILD_ROOT
make DESTDIR=%{buildroot} install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(6755,root,root,-)
/usr/bin/add_vpn_user
%defattr(755,root,root,-)
/etc/init.d/configure-vpn
/etc/systemd/system/configure-vpn.service
/usr/bin/add_vpn_user.sh
/usr/bin/gen_word.sh
/usr/bin/gen_word.py
/usr/bin/vpn_login.py
/usr/bin/vpn_funcs.sh

%post

%changelog
* Thu Jul 28 2016 Quentin Swain <quentin@quarksecurity.com> 1-2
- Update package to support libreswan
* Tue Apr 21 2014 Pat McClory <pat@quarksecurity.com> 1-1
- Configure strongswan Spec file
