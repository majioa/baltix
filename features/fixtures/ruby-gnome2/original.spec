Name: 	       ruby-gnome2
Version:       3.4.3
Release:       alt1.1
Summary:       Ruby bindings for GNOME
License:       MIT
Group:         Development/Ruby
Url:           https://ruby-gnome2.osdn.jp/
Vcs:           https://github.com/ruby-gnome2/ruby-gnome2.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>

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
BuildRequires: gem-cairo-devel
BuildRequires: libbrotli-devel

BuildRequires: gem(pkg-config)
BuildRequires: gem(native-package-installer)
#BuildRequires: gem(mechanize)
BuildRequires: gem-cairo
BuildRequires: gem-rake

Requires:      gem(atk)
Requires:      gem(atk-no-gi)
Requires:      gem(cairo-gobject)
Requires:      gem(clutter)
Requires:      gem(clutter-gdk)
Requires:      gem(clutter-gstreamer)
Requires:      gem(clutter-gtk)
Requires:      gem(gdk3)
Requires:      gem(gdk4)
Requires:      gem(gdk_pixbuf2)
Requires:      gem(gdk_pixbuf2-no-gi)
Requires:      gem(gegl)
Requires:      gem(gio2)
Requires:      gem(glib2)
Requires:      gem(gnumeric)
Requires:      gem(gobject-introspection)
Requires:      gem(goffice)
Requires:      gem(gsf)
Requires:      gem(gstreamer)
Requires:      gem(gtk2)
Requires:      gem(gtk3)
Requires:      gem(gtk3-no-gi)
Requires:      gem(gtk4)
Requires:      gem(gtksourceview2)
Requires:      gem(gtksourceview3)
Requires:      gem(gtksourceview3-no-gi)
Requires:      gem(gtksourceview4)
Requires:      gem(gvlc)
Requires:      gem(pango)
Requires:      gem(pango-no-gi)
Requires:      gem(poppler)
Requires:      gem(poppler-no-gi)
Requires:      gem(rsvg2)
Requires:      gem(rsvg2-no-gi)
Requires:      gem(vte)
Requires:      gem(vte3)
Requires:      gem(vte3-no-gi)
Requires:      gem(webkit-gtk)
Requires:      gem(webkit-gtk2)
Requires:      gem(webkit2-gtk)
%ruby_alias_names gdk_pixbuf2,gdk-pixbuf2
%ruby_alias_names gdk_pixbuf2-no-gi,gdk-pixbuf2-no-gi

%description
This is a set of bindings for the GNOME 2.x and 3.x libraries to use
from Ruby 2.1, 2.2, 2.3 and 2.4.


%package       -n gem-glib2
Summary:       GLib 2 bindings for the Ruby language
Group:         Development/Ruby

Provides:      ruby-glib2
Obsoletes:     ruby-glib2

%description   -n gem-glib2
GLib is a useful general-purpose C library, notably used by GTK+ and
GNOME. This package contains libraries for using GLib 2 with the Ruby
programming language. It is most likely useful in conjunction with Ruby
bindings for other libraries such as GTK+.


%package       -n gem-glib2-devel
Summary:       Development files for GLib 2 bindings for the Ruby language
Group:         Development/Ruby
BuildArch:     noarch

Provides:      ruby-gnome2-devel
Obsoletes:     ruby-gnome2-devel

%description   -n gem-glib2-devel
This packages contains header files for gem-glib2 gem package.


%package       -n gem-glib2-doc
Summary:       Documentation files for %name
Group:         Documentation
BuildArch:     noarch

Provides:      ruby-glib2-doc
Obsoletes:     ruby-glib2-doc

%description   -n gem-glib2-doc
Documentation files for %{name}.


%package       -n gem-vte
Summary:       Ruby/VTE is a Ruby binding of VTE
Group:         Development/Ruby

%description   -n gem-vte
%summary.


%package       -n gem-vte-devel
Summary:       Headers for %name
Group:         Development/Ruby
BuildArch:     noarch

%description   -n gem-vte-devel
%summary.


%package       -n gem-vte-doc
Summary:       Documentation files for %name
Group:         Documentation
BuildArch:     noarch

%description   -n gem-vte-doc
Documentation files for %{name}.


%package       -n gem-vte3
Summary:       Ruby/VTE3 is a Ruby binding of VTE for use with GTK3
Group:         Development/Ruby
BuildArch:     noarch

%description   -n gem-vte3
%summary.


%package       -n gem-vte3-devel
Summary:       Headers for %name
Group:         Development/Ruby
BuildArch:     noarch

%description   -n gem-vte3-devel
%summary.


%package       -n gem-vte3-doc
Summary:       Documentation files for %name
Group:         Documentation
BuildArch:     noarch

%description   -n gem-vte3-doc
Documentation files for %{name}.


%package       -n gem-vte3-no-gi
Summary:       Ruby/VTE3 is a Ruby binding of VTE for use with GTK3 with no Graphic Interface
Group:         Development/Ruby
BuildArch:     noarch

%description   -n gem-vte3-no-gi
%summary.


%package       -n gem-vte3-no-gi-doc
Summary:       Documentation files for %name
Group:         Documentation
BuildArch:     noarch

%description   -n gem-vte3-no-gi-doc
Documentation files for %{name}.


%prep
%setup

%build
%ruby_build --ignore=ruby-gnome2,gdk3-no-gi,/-no-gi

%install
%ruby_install

%check
%ruby_test

%files         -n ruby-gnome2

%files         -n gem-glib2
%ruby_gemspecdir/glib2-%version.gemspec
%ruby_gemslibdir/glib2-%version
%ruby_gemsextdir/glib2-%version

%files         -n gem-glib2-devel
%ruby_includedir/glib2

%files         -n gem-glib2-doc
%ruby_gemsdocdir/glib2-%version

%files         -n gem-vte
%ruby_gemspecdir/vte-%version.gemspec
%ruby_gemslibdir/vte-%version
%ruby_gemsextdir/vte-%version

%files         -n gem-vte-devel
%ruby_includedir/vte

%files         -n gem-vte-doc
%ruby_gemsdocdir/vte-%version

%files         -n gem-vte3
%ruby_gemspecdir/vte3-%version.gemspec
%ruby_gemslibdir/vte3-%version

%files         -n gem-vte3-devel
%ruby_includedir/vte3

%files         -n gem-vte3-doc
%ruby_gemsdocdir/vte3-%version

%files         -n gem-vte3-no-gi
%ruby_gemspecdir/vte3-no-gi-%version.gemspec
%ruby_gemslibdir/vte3-no-gi-%version

%files         -n gem-vte3-no-gi-doc
%ruby_gemsdocdir/vte3-no-gi-%version


%changelog
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
