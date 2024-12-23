%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname rbvmomi

Name:          gem-rbvmomi
Version:       2.4.1
Release:       alt1
Summary:       Ruby interface to the VMware vSphere API
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/vmware/rbvmomi
Vcs:           https://github.com/vmware/rbvmomi.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
%if_enabled check
BuildRequires: gem(builder) >= 3.0
BuildRequires: gem(json) >= 1.8
BuildRequires: gem(nokogiri) >= 1.5
BuildRequires: gem(optimist) >= 3.0
BuildRequires: gem(rake) >= 10.5
BuildRequires: gem(simplecov) >= 0.12.0
BuildRequires: gem(test-unit) >= 2.5
BuildRequires: gem(yard) >= 0.9.5
BuildConflicts: gem(builder) >= 4
BuildConflicts: gem(nokogiri) >= 2
BuildConflicts: gem(optimist) >= 4
BuildConflicts: gem(rake) >= 16
BuildConflicts: gem(simplecov) >= 0.13
BuildConflicts: gem(yard) >= 0.10
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_use_gem_dependency rake >= 10.0,rake < 16
%ruby_alias_names rbvmomi,rbvmomish
Requires:      gem(builder) >= 3.0
Requires:      gem(json) >= 1.8
Requires:      gem(nokogiri) >= 1.5
Requires:      gem(optimist) >= 3.0
Conflicts:     gem(builder) >= 4
Conflicts:     gem(nokogiri) >= 2
Conflicts:     gem(optimist) >= 4
Obsoletes:     ruby-rbvmomi < %EVR
Provides:      ruby-rbvmomi = %EVR
Provides:      gem(rbvmomi) = 2.4.1


%description
RbVmomi is a Ruby interface to the vSphere API. Like the Perl and Java SDKs, you
can use it to manage ESX and vCenter servers. The current release supports the
vSphere 6.5 API. RbVmomi specific documentation is online and is meant to be
used alongside the official documentation.


%package       -n rbvmomish
Version:       2.4.1
Release:       alt1
Summary:       Ruby interface to the VMware vSphere API executable(s)
Summary(ru_RU.UTF-8): Исполнямка для самоцвета rbvmomi
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(rbvmomi) = 2.4.1

%description   -n rbvmomish
Ruby interface to the VMware vSphere API executable(s).

RbVmomi is a Ruby interface to the vSphere API. Like the Perl and Java SDKs, you
can use it to manage ESX and vCenter servers. The current release supports the
vSphere 6.5 API. RbVmomi specific documentation is online and is meant to be
used alongside the official documentation.

%description   -n rbvmomish -l ru_RU.UTF-8
Исполнямка для самоцвета rbvmomi.


%if_enabled    doc
%package       -n gem-rbvmomi-doc
Version:       2.4.1
Release:       alt1
Summary:       Ruby interface to the VMware vSphere API documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета rbvmomi
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(rbvmomi) = 2.4.1

%description   -n gem-rbvmomi-doc
Ruby interface to the VMware vSphere API documentation files.

RbVmomi is a Ruby interface to the vSphere API. Like the Perl and Java SDKs, you
can use it to manage ESX and vCenter servers. The current release supports the
vSphere 6.5 API. RbVmomi specific documentation is online and is meant to be
used alongside the official documentation.

%description   -n gem-rbvmomi-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета rbvmomi.
%endif


%if_enabled    devel
%package       -n gem-rbvmomi-devel
Version:       2.4.1
Release:       alt1
Summary:       Ruby interface to the VMware vSphere API development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета rbvmomi
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(rbvmomi) = 2.4.1
Requires:      gem(rake) >= 10.5
Requires:      gem(simplecov) >= 0.12.0
Requires:      gem(yard) >= 0.9.5
Requires:      gem(test-unit) >= 2.5
Conflicts:     gem(rake) >= 16
Conflicts:     gem(simplecov) >= 0.13
Conflicts:     gem(yard) >= 0.10

%description   -n gem-rbvmomi-devel
Ruby interface to the VMware vSphere API development package.

RbVmomi is a Ruby interface to the vSphere API. Like the Perl and Java SDKs, you
can use it to manage ESX and vCenter servers. The current release supports the
vSphere 6.5 API. RbVmomi specific documentation is online and is meant to be
used alongside the official documentation.

%description   -n gem-rbvmomi-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета rbvmomi.
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
%doc LICENSE README.md
%ruby_gemspec
%ruby_gemlibdir

%files         -n rbvmomish
%doc LICENSE README.md
%_bindir/rbvmomish

%if_enabled    doc
%files         -n gem-rbvmomi-doc
%doc LICENSE README.md
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-rbvmomi-devel
%doc LICENSE README.md
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 2.4.1-alt1
- ^ 2.3.0 -> 2.4.1

* Wed Mar 04 2020 Pavel Skrylev <majioa@altlinux.org> 2.3.0-alt1
- updated (^) 2.2.0 -> 2.3.0
- fixed (!) spec

* Mon Sep 16 2019 Pavel Skrylev <majioa@altlinux.org> 2.2.0-alt1
- updated (^) 2.1.2 -> 2.2.0
- fixed (!) spec

* Thu Jun 06 2019 Pavel Skrylev <majioa@altlinux.org> 2.1.2-alt1
- updated (^) 1.13.0 -> 2.1.2

* Fri Mar 22 2019 Pavel Skrylev <majioa@altlinux.org> 1.13.0-alt2
- moved to (>) Ruby Policy 2.0
- removed (-) bug (closes #36334)

* Thu Aug 30 2018 Pavel Skrylev <majioa@altlinux.org> 1.13.0-alt1
- Initial build for Sisyphus
