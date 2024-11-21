%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel

Name:          ruby-gnome2
Version:       3.5.1
Release:       alt1
Summary:       Ruby bindings for GNOME
License:       LGPL-2.1+
Group:         Development/Ruby
Url:           https://ruby-gnome2.osdn.jp/
Vcs:           https://github.com/ruby-gnome2/ruby-gnome2.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
BuildRequires: libgtk+2-devel
BuildRequires: libgtk+3-devel
BuildRequires: libpixman-devel
BuildRequires: libexpat-devel
BuildRequires: libharfbuzz-devel
BuildRequires: libdrm-devel
BuildRequires: libpcre-devel
BuildRequires: libXdmcp-devel
BuildRequires: libXdamage-devel
BuildRequires: libXxf86vm-devel
BuildRequires: libvte3-devel
BuildRequires: libvte-devel
BuildRequires: libvlc-devel
BuildRequires: libuuid-devel
BuildRequires: libgtksourceview-devel
BuildRequires: libfribidi-devel
BuildRequires: libtiff-devel
BuildRequires: libmount-devel
BuildRequires: libblkid-devel
BuildRequires: libat-spi2-core-devel
BuildRequires: libepoxy-devel
BuildRequires: libXinerama-devel
BuildRequires: libXi-devel
BuildRequires: libXrandr-devel
BuildRequires: libXcursor-devel
BuildRequires: libXcomposite-devel
BuildRequires: libpng-devel
BuildRequires: libxml2-devel
BuildRequires: libwayland-cursor-devel
BuildRequires: libwayland-egl-devel
BuildRequires: wayland-protocols
BuildRequires: libxkbcommon-devel
BuildRequires: gstreamer1.0-devel
BuildRequires: gobject-introspection-devel
BuildRequires: at-spi2-atk-devel
BuildRequires: libselinux-devel
BuildRequires: libXtst-devel
BuildRequires: libthai-devel
BuildRequires: libdatrie-devel
BuildRequires: bzlib-devel
BuildRequires: glib2-devel
BuildRequires: libgio-devel
BuildRequires: libpango-devel
BuildRequires: gst-plugins-devel
BuildRequires: gcc-c++
BuildRequires: libbrotli-devel
BuildRequires: gem(native-package-installer) >= 1.0.3
BuildRequires: gem(pkg-config) >= 1.3.5
BuildRequires: gem(rake) >= 0
%if_enabled check
BuildRequires: gem(cairo) >= 0
BuildRequires: gem(test-unit) >= 2
BuildRequires: gem(vte) = 3.5.1
BuildRequires: gem(webrick) >= 0
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_ignore_names rake,ruby-gnome2,gdk3-no-gi,(?-mix:-no-gi)
Requires:      gem(cairo) >= 0
Requires:      gem(vte) = 3.5.1
Requires:      gem(webrick) >= 0

%description
This is a set of bindings for the GNOME 2.x and 3.x libraries to use from Ruby
2.1, 2.2, 2.3 and 2.4.


%package       -n gem-vte3
Version:       3.5.1
Release:       alt1
Summary:       Ruby/VTE3 is a Ruby binding of VTE for use with GTK3
Group:         Development/Ruby

Requires:      gem(vte) = 3.5.1
Provides:      gem(vte3) = 3.5.1

%description   -n gem-vte3
Ruby/VTE3 is a Ruby binding of VTE for use with GTK3.


%if_enabled    doc
%package       -n gem-vte3-doc
Version:       3.5.1
Release:       alt1
Summary:       Ruby/VTE3 is a Ruby binding of VTE for use with GTK3 documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета vte3
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(vte3) = 3.5.1

%description   -n gem-vte3-doc
Ruby/VTE3 is a Ruby binding of VTE for use with GTK3 documentation files.

%description   -n gem-vte3-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета vte3.
%endif


%if_enabled    devel
%package       -n gem-vte3-devel
Version:       3.5.1
Release:       alt1
Summary:       Ruby/VTE3 is a Ruby binding of VTE for use with GTK3 development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета vte3
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(vte3) = 3.5.1

%description   -n gem-vte3-devel
Ruby/VTE3 is a Ruby binding of VTE for use with GTK3 development package.

%description   -n gem-vte3-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета vte3.
%endif


