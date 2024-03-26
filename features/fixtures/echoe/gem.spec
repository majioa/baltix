%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname echoe

Name:          gem-echoe
Version:       4.6.6
Release:       alt1
Summary:       A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment
License:       Unlicense
Group:         Development/Ruby
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
%if_enabled check
BuildRequires: gem(allison) >= 2.0.3
BuildRequires: gem(rake) >= 0.9.2
BuildRequires: gem(rdoc) >= 2.5.11
BuildRequires: gem(rubyforge) >= 2.0.4
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Requires:      gem(rubyforge) >= 2.0.4
Requires:      gem(allison) >= 2.0.3
Requires:      gem(rdoc) >= 2.5.11
Requires:      gem(rake) >= 0.9.2
Provides:      gem(echoe) = 4.6.6


%description
A Rubygems packaging tool that provides Rake tasks for documentation, extension
compiling, testing, and deployment.


%if_enabled    doc
%package       -n gem-echoe-doc
Version:       4.6.6
Release:       alt1
Summary:       A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета echoe
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(echoe) = 4.6.6

%description   -n gem-echoe-doc
A Rubygems packaging tool that provides Rake tasks for documentation, extension
compiling, testing, and deployment documentation files.

%description   -n gem-echoe-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета echoe.
%endif


%if_enabled    devel
%package       -n gem-echoe-devel
Version:       4.6.6
Release:       alt1
Summary:       A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета echoe
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(echoe) = 4.6.6

%description   -n gem-echoe-devel
A Rubygems packaging tool that provides Rake tasks for documentation, extension
compiling, testing, and deployment development package.

%description   -n gem-echoe-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета echoe.
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
%doc CHANGELOG LICENSE MIT-LICENSE README.rdoc
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-echoe-doc
%doc CHANGELOG LICENSE MIT-LICENSE README.rdoc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-echoe-devel
%doc CHANGELOG LICENSE MIT-LICENSE README.rdoc
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 4.6.6-alt1
- + packaged gem with Ruby Policy 2.0

