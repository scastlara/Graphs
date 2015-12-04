#!/usr/bin/perl
package Graphs::Degree;

=head1 NAME

Graphs::Degree

=head1 VERSION

v0.1.0

=head1 SYNOPSIS
    
    use Graphs::Degree;

    # To use the module we need a graph in a hash of hashes:
    my $graph;

    $graph->{node1}->{node2} = undef;
    $graph->{node1}->{node3} = undef;
    $graph->{node2}->{node3} = undef;
    $graph->{node3}->{node1} = undef;
    
    # Then we call the module
    my $nodes = nodes_by_degree(
        {
            graph => $graph,
            rule  => "in",
            file  => "output.txt"
        }
    );

    say "Node with highest degree: $nodes->[0]->{name}, "
        "with indegree $nodes->[0]->{in} ", 
        "and outdegree $nodes->[0]->{out}";

    # You can also pass the arguments as a hash reference:

    my $options = {
        graph => $graph,
        rule  => "in",
        file  => "output.txt"
    };

    my $nodes = nodes_by_degree($options);


    # To iterate through the nodes:

    foreach my $node (@{ $nodes }) {
        say "Node $node->{name} has indegree $node->{in} and outdegree $node->{out}";
    }

# ------

# You can use this module as a script:

    perl Degree.pm input.dot output.tbl RULE

    # You can use the rules 
        TOTAL
        IN
        OUT

=head1 Description

=head2 nodes_by_degree

This module only exports a function: nodes_by_degree()

This function does two things: it returns a data structure with the nodes of the graph ordered by
in-degree, out-degree or total-degree; and it prints the ordered nodes to a file (if specified).

This function takes a hash reference with three elements described below.

It returns a list with the nodes sorted by the specified rule. The data structure is a list of hashes. Each element
of the list points to a hash with three keys, "name", "in" and "out". To access the elements of the list:

    my $node_name      = $nodes->[$index]->{name} ;
    my $node_indegree  = $nodes->[$index]->{in}   ;
    my $node_outdegree = $nodes->[$index]->{out}  ;

=head1 ARGUMENTS

=over 8 

=item B<hash>

A hash reference that describes a graph as follows:

    %hash = (
        parent1 => child1
                => child2

        parent2 => child3
                => child4

        ...
    )

=item B<rule>

A rule to sort the nodes. Values: "TOTAL" or "IN" or "OUT" (case insensitive). 

You can sort them by TOTAL degree (sum of in and out degree), IN degree or OUT degree. By default it will sort them by TOTAL degree.

=item B<file>

A file to write the list.

If you don't specify one, it won't print the results.

=back





=cut

use warnings;
use strict;
use Exporter qw(import);
use Carp;
use Dot::Parser qw(parse_dot);

#===============================================================================
# VARIABLES AND OPTIONS
#===============================================================================
our @ISA         = qw(Exporter);
our @EXPORT_OK   = qw(nodes_by_degree);
our %EXPORT_TAGS = ( DEFAULT => [qw(nodes_by_degree)]);

__PACKAGE__->run() unless caller();


#===============================================================================
# FUNCTIONS
#===============================================================================

sub run {
    my $file    = shift @ARGV;
    my $output  = shift @ARGV;
    my $rule    = shift @ARGV;

    croak "You have to give me one DOT file to read! 1st argument.\n" 
        unless $file;
    croak "You have to tell me where to save the results. 2nd argument.\n" 
        unless $output;

    if (not defined $rule) {
        print STDERR "\nI'll sort the nodes by TOTAL degree. ", 
                     "To change this behaviour substitute rule by IN or OUT:\n",
                     "perl Degree.pm file.dot out.tbl RULE\n\n";
        $rule = "TOTAL";
    }

    my $graph = parse_dot($file);
    my $options = {
        graph => $graph,
        file  => $output,
        rule  => "$rule"
    };

    nodes_by_degree($options);

    return;
}

#--------------------------------------------------------------------------------
sub nodes_by_degree {
    my $input     = shift;
    my $graph     = $input->{graph};
    my $sort_rule = $input->{rule} if defined $input->{rule};
    my $printopt  = $input->{file} if defined $input->{file};

    $sort_rule = "TOTAL" unless $sort_rule;

    my $indegree_graph = _invert_hash($graph);
    my $node_degree    = _init_degree($graph, $indegree_graph);

    _count_degree($indegree_graph, $node_degree, "in");
    _count_degree($graph, $node_degree, "out");
    
    my $sorted_degree = _sort_by_degree($node_degree, $sort_rule);

    if ($printopt) {
        _print_table($sorted_degree, $printopt);
    }

    return($sorted_degree);
}

#--------------------------------------------------------------------------------
sub _invert_hash {
    my $graph     = shift;
    my %out_graph = ();

    map {
        my $parent = $_;
        $out_graph{ $_ }->{$parent} = undef
            for keys %{ $graph->{$parent} };
    } keys %{ $graph };

    return \%out_graph;
}

#--------------------------------------------------------------------------------
sub _init_degree {
    my $graph    = shift;
    my $in_graph = shift;
    my %out_hash = ();

    map {
        $out_hash{$_}->{in}  = 0;
        $out_hash{$_}->{out} = 0
    } keys %{ $_ } for ($graph, $in_graph);

    return \%out_hash;
}

#--------------------------------------------------------------------------------
sub _count_degree {
    my $graph  = shift;
    my $output = shift;
    my $type   = shift;

    foreach my $node ( keys %{$graph} ) {
        $output->{$node}->{$type} = scalar(keys %{ $graph->{$node} });
    }


    return;
}

#--------------------------------------------------------------------------------
sub _sort_by_degree {
    my $data   = shift;
    my $rule   = shift;
    my @output = ();
    my $sort_function;

    if ($rule =~ m/^TOTAL$/i) {
        $sort_function = \&_by_total;
    } elsif ($rule =~ m/^(INDEGREE|IN)$/i or $rule =~ m/^(OUTDEGREE|OUT)$/i) {
        $sort_function = \&_by_inout
    } else {
        croak "\nNot defined sort rule $rule\n Use TOTAL, IN or OUT\n\n";
    }

    my @sorted = sort { 
        $sort_function->($a, $b, $data, $rule) 
    } keys %{ $data };

    foreach my $node (@sorted) {
        push @output, { 
            name => $node, 
            in   => $data->{$node}->{in},
            out  => $data->{$node}->{out}
        };
    }

    return(\@output);
}

#--------------------------------------------------------------------------------
sub _by_total {
    my $a    = shift;
    my $b    = shift;
    my $data = shift;
    my $rule = shift;

    $data->{$b}->{in} + $data->{$b}->{out}
     <=>        
     $data->{$a}->{in} + $data->{$a}->{out};
 };

#--------------------------------------------------------------------------------
 sub _by_inout {
    my $a    = shift;
    my $b    = shift;
    my $data = shift;
    my $rule = lc(shift);

    $data->{$b}->{$rule} <=> $data->{$a}->{$rule};
 }

#--------------------------------------------------------------------------------
sub _print_table {
    my $data     = shift;
    my $filename = shift;
    my $rank     = 0;

    open my $fh, ">", $filename
        or die "Can't open $filename : $!\n";

    print $fh "RANK\tNODE\tINDEGREE\tOUTDEGREE\n";
    foreach my $node ( @{ $data } ) {
        print $fh ++$rank, "\t$node->{name}\t$node->{in}\t$node->{out}\n";
    }

    return;
}

1;