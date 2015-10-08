package MarpaX::RFC::RFC3986;
use Moo;
use MooX::ClassAttribute;
use Types::Standard -all;
use strict;
use diagnostics;
use Marpa::R2;
use MooX::HandlesVia;

# ABSTRACT: Uniform Resource Identifier (URI): Generic Syntax - Marpa Parser

# References: RFC 3986       URI                                     http://tools.ietf.org/html/rfc3986
#             RFC 6874       IPv6 Zone Identifiers                   http://tools.ietf.org/html/rfc6874
#             RFC 7320       URI Design and Ownership                http://tools.ietf.org/html/rfc7320 (does not affect the grammar)

# AUTHORITY

# VERSION

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

our $DATA = do { local $/; <DATA>; };

# -------------------
# EXTERNAL ATTRIBUTES
# -------------------
has value           => (is => 'rwp', isa => Str, required => 1, trigger => 1);
class_has grammar   => (is => 'ro', isa => InstanceOf['Marpa::R2::Scanless:G'], default => sub { return Marpa::R2::Scanless::G->new({ source => \$DATA }) } );
class_has bnf       => (is => 'ro', isa => Str,                                 default => $DATA );
has scheme          => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_scheme');
has authority       => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_authority');
has path            => (is => 'ro', isa => Str,           default => '',         writer => '_set_path');        # There is always a path in an URI
has query           => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_query');
has fragment        => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_fragment');
has hier_part       => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_hier_part');
has userinfo        => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_userinfo');
has host            => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_host');
has port            => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_port');
has relative_part   => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_relative_part');
has ip_literal      => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_ip_literal');
has zoneid          => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_zoneid' );
has ipv4address     => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_ipv4address');
has reg_name        => (is => 'ro', isa => Str|Undef,     default => undef,      writer => '_set_reg_name');
#
# Normalization have specific rules on Path Segment and Protocol, not under our control, so we provide methods
# to attributes that a subclass should override.
#
has scheme_normalization => (is => 'ro', isa => HashRef[CodeRef], default => sub { {}},
                             handles_via => 'Hash',
                             handles => {
                                         _exists_scheme_normalization => 'exists',
                                         _get_scheme_normalization => 'get',
                                        }
                            );
has protocol_normalization => (is => 'ro', isa => HashRef[CodeRef], default => sub { {}},
                                handles_via => 'Hash',
                                handles => {
                                            _exists_protocol_normalization => 'exists',
                                            _get_protocol_normalization => 'get',
                                           }
                               );

# -------
# METHODS
# -------
sub canonical {                        # canonical is an on-demand parsing
  my ($self) = @_;
  return ${$self->_parse(1)};
}

sub _normalize {
  my ($self, $normalized) = @_;

  my $rule_id = $Marpa::R2::Context::rule;
  my $slg     = $Marpa::R2::Context::slg;
  my ($lhs, @rhs) = map { $slg->symbol_display_form($_) } $slg->rule_expand($rule_id);

  if ($lhs eq '<pct encoded>') {
    #
    # 6.2.2.1.  Case Normalization
    # ----------------------------
    # For all URIs, the hexadecimal digits within a percent-encoding
    # triplet (e.g., "%3a" versus "%3A") are case-insensitive and therefore
    # should be normalized to use uppercase letters for the digits A-F.
    #
    $normalized = uc($normalized);
    #
    # 6.2.2.2.  Percent-Encoding Normalization
    # ----------------------------------------
    # (These URIs) should be normalized by decoding any percent-encoded octet that corresponds
    # to an unreserved character, as described in Section 2.3.
    #
    # No need to call the grammar again, we know what they are:
    # <unreserved>    ::= ALPHA | DIGIT | [-._~]
    # ALPHA         ::= [A-Za-z]
    # DIGIT         ::= [0-9]
    #
    my $char = $normalized;
    substr($char, 0, 1, '');    # Remove the '%'
    $char = chr(hex($char));
    if ($char =~ /[A-Za-z0-9._~-]/) {
      $normalized = $char;
    }
  }
  elsif ($lhs eq '<path abempty>'  ||
         $lhs eq '<path absolute>' ||
         $lhs eq '<path noscheme>' ||
         $lhs eq '<path rootless>' ||
         $lhs eq '<path empty>') {
    #
    # 6.2.2.3.  Path Segment Normalization
    # ------------------------------------
    # URI normalizers should remove dot-segments by applying the
    # remove_dot_segments algorithm to the path
    #
    $normalized = $self->_remove_dot_segments($normalized);
  }
  if ($self->_exists_scheme_normalization($lhs)) {
    #
    # 6.2.3.  Scheme-Based Normalization
    #
    my $codeRef = $self->_get_scheme_normalization($lhs);
    $normalized = $self->$codeRef($normalized);
  }
  if ($self->_exists_protocol_normalization($lhs)) {
    #
    # 6.2.4.  Protocol-Based Normalization
    #
    my $codeRef = $self->_get_protocol_normalization($lhs);
    $normalized = $self->$codeRef($normalized);
  }

  return $normalized;
}

