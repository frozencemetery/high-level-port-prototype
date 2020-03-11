from typing import NamedTuple

from gssapi.raw.creds import Creds
from gssapi.raw.names import Name
from gssapi.raw.sec_contexts import SecurityContext
from gssapi.raw.oids import OID

from typing import Iterable, List, Optional, Set

class AcquireCredResult(NamedTuple):
    creds: "Creds"
    mechs: Set[OID]
    lifetime: int


class InquireCredResult(NamedTuple):
    name: Name
    lifetime: int
    usage: str
    mechs: Optional[Set[OID]]


class InquireCredByMechResult(NamedTuple):
    name: Name
    init_lifetime: int
    accept_lifetime: int
    usage: str


class AddCredResult(NamedTuple):
    creds: Creds
    mechs: Set[OID]
    init_lifetime: int
    accept_lifetime: int


class DisplayNameResult(NamedTuple):
    name: bytes
    name_type: Optional[OID]


class WrapResult(NamedTuple):
    message: bytes
    encrypted: bool


class UnwrapResult(NamedTuple):
    message: bytes
    encrypted: bool
    qop: int


class AcceptSecContextResult(NamedTuple):
    context: SecurityContext
    initiator_name: Name
    mech: OID
    token: Optional[bytes]
    flags: int # wrong
    lifetime: int
    delegated_creds: Optional[Creds]
    more_steps: bool


class InitSecContextResult(NamedTuple):
    context: SecurityContext
    mech: OID
    flags: int # wrong
    token: Optional[bytes]
    lifetime: int
    more_steps: bool


class InquireContextResult(NamedTuple):
    initiator_name: Optional[Name]
    target_name: Optional[Name]
    lifetime: int
    mech: OID
    flags: int
    locally_init: bool
    complete: bool


class StoreCredResult(NamedTuple):
    mechs: List[OID]
    usage: str


class IOVUnwrapResult(NamedTuple):
    encrypted: bool
    qop: int


class InquireNameResult(NamedTuple):
    attrs: List[bytes]
    is_mech_name: bool
    mech: OID


class GetNameAttributeResult(NamedTuple):
    values: Iterable[bytes]
    display_values: Iterable[bytes]
    authenticated: bool
    complete: bool


class InquireAttrsResult(NamedTuple):
    mech_attrs: Set[OID]
    known_mech_attrs: Set[OID]


class DisplayAttrResult(NamedTuple):
    name: Name
    short_desc: str
    long_desc: str


class InquireSASLNameResult(NamedTuple):
    sasl_mech_name: bytes
    mech_name: bytes
    mech_description: bytes