%package       -n gem-glib2
Version:       3.5.1
Release:       alt1
Summary:       GLib 2 bindings for the Ruby language
Group:         Development/Ruby

Requires:      gem(native-package-installer) >= 1.0.3
Requires:      gem(pkg-config) >= 1.3.5
Obsoletes:     ruby-glib2 < %EVR
Provides:      ruby-glib2 = %EVR
Provides:      gem(glib2) = 3.5.1

%description   -n gem-glib2
GLib is a useful general-purpose C library, notably used by GTK+ and GNOME. This
package contains libraries for using GLib 2 with the Ruby programming language.
It is most likely useful in conjunction with Ruby bindings for other libraries
such as GTK+.


%if_enabled    doc
%package       -n gem-glib2-doc
Version:       3.5.1
Release:       alt1
Summary:       GLib 2 bindings for the Ruby language documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета glib2
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(glib2) = 3.5.1
Obsoletes:     ruby-glib2-doc < %EVR
Provides:      ruby-glib2-doc = %EVR

%description   -n gem-glib2-doc
GLib 2 bindings for the Ruby language documentation files.

GLib is a useful general-purpose C library, notably used by GTK+ and GNOME. This
package contains libraries for using GLib 2 with the Ruby programming language.
It is most likely useful in conjunction with Ruby bindings for other libraries
such as GTK+.

%description   -n gem-glib2-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета glib2.
%endif


%if_enabled    devel
%package       -n gem-glib2-devel
Version:       3.5.1
Release:       alt1
Summary:       GLib 2 bindings for the Ruby language development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета glib2
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(glib2) = 3.5.1
Requires:      gem(test-unit) >= 2

%description   -n gem-glib2-devel
GLib 2 bindings for the Ruby language development package.

GLib is a useful general-purpose C library, notably used by GTK+ and GNOME. This
package contains libraries for using GLib 2 with the Ruby programming language.
It is most likely useful in conjunction with Ruby bindings for other libraries
such as GTK+.

%description   -n gem-glib2-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета glib2.
%endif


%if_enabled    devel
%package       -n ruby-gnome2-devel
Version:       3.5.1
Release:       alt1
Summary:       Ruby bindings for GNOME development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета ruby-gnome2
Group:         Development/Ruby
BuildArch:     noarch

Requires:      ruby-gnome2 = 3.5.1-alt1
Requires:      gem(cairo) >= 0
Requires:      gem(native-package-installer) >= 1.0.3
Requires:      gem(pkg-config) >= 1.3.5
Requires:      gem(rake) >= 0
Requires:      gem(test-unit) >= 2
Requires:      gem(vte) = 3.5.1
Requires:      gem(webrick) >= 0

%description   -n ruby-gnome2-devel
Ruby bindings for GNOME development package.

This is a set of bindings for the GNOME 2.x and 3.x libraries to use from Ruby
2.1, 2.2, 2.3 and 2.4.

%description   -n ruby-gnome2-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета ruby-gnome2.
%endif


%prep
%setup

%build
%ruby_build

%install
%ruby_install

%check
%ruby_test

%files

%files         -n gem-vte3
%doc COPYING.LIB README.md
%ruby_gemspecdir/vte3-3.5.1.gemspec
%ruby_gemslibdir/vte3-3.5.1
%ruby_gemsextdir/vte3-3.5.1

%if_enabled    doc
%files         -n gem-vte3-doc
%doc COPYING.LIB README.md
%ruby_gemsdocdir/vte3-3.5.1
%endif

%if_enabled    devel
%files         -n gem-vte3-devel
%doc COPYING.LIB README.md
%endif

%files         -n gem-glib2
%doc COPYING.LIB README.md
%ruby_gemspecdir/glib2-3.5.1.gemspec
%ruby_gemslibdir/glib2-3.5.1
%ruby_gemsextdir/glib2-3.5.1

%if_enabled    doc
%files         -n gem-glib2-doc
%doc COPYING.LIB README.md
%ruby_gemsdocdir/glib2-3.5.1
%endif