sub _remove_dot_segments {
  my ($self, $input) = @_;

  # my $rule_id = $Marpa::R2::Context::rule;
  # my $slg     = $Marpa::R2::Context::slg;
  # my ($lhs, @rhs) = map { $slg->symbol_display_form($_) } $slg->rule_expand($rule_id);
  # print STDERR "$lhs ::= @rhs\n";

  #
  # 1.  The input buffer is initialized with the now-appended path
  # components and the output buffer is initialized to the empty
  # string.
  #
  my $output = '';

  # my $i = 0;
  # my $step = ++$i;
  # my $substep = '';
  # printf STDERR "%-10s %-30s %-30s\n", "STEP", "OUTPUT BUFFER", "INPUT BUFFER";
  # printf STDERR "%-10s %-30s %-30s\n", "$step$substep", $output, $input;
  # $step = ++$i;
  #
  # 2.  While the input buffer is not empty, loop as follows:
  #
  while (length($input)) {
    #
    # A. If the input buffer begins with a prefix of "../" or "./",
    #    then remove that prefix from the input buffer; otherwise,
    #
    if (index($input, '../') == 0) {
      substr($input, 0, 3, '');
      # $substep = 'A';
    }
    elsif (index($input, './') == 0) {
      substr($input, 0, 2, '');
      # $substep = 'A';
    }
    #
    # B. if the input buffer begins with a prefix of "/./" or "/.",
    #    where "." is a complete path segment, then replace that
    #    prefix with "/" in the input buffer; otherwise,
    #
    elsif (index($input, '/./') == 0) {
      substr($input, 0, 3, '/');
      # $substep = 'B';
    }
    elsif ($input =~ /^\/\.(?:[\/]|\z)/) {            # Take care this can confuse the other test on '/../ or '/..'
      substr($input, 0, 2, '/');
      # $substep = 'B';
    }
    #
    # C. if the input buffer begins with a prefix of "/../" or "/..",
    #    where ".." is a complete path segment, then replace that
    #    prefix with "/" in the input buffer and remove the last
    #    segment and its preceding "/" (if any) from the output
    #    buffer; otherwise,
    #
    elsif (index($input, '/../') == 0) {
      substr($input, 0, 4, '/');
      $output =~ s/\/?[^\/]*\z//;
      # $substep = 'C';
    }
    elsif ($input =~ /^\/\.\.(?:[^\/]|\z)/) {
      substr($input, 0, 3, '/');
      $output =~ s/\/?[^\/]*\z//;
      # $substep = 'C';
    }
    #
    # D. if the input buffer consists only of "." or "..", then remove
    #    that from the input buffer; otherwise,
    #
    elsif (($input eq '.') || ($input eq '..')) {
      $input = '';
      # $substep = 'D';
    }
    #
    # E. move the first path segment in the input buffer to the end of
    #    the output buffer, including the initial "/" character (if
    #    any) and any subsequent characters up to, but not including,
    #    the next "/" character or the end of the input buffer.
    #
    #    Note: "or the end of the input buffer" ?
    #
    else {
      $input =~ /^\/?([^\/]*)/;                            # This will always match
      $output .= substr($input, $-[0], $+[0] - $-[0], ''); # Note that perl has no problem saying length is zero
      # $substep = 'E';
    }
    # printf STDERR "%-10s %-30s %-30s\n", "$step$substep", $output, $input;
  }
  #
  # 3. Finally, the output buffer is returned as the result of
  #    remove_dot_segments.
  #
  return $output;
}

