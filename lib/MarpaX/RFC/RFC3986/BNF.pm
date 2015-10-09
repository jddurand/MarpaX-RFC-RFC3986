package MarpaX::RFC::RFC3986::BNF;
use Data::Section -setup;

# ABSTRACT: Uniform Resource Identifier (URI): Generic Syntax - Marpa BNF

# VERSION

# AUTHORITY

1;

__DATA__
__[ BNF ]__
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
