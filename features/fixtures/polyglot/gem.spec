%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%define        gemname polyglot

Name:          gem-polyglot
Version:       0.3.5
Release:       alt1
Summary:       Augment 'require' to load non-Ruby file types
License:       MIT
Group:         Development/Ruby
Url:           http://github.com/cjheath/polyglot
Vcs:           https://github.com/cjheath/polyglot.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
Provides:      gem(polyglot) = 0.3.5

%description
The Polyglot library allows a Ruby module to register a loader for the file type
associated with a filename extension, and it augments 'require' to find and load
matching files.


%if_enabled    doc
%package       -n gem-polyglot-doc
Version:       0.3.5
Release:       alt1
Summary:       Augment 'require' to load non-Ruby file types documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета polyglot
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(polyglot) = 0.3.5

%description   -n gem-polyglot-doc
Augment 'require' to load non-Ruby file types documentation files.

The Polyglot library allows a Ruby module to register a loader for the file type
associated with a filename extension, and it augments 'require' to find and load
matching files.

%description   -n gem-polyglot-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета polyglot.
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
%doc History.txt License.txt README.txt
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-polyglot-doc
%doc History.txt License.txt README.txt
%ruby_gemdocdir
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 0.3.5-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