sub BUILDARGS {
  my ($class, @args) = @_;
  unshift(@args, 'value') if (@args % 2 == 1);
  return { @args };
};

sub BUILD {
  my ($self) = @_;
  $self->_parse(0);
  return;
}

sub _trigger_value {
  my ($self, $value) = @_;
  $self->_parse(0);
  return;
}

sub _parse {
  my ($self, $normalize) = @_;
  #
  # This hack just to avoid recursivity: we do not want Marpa to
  # call another new() but operate on our instance immediately
  #
  local $MarpaX::RFC::RFC3986::SELF      = $self;
  local $MarpaX::RFC::RFC3986::NORMALIZE = $normalize;
  return $self->grammar->parse(\$self->value, { ranking_method => 'high_rule_only' });
}

sub is_absolute {
  my ($self) = @_;
  #
  # No need to reparse. An absolute URI is when scheme and hier_part are defined,
  # and fragment is undefined
  #
  return Str->check($self->scheme) && Str->check($self->hier_part) && Undef->check($self->fragment);
}

#
# Grammar rules
#
sub _marpa_concat        { shift; my $self = $MarpaX::RFC::RFC3986::SELF; my $concat = join('', @_); return $MarpaX::RFC::RFC3986::NORMALIZE ? $self->_normalize($concat) : $concat; }
sub _marpa_scheme        { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_scheme        ($self->_marpa_concat(@_)); }
sub _marpa_authority     { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_authority     ($self->_marpa_concat(@_)); }
sub _marpa_path          { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_path          ($self->_marpa_concat(@_)); }
sub _marpa_query         { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_query         ($self->_marpa_concat(@_)); }
sub _marpa_fragment      { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_fragment      ($self->_marpa_concat(@_)); }
sub _marpa_hier_part     { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_hier_part     ($self->_marpa_concat(@_)); }
sub _marpa_userinfo      { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_userinfo      ($self->_marpa_concat(@_)); }
sub _marpa_host          { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_host          ($self->_marpa_concat(@_)); }
sub _marpa_port          { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_port          ($self->_marpa_concat(@_)); }
sub _marpa_relative_part { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_relative_part ($self->_marpa_concat(@_)); }
sub _marpa_ip_literal    { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_ip_literal    ($self->_marpa_concat(@_)); }
sub _marpa_zoneid        { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_zoneid        ($self->_marpa_concat(@_)); }
sub _marpa_ipv4address   { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_ipv4address   ($self->_marpa_concat(@_)); }
sub _marpa_reg_name      { shift; my $self = $MarpaX::RFC::RFC3986::SELF; return $self->_set_reg_name      ($self->_marpa_concat(@_)); }

1;
__DATA__
inaccessible is ok by default
:default ::= action => MarpaX::RFC::RFC3986::_marpa_concat
:start ::= <URI reference>

<URI>         ::= <scheme> ':' <hier part> '?' <query> '#' <fragment>
                | <scheme> ':' <hier part> '?' <query>
                | <scheme> ':' <hier part>             '#' <fragment>
                | <scheme> ':' <hier part>

<hier part>     ::= '//' <authority> <path abempty>                     action => MarpaX::RFC::RFC3986::_marpa_hier_part
                  | <path absolute>                                     action => MarpaX::RFC::RFC3986::_marpa_hier_part
                  | <path rootless>                                     action => MarpaX::RFC::RFC3986::_marpa_hier_part
                  | <path empty>                                        action => MarpaX::RFC::RFC3986::_marpa_hier_part

<URI reference> ::= <URI>
                  | <relative ref>

<absolute URI>  ::= <scheme> ':' <hier part> '?' <query>
                  | <scheme> ':' <hier part>

<relative ref>  ::= <relative part> '?' <query> '#' <fragment>
                  | <relative part> '?' <query>
                  | <relative part>             '#' <fragment>
                  | <relative part>

<relative part> ::= '//' <authority> <path abempty>                    action => MarpaX::RFC::RFC3986::_marpa_relative_part
                  | <path absolute>                                    action => MarpaX::RFC::RFC3986::_marpa_relative_part
                  | <path noscheme>                                    action => MarpaX::RFC::RFC3986::_marpa_relative_part
                  | <path empty>                                       action => MarpaX::RFC::RFC3986::_marpa_relative_part

