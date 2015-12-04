#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Dot::Parser qw(parse_dot);
use Graphs::Degree qw(nodes_by_degree);

# GET OPTIONS
my %options;
$options{rule} = "TOTAL"; # default

GetOptions (
    \%options, 
    "input=s",
    "output=s",
    "rule=s"   
 ); 


# CHECK COMMAND-LINE ARGUMENTS
if (not defined $options{input}) {
    die "You have to give me an input DOT file\nUse option -i\n";
} elsif (not defined $options{output}) {
    die "You have to give me an output file name\nUse option -o\n";
} 

print STDERR "Using $options{rule} degree to sort the nodes.\n",
             "You can change this behaviour use the option -r\n",
             "\t(choose IN for in-degree or OUT for out-degree)\n";
             
# MAIN SCRIPT
my $graph = parse_dot( $options{input} );

my $options_to_sort = {
    graph => $graph,
    file  => $options{output},
    rule  => $options{rule}
};

nodes_by_degree($options_to_sort);