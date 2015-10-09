package MarpaX::RFC::RFC3986;
use Moo;
use MarpaX::RFC::RFC3986::BNF;
use MooX::Role::Parameterized::With 'MarpaX::Role::Parameterized::ResourceIdentifier'
  => {
      BNF_section_data => MarpaX::RFC::RFC3986::BNF->section_data('BNF')
     };

# ABSTRACT: Uniform Resource Identifier (URI): Generic Syntax - Marpa Parser

# VERSION

# AUTHORITY

# References: RFC 3986       URI                                     http://tools.ietf.org/html/rfc3986
#             RFC 6874       IPv6 Zone Identifiers                   http://tools.ietf.org/html/rfc6874
#             RFC 7320       URI Design and Ownership                http://tools.ietf.org/html/rfc7320 (does not affect the grammar)

=head1 DESCRIPTION

This module parses an URI reference as per RFC3986 STD 66, with RFC6874 update about IPv6 Zone Identifiers. It is not intended as a replacement of the URI module, but more for data validation using a strict grammar with good error reporting.

=head1 SYNOPSIS

    use MarpaX::RFC::RFC3986;
    use Try::Tiny;
    use Data::Dumper;

    print Dumper(MarpaX::RFC::RFC3986->new('http://www.perl.org'));

    try {
      print STDERR "\nThe following is an expected failure:\n";
      MarpaX::RFC::RFC3986->new('http://invalid##');
    } catch {
      print STDERR "$_\n";
      return;
    }

=head1 URI DESCRIPTION

Quoted from the RFC here is the overall structure of an URI that will help understand the meaning of the methods thereafter:

         foo://example.com:8042/over/there?name=ferret#nose
         \_/   \______________/\_________/ \_________/ \__/
          |           |            |            |        |
       scheme     authority       path        query   fragment
          |   _____________________|__
         / \ /                        \
         urn:example:animal:ferret:nose

The grammar is parsing both absolute URI and relative URI, the corresponding start rule being named a URI reference.

An absolute URI has the following structure:

         URI = scheme ":" hier-part [ "?" query ] [ "#" fragment ]

while a relative URI is split into:

         relative-ref  = relative-part [ "?" query ] [ "#" fragment ]

Back to the overall structure, the authority is:

         authority   = [ userinfo "@" ] host [ ":" port ]

where the host can be an IP-literal with Zone information, and IPV4 address or a registered name:

         host = IP-literal / IPv4address / reg-name

The Zone Identifier is an extension to original RFC3986, and is defined in RFC6874:

         IP-literal = "[" ( IPv6address / IPv6addrz / IPvFuture  ) "]"

         ZoneID = 1*( unreserved / pct-encoded )

         IPv6addrz = IPv6address "%25" ZoneID

=head1 CLASS METHODS

=head2 MarpaX::RFC::RFC3986->new(@options --> InstanceOf['MarpaX::RFC::RFC3986'])

Instantiate a new object. Usage is either C<MarpaX::RFC::RFC3986-E<gt>new(value =E<gt> $uri)> or C<MarpaX::RFC::RFC3986-E<gt>new($uri)>. This method will croak if the the C<$uri> parameter cannot coerce to a string nor is a valid URI. The variable C<$self> is used below to refer to this object instance.

=head2 MarpaX::RFC::RFC3986->grammar( --> InstanceOf['Marpa::R2::Scanless::G'])

A Marpa::R2::Scanless::G instance, hosting the computed grammar. This is a class variable, i.e. works also with C<$self>.

=head2 MarpaX::RFC::RFC3986->bnf( --> Str)

The BNF grammar used to parse an URI. This is a class variable, i.e. works also with C<$self>.

=head1 OBJECT METHODS

=head2 $self->value( --> Str)

The variable given in input to C<new()>.

=head2 $self->scheme( --> Str|Undef)

The URI scheme. Can be undefined.

=head2 $self->authority( --> Str|Undef)

The URI authority. Can be undefined.

=head2 $self->path( --> Str)

The URI path. Note that an URI always have a path, although it can be empty.

=head2 $self->query( --> Str|Undef)

The URI query. Can be undefined.

=head2 $self->fragment( --> Str|Undef)

The URI fragment. Can be undefined.

=head2 $self->hier_part( --> Str|Undef)

The URI hier part. Can be undefined.

=head2 $self->userinfo( --> Str|Undef)

The URI userinfo. Can be undefined.

=head2 $self->host( --> Str|Undef)

The URI host. Can be undefined.

=head2 $self->port( --> Str|Undef)

The URI port. Can be undefined.

=head2 $self->relative_part( --> Str|Undef)

The URI relative part. Can be undefined.

=head2 $self->ip_literal( --> Str|Undef)

The URI IP literal. Can be undefined.

=head2 $self->zoneid( --> Str|Undef)

The URI IP's zone id. Can be undefined.

=head2 $self->ipv4address( --> Str|Undef)

The URI IP Version 4 address. Can be undefined.

=head2 $self->reg_name( --> Str|Undef)

The URI registered name. Can be undefined.

=head2 $self->is_absolute( --> Bool)

Returns a true value if the URI is absolute, false otherwise.

=head1 SEE ALSO

L<Marpa::R2>

L<URI>

L<Data::Validate::URI>

L<Uniform Resource Identifier (URI): Generic Syntax|http://tools.ietf.org/html/rfc3986>

L<Representing IPv6 Zone Identifiers in Address Literals and Uniform Resource Identifiers|http://tools.ietf.org/html/rfc6874>

L<URI Design and Ownership|http://tools.ietf.org/html/rfc7320>

=cut

1;