%if_enabled    devel
%files         -n gem-glib2-devel
%doc COPYING.LIB README.md
%ruby_includedir/*
%endif

%if_enabled    devel
%files         -n ruby-gnome2-devel
%endif


%changelog
* Wed Mar 09 2022 Pavel Skrylev <majioa@altlinux.org> 3.5.1-alt1
- ^ 3.4.3 -> 3.5.1

* Thu Jul 01 2021 Pavel Skrylev <majioa@altlinux.org> 3.4.3-alt1.1
- ! spec with settigns proper aliases

* Tue Jun 30 2020 Pavel Skrylev <majioa@altlinux.org> 3.4.3-alt1
- ^ 3.4.1 -> 3.4.3
- + a few package task build depended gem

* Thu Jun 04 2020 Pavel Skrylev <majioa@altlinux.org> 3.4.1-alt1.4
- Fix

* Mon May 25 2020 Andrey Cherepanov <cas@altlinux.org> 3.4.1-alt1.3
- Fix build by adding libbrotli-devel.

* Sat May 09 2020 Andrey Cherepanov <cas@altlinux.org> 3.4.1-alt1.2
- Do not require deprecated libwlc0-devel for wayland-protocols.pc.

* Thu Apr 02 2020 Pavel Skrylev <majioa@altlinux.org> 3.4.1-alt1.1
- ! build required package names

* Wed Mar 04 2020 Pavel Skrylev <majioa@altlinux.org> 3.4.1-alt1
- updated (^) 3.3.8 -> 3.4.1

* Wed Sep 11 2019 Pavel Skrylev <majioa@altlinux.org> 3.3.8-alt1
- updated (^) 3.3.7 -> 3.3.8
- fixed (!) spec according to changelog rules

* Tue Aug 20 2019 Pavel Skrylev <majioa@altlinux.org> 3.3.7-alt1
- updated (^) 3.3.6 -> 3.3.7
- added (+) libthai-devel, and libdatrie-devel build reqs
- added (+) wnck3, and libsecret gems

* Wed Jul 10 2019 Pavel Skrylev <majioa@altlinux.org> 3.3.6-alt2
- ignore ruby-gnome2 gemfile

* Wed Apr 03 2019 Pavel Skrylev <majioa@altlinux.org> 3.3.6-alt1
- Bump to 3.3.6

* Tue Mar 19 2019 Pavel Skrylev <majioa@altlinux.org> 3.3.2-alt2
- Fix build for new gnome

* Tue Feb 05 2019 Pavel Skrylev <majioa@altlinux.org> 3.3.2-alt1
- Bump to 3.3.2 gem;
- Use Ruby Policy 2.0;
- All the subpackages now included.

* Sun Jan 20 2019 Pavel Skrylev <majioa@altlinux.org> 3.3.1-alt1
- Bump to 3.3.1 gem.

* Fri Oct 05 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.9-alt2
- Fix build (add libpcre-devel).

* Mon Sep 17 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.9-alt1
- New version.

* Wed Jul 11 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.7-alt1.1
- Rebuild with new Ruby autorequirements.

* Thu Jun 07 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.7-alt1
- New version.

* Wed Jun 06 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.6-alt1
- New version.

* Wed May 02 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.5-alt1
- New version.

* Mon Apr 09 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.4-alt1
- New version.

* Tue Apr 03 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.3-alt2
- Build with libvte3.

* Tue Apr 03 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.3-alt1
- New version.

* Mon Apr 02 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.2-alt1
- New version.

* Sat Mar 31 2018 Andrey Cherepanov <cas@altlinux.org> 3.2.1-alt1
- New version.
- Build with gstreamer1.0-devel.

* Fri Mar 30 2018 Andrey Cherepanov <cas@altlinux.org> 3.1.1-alt1.4
- Rebuild with Ruby 2.5.1

* Tue Mar 13 2018 Andrey Cherepanov <cas@altlinux.org> 3.1.1-alt1.3
- Rebuild with Ruby 2.5.0

* Mon Sep 25 2017 Andrey Cherepanov <cas@altlinux.org> 3.1.1-alt1.2
- Rebuild with Ruby 2.4.2

* Tue Sep 05 2017 Andrey Cherepanov <cas@altlinux.org> 3.1.1-alt1.1
- Rebuild with Ruby 2.4.1

* Fri Apr 21 2017 Andrey Cherepanov <cas@altlinux.org> 3.1.1-alt1
- Initial build in Sisyphus
