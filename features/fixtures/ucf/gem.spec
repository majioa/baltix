%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname ucf

Name:          gem-ucf
Version:       2.0.2
Release:       alt1
Summary:       This is a Ruby library for working with UCF documents
License:       BSD
Group:         Development/Ruby
Url:           http://mygrid.github.io/ruby-ucf/
Vcs:           https://github.com/mygrid/ruby-ucf.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
%if_enabled check
BuildRequires: gem(bundler) >= 0
BuildRequires: gem(coveralls) >= 0
BuildRequires: gem(nokogiri) >= 1.6
BuildRequires: gem(rake) >= 10.4
BuildRequires: gem(rdoc) >= 4.1
BuildRequires: gem(test-unit) >= 3.0
BuildRequires: gem(zip-container) >= 4.0.1
BuildConflicts: gem(nokogiri) >= 2
BuildConflicts: gem(rake) >= 11
BuildConflicts: gem(rdoc) >= 5
BuildConflicts: gem(test-unit) >= 4
BuildConflicts: gem(zip-container) >= 4.1
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 1.9.3
Requires:      gem(zip-container) >= 4.0.1
Conflicts:     gem(zip-container) >= 4.1
Obsoletes:     ruby-ucf < %EVR
Provides:      ruby-ucf = %EVR
Provides:      gem(ucf) = 2.0.2

%description
This is a Ruby library for working with UCF documents. See the specification at
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for more
details. UCF is a type of EPUB and very similar to the EPUB Open Container
Format (OCF).


%if_enabled    doc
%package       -n gem-ucf-doc
Version:       2.0.2
Release:       alt1
Summary:       This is a Ruby library for working with UCF documents documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета ucf
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(ucf) = 2.0.2
Obsoletes:     ruby-ucf-doc < %EVR
Provides:      ruby-ucf-doc = %EVR

%description   -n gem-ucf-doc
This is a Ruby library for working with UCF documents documentation files.

This is a Ruby library for working with UCF documents. See the specification at
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for more
details. UCF is a type of EPUB and very similar to the EPUB Open Container
Format (OCF).

%description   -n gem-ucf-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета ucf.
%endif


%if_enabled    devel
%package       -n gem-ucf-devel
Version:       2.0.2
Release:       alt1
Summary:       This is a Ruby library for working with UCF documents development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета ucf
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(ucf) = 2.0.2
Requires:      gem(bundler) >= 0
Requires:      gem(coveralls) >= 0
Requires:      gem(nokogiri) >= 1.6
Requires:      gem(rake) >= 10.4
Requires:      gem(rdoc) >= 4.1
Requires:      gem(test-unit) >= 3.0
Conflicts:     gem(nokogiri) >= 2
Conflicts:     gem(rake) >= 11
Conflicts:     gem(rdoc) >= 5
Conflicts:     gem(test-unit) >= 4

%description   -n gem-ucf-devel
This is a Ruby library for working with UCF documents development package.

This is a Ruby library for working with UCF documents. See the specification at
https://learn.adobe.com/wiki/display/PDFNAV/Universal+Container+Format for more
details. UCF is a type of EPUB and very similar to the EPUB Open Container
Format (OCF).

%description   -n gem-ucf-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета ucf.
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
%files         -n gem-ucf-doc
%doc ReadMe.rdoc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-ucf-devel
%doc ReadMe.rdoc
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 2.0.2-alt1
- ^ 2.0.0 -> 2.0.2
- * renamed package with subpackages
- * define explicit dependencies

* Wed Jul 11 2018 Andrey Cherepanov <cas@altlinux.org> 2.0.0-alt1.1
- Rebuild with new Ruby autorequirements.

* Tue Feb 17 2015 Andrey Cherepanov <cas@altlinux.org> 2.0.0-alt1
- Initial build for ALT Linux (without tests)
