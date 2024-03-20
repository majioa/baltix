%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname zip_container

Name:          gem-zip-container
Version:       4.0.2
Release:       alt1
Summary:       A Ruby library for working with ZIP Container Format files
License:       BSD
Group:         Development/Ruby
Url:           http://mygrid.github.io/ruby-zip-container/
Vcs:           https://github.com/mygrid/ruby-zip-container.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
%if_enabled check
BuildRequires: gem(bundler) >= 0
BuildRequires: gem(coveralls) >= 0.8
BuildRequires: gem(rake) >= 10.1
BuildRequires: gem(rdoc) >= 4.1
BuildRequires: gem(rubocop) >= 0.59
BuildRequires: gem(rubyzip) >= 2.0.0
BuildRequires: gem(test-unit) >= 3.0
BuildConflicts: gem(coveralls) >= 1
BuildConflicts: gem(rake) >= 11
BuildConflicts: gem(rdoc) >= 5
BuildConflicts: gem(rubocop) >= 1
BuildConflicts: gem(rubyzip) >= 2.1
BuildConflicts: gem(test-unit) >= 4
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_alias_names zip_container,zip-container
Requires:      gem(rubyzip) >= 2.0.0
Conflicts:     gem(rubyzip) >= 2.1
Obsoletes:     ruby-zip-container < %EVR
Provides:      ruby-zip-container = %EVR
Provides:      gem(zip_container) = 4.0.2


%description
A Ruby library for working with ZIP Container Format files. See
http://www.idpf.org/epub/30/spec/epub30-ocf.html for the OCF specification and
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for the
UCF specification.


%if_enabled    doc
%package       -n gem-zip-container-doc
Version:       4.0.2
Release:       alt1
Summary:       A Ruby library for working with ZIP Container Format files documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета zip_container
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(zip_container) = 4.0.2

%description   -n gem-zip-container-doc
A Ruby library for working with ZIP Container Format files documentation
files.

A Ruby library for working with ZIP Container Format files. See
http://www.idpf.org/epub/30/spec/epub30-ocf.html for the OCF specification and
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for the
UCF specification.

%description   -n gem-zip-container-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета zip_container.
%endif


%if_enabled    devel
%package       -n gem-zip-container-devel
Version:       4.0.2
Release:       alt1
Summary:       A Ruby library for working with ZIP Container Format files development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета zip_container
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(zip_container) = 4.0.2
Requires:      gem(bundler) >= 0
Requires:      gem(coveralls) >= 0.8
Requires:      gem(rake) >= 10.1
Requires:      gem(rdoc) >= 4.1
Requires:      gem(rubocop) >= 0.59
Requires:      gem(test-unit) >= 3.0
Conflicts:     gem(coveralls) >= 1
Conflicts:     gem(rake) >= 11
Conflicts:     gem(rdoc) >= 5
Conflicts:     gem(rubocop) >= 1
Conflicts:     gem(test-unit) >= 4

%description   -n gem-zip-container-devel
A Ruby library for working with ZIP Container Format files development
package.

A Ruby library for working with ZIP Container Format files. See
http://www.idpf.org/epub/30/spec/epub30-ocf.html for the OCF specification and
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for the
UCF specification.

%description   -n gem-zip-container-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета zip_container.
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
%doc ReadMe.rdoc
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-zip-container-doc
%doc ReadMe.rdoc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-zip-container-devel
%doc ReadMe.rdoc
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 4.0.2-alt1
- ^ 3.0.2 -> 4.0.2

* Wed Sep 05 2018 Andrey Cherepanov <cas@altlinux.org> 3.0.2-alt1
- New version.

* Wed Jul 11 2018 Andrey Cherepanov <cas@altlinux.org> 3.0.1-alt1.1
- Rebuild with new Ruby autorequirements.

* Tue Feb 17 2015 Andrey Cherepanov <cas@altlinux.org> 3.0.1-alt1
- Initial build for ALT Linux (without tests)
