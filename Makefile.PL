use ExtUtils::MakeMaker;
use strict;
use warnings FATAL => 'all';


    WriteMakefile(
        NAME            => 'Graphs::Degree',
        VERSION_FROM    => 'lib/Graphs/Degree.pm',
        EXE_FILES => ['bin/dot2degree.pl'],
        PREREQ_PM => {
            "Dot::Parser" => 0 
        }
    );

