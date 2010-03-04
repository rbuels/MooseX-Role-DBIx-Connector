package MooseX::Role::DBIx::Connector;
use MooseX::Role::Parameterized;
use DBIx::Connector;

our $VERSION = '0.10';
$VERSION = eval $VERSION;


parameter 'connection_name' => qw(
    is        ro
    isa       Str
    default   db
   );


parameter 'connection_description' => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
   );   __PACKAGE__->meta->parameters_metaclass->add_method(
   _build_connection_description => sub {
       my $n = shift->connection_name;
       $n =~ s/_/ /g;
       return $n;
   });


parameter 'accessor_options' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);


role {

    my $p        = shift;
    my $conn     = $p->connection_name;
    my $desc     = $p->connection_description;
    my $opts     = $p->accessor_options;

    has "${conn}_dsn" => (
        documentation => "DBI dsn for connecting to the $desc",
        isa           => 'Str',
        is            => 'ro',
        required      => 1,
        @{ $opts->{$conn.'_dsn'} || [] },
       );
    has "${conn}_user" => (
        documentation  => "username for connecting to the $desc",
        isa            => 'Str',
        is             => 'ro',
        @{ $opts->{"${conn}_user"} || [] },
       );
    has "${conn}_password" => (
        documentation => "password for connecting to the $desc",
        isa           => 'Str',
        is            => 'ro',
        @{ $opts->{"${conn}_password"} || [] },
       );

    has "${conn}_attrs" => (
        documentation => "hashref of DBI attributes for connecting to $desc",
        is            => 'ro',
        isa           => 'HashRef',
        default       => sub { {} },
        @{ $opts->{"${conn}_attrs"} || [] },
       );

    has "${conn}_conn" => (
        is         => 'ro',
        isa        => 'DBIx::Connector',
        lazy_build => 1,
        @{ $opts->{"${conn}_conn"} || [] },
       );

    method "_build_${conn}_conn" => sub {
        my ($self) = @_;

        no strict 'refs';

        return DBIx::Connector->new(
            $self->{"${conn}_dsn"},
            $self->{"${conn}_user"},
            $self->{"${conn}_password"},
            $self->{"${conn}_attrs"},
           );
    };

};
