%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname parser

Name:          gem-parser
Version:       3.0.1.1
Release:       alt1
Summary:       A Ruby parser
License:       MIT
Group:         Development/Ruby
Url:           https://github.com/whitequark/parser
Vcs:           https://github.com/whitequark/parser.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
BuildRequires: racc
BuildRequires: ragel
%if_enabled check
BuildRequires: gem(ast) >= 2.4.1
BuildRequires: gem(bundler) >= 1.15
BuildRequires: gem(cliver) >= 0.3.2
BuildRequires: gem(gauntlet) >= 0
BuildRequires: gem(kramdown) >= 0
BuildRequires: gem(minitest) >= 5.10
BuildRequires: gem(racc) >= 1.4.15
BuildRequires: gem(rake) >= 13.0.1
BuildRequires: gem(simplecov) >= 0.15.1
BuildRequires: gem(yard) >= 0
BuildConflicts: gem(ast) >= 2.5
BuildConflicts: gem(bundler) >= 3.0.0
BuildConflicts: gem(cliver) >= 0.4
BuildConflicts: gem(minitest) >= 6
BuildConflicts: gem(racc) >= 2
BuildConflicts: gem(rake) >= 13.1
BuildConflicts: gem(simplecov) >= 0.16
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_use_gem_dependency racc >= 1.5.1,racc < 2
%ruby_alias_names parser,ruby-parse,ruby-rewrite
Requires:      gem(ast) >= 2.4.1
Conflicts:     gem(ast) >= 2.5
Provides:      gem(parser) = 3.0.1.1

%ruby_use_gem_version parser:3.0.1.1
%ruby_on_build_rake_tasks build

%description
Parser is a production-ready Ruby parser written in pure Ruby. It recognizes as
much or more code than Ripper, Melbourne, JRubyParser or ruby_parser, and is
vastly more convenient to use.

You can also use unparser to produce equivalent source code from Parser's ASTs.


%package       -n ruby-parse
Version:       3.0.1.1
Release:       alt1
Summary:       A Ruby parser executable(s)
Summary(ru_RU.UTF-8): Исполнямка для самоцвета parser
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(parser) = 3.0.1.1

%description   -n ruby-parse
A Ruby parser executable(s).

Parser is a production-ready Ruby parser written in pure Ruby. It recognizes as
much or more code than Ripper, Melbourne, JRubyParser or ruby_parser, and is
vastly more convenient to use.

You can also use unparser to produce equivalent source code from Parser's ASTs.

%description   -n ruby-parse -l ru_RU.UTF-8
Исполнямка для самоцвета parser.


%if_enabled    doc
%package       -n gem-parser-doc
Version:       3.0.1.1
Release:       alt1
Summary:       A Ruby parser documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета parser
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(parser) = 3.0.1.1

%description   -n gem-parser-doc
A Ruby parser documentation files.

Parser is a production-ready Ruby parser written in pure Ruby. It recognizes as
much or more code than Ripper, Melbourne, JRubyParser or ruby_parser, and is
vastly more convenient to use.

You can also use unparser to produce equivalent source code from Parser's ASTs.

%description   -n gem-parser-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета parser.
%endif


%if_enabled    devel
%package       -n gem-parser-devel
Version:       3.0.1.1
Release:       alt1
Summary:       A Ruby parser development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета parser
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(parser) = 3.0.1.1
Requires:      gem(bundler) >= 1.15
Requires:      gem(rake) >= 13.0.1
Requires:      gem(racc) >= 1.4.15
Requires:      gem(cliver) >= 0.3.2
Requires:      gem(yard) >= 0
Requires:      gem(kramdown) >= 0
Requires:      gem(minitest) >= 5.10
Requires:      gem(simplecov) >= 0.15.1
Requires:      gem(gauntlet) >= 0
Conflicts:     gem(bundler) >= 3.0.0
Conflicts:     gem(rake) >= 13.1
Conflicts:     gem(racc) >= 2
Conflicts:     gem(cliver) >= 0.4
Conflicts:     gem(minitest) >= 6
Conflicts:     gem(simplecov) >= 0.16

%description   -n gem-parser-devel
A Ruby parser development package.

Parser is a production-ready Ruby parser written in pure Ruby. It recognizes as
much or more code than Ripper, Melbourne, JRubyParser or ruby_parser, and is
vastly more convenient to use.

You can also use unparser to produce equivalent source code from Parser's ASTs.

%description   -n gem-parser-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета parser.
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
%ruby_gemspec
%ruby_gemlibdir

%files         -n ruby-parse
%_bindir/ruby-parse
%_bindir/ruby-rewrite

%if_enabled    doc
%files         -n gem-parser-doc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-parser-devel
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 3.0.1.1-alt1
- ^ 2.7.2.0 -> 3.0.1.1

* Sun Nov 22 2020 Pavel Skrylev <majioa@altlinux.org> 2.7.2.0-alt1
- ^ 2.7.1.4 -> 2.7.2.0

* Fri Jul 17 2020 Pavel Skrylev <majioa@altlinux.org> 2.7.1.4-alt1.1
- ! building by usage of compilation with ragel

* Tue Jul 14 2020 Pavel Skrylev <majioa@altlinux.org> 2.7.1.4-alt1
- ^ 2.7.0.4 -> 2.7.1.4

* Wed Mar 04 2020 Pavel Skrylev <majioa@altlinux.org> 2.7.0.4-alt1
- updated (^) 2.6.4.1 -> 2.7.0.4
- changed (*) spec

* Mon Sep 16 2019 Pavel Skrylev <majioa@altlinux.org> 2.6.4.1-alt1
- updated (^) 2.6.2.0 -> 2.6.4.1

* Fri Mar 22 2019 Pavel Skrylev <majioa@altlinux.org> 2.6.2.0-alt1
- updated (^) 2.6.0.0 -> 2.6.2.0

* Wed Feb 27 2019 Pavel Skrylev <majioa@altlinux.org> 2.6.0.0-alt1
- added (+) package as a gem with usage Ruby Policy 2.0
