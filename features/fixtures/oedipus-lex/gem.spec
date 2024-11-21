%define        _unpackaged_files_terminate_build 1
%def_enable    check
%def_enable    doc
%def_enable    devel
%define        gemname oedipus_lex

Name:          gem-oedipus-lex
Version:       2.6.2
Release:       alt1
Summary:       Oedipus Lex is a lexer generator in the same family as Rexical and Rex
License:       MIT
Group:         Development/Ruby
Url:           http://github.com/seattlerb/oedipus_lex
Vcs:           https://github.com/seattlerb/oedipus_lex.git
Packager:      Ruby Maintainers Team <ruby@packages.altlinux.org>
BuildArch:     noarch

Source:        %name-%version.tar
BuildRequires(pre): rpm-build-ruby
%if_enabled check
BuildRequires: gem(hoe) >= 0
BuildRequires: gem(rdoc) >= 4.0
%endif

%add_findreq_skiplist %ruby_gemslibdir/**/*
%add_findprov_skiplist %ruby_gemslibdir/**/*
%ruby_alias_names oedipus_lex,oedipus-lex
Requires:      ruby >= 2.7
Conflicts:     ruby >= 4.0
Provides:      gem(oedipus_lex) = 2.6.2

%description
Oedipus Lex is a lexer generator in the same family as Rexical and Rex. Oedipus
Lex is my independent lexer fork of Rexical. Rexical was in turn a fork of Rex.
We've been unable to contact the author of rex in order to take it over, fix it
up, extend it, and relicense it to MIT. So, Oedipus was written clean-room in
order to bypass licensing constraints (and because bootstrapping is
fun).

Oedipus brings a lot of extras to the table and at this point is only
historically related to rexical. The syntax has changed enough that any rexical
lexer will have to be tweaked to work inside of oedipus. At the very least, you
need to add slashes to all your regexps.

Oedipus, like rexical, is based primarily on generating code much like you would
a hand-written lexer. It is _not_ a table or hash driven lexer. It uses
StrScanner within a multi-level case statement. As such, Oedipus matches on the
_first_ match, not the longest (like lex and its ilk).

This documentation is not meant to bypass any prerequisite knowledge on lexing
or parsing. If you'd like to study the subject in further detail, please try
[TIN321] or the [LLVM Tutorial] or some other good resource for CS learning.
Books... books are good. I like books.


%if_enabled    doc
%package       -n gem-oedipus-lex-doc
Version:       2.6.2
Release:       alt1
Summary:       Oedipus Lex is a lexer generator in the same family as Rexical and Rex documentation files
Summary(ru_RU.UTF-8): Файлы сведений для самоцвета oedipus_lex
Group:         Development/Documentation
BuildArch:     noarch

Requires:      gem(oedipus_lex) = 2.6.2

%description   -n gem-oedipus-lex-doc
Oedipus Lex is a lexer generator in the same family as Rexical and Rex
documentation files.

Oedipus Lex is a lexer generator in the same family as Rexical and Rex. Oedipus
Lex is my independent lexer fork of Rexical. Rexical was in turn a fork of Rex.
We've been unable to contact the author of rex in order to take it over, fix it
up, extend it, and relicense it to MIT. So, Oedipus was written clean-room in
order to bypass licensing constraints (and because bootstrapping is
fun).

Oedipus brings a lot of extras to the table and at this point is only
historically related to rexical. The syntax has changed enough that any rexical
lexer will have to be tweaked to work inside of oedipus. At the very least, you
need to add slashes to all your regexps.

Oedipus, like rexical, is based primarily on generating code much like you would
a hand-written lexer. It is _not_ a table or hash driven lexer. It uses
StrScanner within a multi-level case statement. As such, Oedipus matches on the
_first_ match, not the longest (like lex and its ilk).

This documentation is not meant to bypass any prerequisite knowledge on lexing
or parsing. If you'd like to study the subject in further detail, please try
[TIN321] or the [LLVM Tutorial] or some other good resource for CS learning.
Books... books are good. I like books.

%description   -n gem-oedipus-lex-doc -l ru_RU.UTF-8
Файлы сведений для самоцвета oedipus_lex.
%endif


%if_enabled    devel
%package       -n gem-oedipus-lex-devel
Version:       2.6.2
Release:       alt1
Summary:       Oedipus Lex is a lexer generator in the same family as Rexical and Rex development package
Summary(ru_RU.UTF-8): Файлы для разработки самоцвета oedipus_lex
Group:         Development/Ruby
BuildArch:     noarch

Requires:      gem(oedipus_lex) = 2.6.2
Requires:      gem(hoe) >= 0
Requires:      gem(rdoc) >= 4.0

%description   -n gem-oedipus-lex-devel
Oedipus Lex is a lexer generator in the same family as Rexical and Rex
development package.

Oedipus Lex is a lexer generator in the same family as Rexical and Rex. Oedipus
Lex is my independent lexer fork of Rexical. Rexical was in turn a fork of Rex.
We've been unable to contact the author of rex in order to take it over, fix it
up, extend it, and relicense it to MIT. So, Oedipus was written clean-room in
order to bypass licensing constraints (and because bootstrapping is
fun).

Oedipus brings a lot of extras to the table and at this point is only
historically related to rexical. The syntax has changed enough that any rexical
lexer will have to be tweaked to work inside of oedipus. At the very least, you
need to add slashes to all your regexps.

Oedipus, like rexical, is based primarily on generating code much like you would
a hand-written lexer. It is _not_ a table or hash driven lexer. It uses
StrScanner within a multi-level case statement. As such, Oedipus matches on the
_first_ match, not the longest (like lex and its ilk).

This documentation is not meant to bypass any prerequisite knowledge on lexing
or parsing. If you'd like to study the subject in further detail, please try
[TIN321] or the [LLVM Tutorial] or some other good resource for CS learning.
Books... books are good. I like books.

%description   -n gem-oedipus-lex-devel -l ru_RU.UTF-8
Файлы для разработки самоцвета oedipus_lex.
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
%doc History.rdoc README.rdoc
%ruby_gemspec
%ruby_gemlibdir

%if_enabled    doc
%files         -n gem-oedipus-lex-doc
%doc History.rdoc README.rdoc
%ruby_gemdocdir
%endif

%if_enabled    devel
%files         -n gem-oedipus-lex-devel
%doc History.rdoc README.rdoc
%endif


%changelog
* Wed Apr 21 2021 Pavel Skrylev <majioa@altlinux.org> 2.6.2-alt1
- + packaged gem with Ruby Policy 2.0
- * define explicit dependencies