<scheme trailer unit> ::= ALPHA | DIGIT | [+-.]
<scheme header>       ::= ALPHA
<scheme trailer>      ::= <scheme trailer unit>*
<scheme>              ::= <scheme header> <scheme trailer>              action => MarpaX::RFC::RFC3986::_marpa_scheme

<authority>     ::= <userinfo> '@' <host> ':' <port>                    action => MarpaX::RFC::RFC3986::_marpa_authority
                  | <userinfo> '@' <host>                               action => MarpaX::RFC::RFC3986::_marpa_authority
                  |                <host> ':' <port>                    action => MarpaX::RFC::RFC3986::_marpa_authority
                  |                <host>                               action => MarpaX::RFC::RFC3986::_marpa_authority

<userinfo unit> ::= <unreserved> | <pct encoded> | <sub delims> | ':'
<userinfo>      ::= <userinfo unit>*                                    action => MarpaX::RFC::RFC3986::_marpa_userinfo

  #
  # As per the RFC:
  # he syntax rule for host is ambiguous because it does not completely
  # distinguish between an IPv4address and a reg-name.  In order to
  # disambiguate the syntax, we apply the "first-match-wins" algorithm:
  # If host matches the rule for IPv4address, then it should be
  # considered an IPv4 address literal and not a reg-name.

<host>          ::= <IP literal>                                        action => MarpaX::RFC::RFC3986::_marpa_host
                  | <IPv4address>                            rank => 1  action => MarpaX::RFC::RFC3986::_marpa_host
                  | <reg name>                                          action => MarpaX::RFC::RFC3986::_marpa_host

<port>          ::= DIGIT*                                              action => MarpaX::RFC::RFC3986::_marpa_port

<IP literal>    ::= '[' IPv6address ']'                                 action => MarpaX::RFC::RFC3986::_marpa_ip_literal
                  | '[' IPv6addrz   ']'                                 action => MarpaX::RFC::RFC3986::_marpa_ip_literal
                  | '[' IPvFuture   ']'                                 action => MarpaX::RFC::RFC3986::_marpa_ip_literal

<ZoneID unit>   ::= <unreserved> | <pct encoded>
<ZoneID>        ::= <ZoneID unit>+                                      action => MarpaX::RFC::RFC3986::_marpa_zoneid

<IPv6addrz>     ::= <IPv6address> '%25' <ZoneID>

<hexdigit many>          ::= HEXDIG+
<IPvFuture trailer unit> ::= <unreserved> | <sub delims> | ':'
<IPvFuture trailer>      ::= <IPvFuture trailer unit>+
<IPvFuture>              ::= 'v' <hexdigit many> '.' <IPvFuture trailer>

<1 h16 colon>   ::= <h16> ':'
<2 h16 colon>   ::= <1 h16 colon> <1 h16 colon>
<3 h16 colon>   ::= <2 h16 colon> <1 h16 colon>
<4 h16 colon>   ::= <3 h16 colon> <1 h16 colon>
<5 h16 colon>   ::= <4 h16 colon> <1 h16 colon>
<6 h16 colon>   ::= <5 h16 colon> <1 h16 colon>

<at most 1 h16 colon>  ::=                                              rank => 0
<at most 1 h16 colon>  ::=         <1 h16 colon>                        rank => 1
<at most 2 h16 colon>  ::= <at most 1 h16 colon>                        rank => 0
                         | <at most 1 h16 colon> <1 h16 colon>          rank => 1
<at most 3 h16 colon>  ::= <at most 2 h16 colon>                        rank => 0
                         | <at most 2 h16 colon> <1 h16 colon>          rank => 1
<at most 4 h16 colon>  ::= <at most 3 h16 colon>                        rank => 0
                         | <at most 3 h16 colon> <1 h16 colon>          rank => 1
<at most 5 h16 colon>  ::= <at most 4 h16 colon>                        rank => 0
                         | <at most 4 h16 colon> <1 h16 colon>          rank => 1
<at most 6 h16 colon>  ::= <at most 5 h16 colon>                        rank => 0
                         | <at most 5 h16 colon> <1 h16 colon>          rank => 1

