%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%define        gemname rspec-support

Name:          gem-rspec-support
Version:       3.8.0
Release:       alt3
Summary:       Common code needed by the other RSpec gems
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/rspec/rspec-support
Vcs:           https://github.com/rspec/rspec-support.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
%if_enabled check
BuildRequires: gem(rake) > 10.0.0
BuildRequires: gem(thread_order) >= 1.1.0
BuildConflicts: gem(thread_order) >= 1.2
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      ruby >= 1.8.7
Obsoletes:     ruby-rspec-support < %EVR
Provides:      ruby-rspec-support = %EVR
Provides:      gem(rspec-support) = 3.8.0

%description
RSpec::Support provides common functionality to RSpec::Core, RSpec::Expectations
and RSpec::Mocks. It is considered suitable for internal use only at this time.


%if_enabled    doc
%package       -n gem-rspec-support-doc
Version:       3.8.0
Release:       alt3
Summary:       Common code needed by the other RSpec gems documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета rspec-support
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(rspec-support) = 3.8.0
Obsoletes:     ruby-rspec-support-doc < %EVR
Provides:      ruby-rspec-support-doc = %EVR

%description   -n gem-rspec-support-doc
Common code needed by the other RSpec gems documentation files.

RSpec::Support provides common functionality to RSpec::Core, RSpec::Expectations
and RSpec::Mocks. It is considered suitable for internal use only at this time.

%description   -n gem-rspec-support-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета rspec-support.
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
%doc Changelog.md LICENSE.md README.md
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-rspec-support-doc
%doc Changelog.md LICENSE.md README.md
%ruby_gemdocdir
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 3.8.0-alt3
- * renamed package with subpackages
- * define explicit dependencies

* Fri Mar 1 2019 Pavel Skrylev <majioa@altlinux.org> 3.8.0-alt2
- Use Ruby Policy 2.0.

* Mon Sep 17 2018 Andrey Cherepanov <cas@altlinux.org> 3.8.0-alt1
- New version.

* Wed Jul 11 2018 Andrey Cherepanov <cas@altlinux.org> 3.7.1-alt1.1
- Rebuild with new Ruby autorequirements.

* Wed Jan 31 2018 Andrey Cherepanov <cas@altlinux.org> 3.7.1-alt1
- New version.

* Tue Oct 17 2017 Andrey Cherepanov <cas@altlinux.org> 3.7.0-alt1
- New version

* Fri May 05 2017 Andrey Cherepanov <cas@altlinux.org> 3.6.0-alt1
- New version

* Wed Mar 08 2017 Andrey Cherepanov <cas@altlinux.org> 3.5.0-alt1
- New version

* Fri Jun 03 2016 Andrey Cherepanov <cas@altlinux.org> 3.4.1-alt1
- New version

* Wed May 20 2015 Andrey Cherepanov <cas@altlinux.org> 3.2.2-alt1
- Initial build for ALT Linux
