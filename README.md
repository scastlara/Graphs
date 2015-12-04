# NAME

Graphs::Degree

# VERSION

v0.1.0

# SYNOPSIS

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

# Description

## nodes\_by\_degree

This module only exports a function: nodes\_by\_degree()

This function does two things: it returns a data structure with the nodes of the graph ordered by
in-degree, out-degree or total-degree; and it prints the ordered nodes to a file (if specified).

This function takes a hash reference with three elements described below.

It returns a list with the nodes sorted by the specified rule. The data structure is a list of hashes. Each element
of the list points to a hash with three keys, "name", "in" and "out". To access the elements of the list:

    my $node_name      = $nodes->[$index]->{name} ;
    my $node_indegree  = $nodes->[$index]->{in}   ;
    my $node_outdegree = $nodes->[$index]->{out}  ;

# ARGUMENTS

- **hash**

    A hash reference that describes a graph as follows:

        %hash = (
            parent1 => child1
                    => child2

            parent2 => child3
                    => child4

            ...
        )

- **rule**

    A rule to sort the nodes. Values: "TOTAL" or "IN" or "OUT" (case insensitive). 

    You can sort them by TOTAL degree (sum of in and out degree), IN degree or OUT degree. By default it will sort them by TOTAL degree.

- **file**

    A file to write the list.

    If you don't specify one, it won't print the results.