<IPv6address>   ::=                                  <6 h16 colon> <ls32>
                  |                             '::' <5 h16 colon> <ls32>
                  |                       <h16> '::' <4 h16 colon> <ls32>
                  |                             '::' <4 h16 colon> <ls32>
                  | <at most 1 h16 colon> <h16> '::' <3 h16 colon> <ls32>
                  |                             '::' <3 h16 colon> <ls32>
                  | <at most 2 h16 colon> <h16> '::' <2 h16 colon> <ls32>
                  |                             '::' <2 h16 colon> <ls32>
                  | <at most 3 h16 colon> <h16> '::' <1 h16 colon> <ls32>
                  |                             '::' <1 h16 colon> <ls32>
                  | <at most 4 h16 colon> <h16> '::'               <ls32>
                  |                             '::'               <ls32>
                  | <at most 5 h16 colon> <h16> '::'               <h16>
                  |                             '::'               <h16>
                  | <at most 6 h16 colon> <h16> '::'
                  |                             '::'

<h16>            ::= HEXDIG
                   | HEXDIG HEXDIG
                   | HEXDIG HEXDIG HEXDIG
                   | HEXDIG HEXDIG HEXDIG HEXDIG

<ls32>          ::= <h16> ':' <h16>
                  | <IPv4address>

IPv4address     ::= <dec octet> '.' <dec octet> '.' <dec octet> '.' <dec octet> action => MarpaX::RFC::RFC3986::_marpa_ipv4address

<dec octet>     ::=                      DIGIT # 0-9
                  |      [\x{31}-\x{39}] DIGIT # 10-99
                  | '1'            DIGIT DIGIT # 100-199
                  | '2'  [\x{30}-\x{34}] DIGIT # 200-249
                  | '25' [\x{30}-\x{35}]       # 250-255

<reg name unit> ::= <unreserved> | <pct encoded> | <sub delims>
<reg name>      ::= <reg name unit>*                                 action => MarpaX::RFC::RFC3986::_marpa_reg_name

<path>          ::= <path abempty>    # begins with "/" or is empty
                  | <path absolute>   # begins with "/" but not "//"
                  | <path noscheme>   # begins with a non-colon segment
                  | <path rootless>   # begins with a segment
                  | <path empty>      # zero character

<segment unit> ::= '/' <segment>
<segments>     ::= <segment unit>*
<path abempty>  ::= <segments>                                       action => MarpaX::RFC::RFC3986::_marpa_path

<path absolute> ::= '/' <segment nz> <segments>                      action => MarpaX::RFC::RFC3986::_marpa_path
                  | '/'                                              action => MarpaX::RFC::RFC3986::_marpa_path
<path noscheme> ::= <segment nz nc> <segments>                       action => MarpaX::RFC::RFC3986::_marpa_path
<path rootless> ::= <segment nz> <segments>                          action => MarpaX::RFC::RFC3986::_marpa_path
<path empty>    ::=                                                  action => MarpaX::RFC::RFC3986::_marpa_path

#
# All possible segments are here
#
<segment>       ::= <pchar>*
<segment nz>    ::= <pchar>+
<segment nz nc unit> ::= <unreserved> | <pct encoded> | <sub delims> | '@'
<segment nz nc> ::= <segment nz nc unit>+                            # non-zero-length segment without any colon ":"

<pchar>         ::= <unreserved> | <pct encoded> | <sub delims> | [:@]

<query unit>    ::= <pchar> | [/?]
<query>         ::= <query unit>*                                    action => MarpaX::RFC::RFC3986::_marpa_query

<fragment unit> ::= <pchar> | [/?]
<fragment>      ::= <fragment unit>*                                 action => MarpaX::RFC::RFC3986::_marpa_fragment

<pct encoded>   ::= '%' HEXDIG HEXDIG

<unreserved>    ::= ALPHA | DIGIT | [-._~]

<sub delims>    ::= [!$&'()*+,;=]

#
# These rules are informative: they are not productive
#
<reserved>      ::= <gen delims> | <sub delims>
<gen delims>    ::= [:/?#\[\]@]
#
# No perl meta-character, just to be sure
#
ALPHA         ::= [A-Za-z]
DIGIT         ::= [0-9]
HEXDIG        ::= [0-9A-Fa-f]
