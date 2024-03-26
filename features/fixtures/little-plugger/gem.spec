%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname little-plugger

Name:          gem-little-plugger
Version:       1.1.4
Release:       alt1
Summary:       LittlePlugger is a module that provides Gem based plugin management
License:       MIT
Group:         Development/Ruby
Url:           http://gemcutter.org/gems/little-plugger
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
%if_enabled check
BuildRequires: gem(rspec) >= 3.3
BuildConflicts: gem(rspec) >= 4
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Provides:      gem(little-plugger) = 1.1.4


%description
LittlePlugger is a module that provides Gem based plugin management. By
extending your own class or module with LittlePlugger you can easily manage the
loading and initializing of plugins provided by other gems.


%if_enabled    doc
%package       -n gem-little-plugger-doc
Version:       1.1.4
Release:       alt1
Summary:       LittlePlugger is a module that provides Gem based plugin management documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета little-plugger
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(little-plugger) = 1.1.4

%description   -n gem-little-plugger-doc
LittlePlugger is a module that provides Gem based plugin management
documentation files.

LittlePlugger is a module that provides Gem based plugin management. By
extending your own class or module with LittlePlugger you can easily manage the
loading and initializing of plugins provided by other gems.

%description   -n gem-little-plugger-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета little-plugger.
%endif


%if_enabled    devel
%package       -n gem-little-plugger-devel
Version:       1.1.4
Release:       alt1
Summary:       LittlePlugger is a module that provides Gem based plugin management development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета little-plugger
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(little-plugger) = 1.1.4
Requires:      gem(rspec) >= 3.3
Conflicts:     gem(rspec) >= 4

%description   -n gem-little-plugger-devel
LittlePlugger is a module that provides Gem based plugin management development
package.

LittlePlugger is a module that provides Gem based plugin management. By
extending your own class or module with LittlePlugger you can easily manage the
loading and initializing of plugins provided by other gems.

%description   -n gem-little-plugger-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета little-plugger.
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
%doc README.rdoc History.txt
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-little-plugger-doc
%doc README.rdoc History.txt
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-little-plugger-devel
%doc README.rdoc History.txt
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 1.1.4-alt1
- + packaged gem with Ruby Policy 2.0

