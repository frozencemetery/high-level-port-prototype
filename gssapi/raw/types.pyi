from collections.abc import MutableSet
from enum import IntEnum

from gssapi.raw._enum_extensions import ExtendableEnum
from gssapi.raw.oids import OID

from typing import Iterator, Optional, Union

class NameType(object):
    hostbased_service: OID
    user: OID
    anonymous: OID
    machine_uid: OID
    string_uid: OID
    export: OID

    # populated by mech_krb5
    kerberos_principal: OID

    # populated by ext_rfc6680
    composite_export: OID

    ...

class RequirementFlag(IntEnum, metaclass=ExtendableEnum):
    delegate_to_peer: int
    mutual_authentication: int
    replay_detection: int
    out_of_sequence_detection: int
    confidentiality: int
    integrity: int
    anonymity: int
    protection_ready: int
    transferable: int
    ...

class AddressType(IntEnum, metaclass=ExtendableEnum): ...

class MechType(object):
    # populated by mech_krb5
    kerberos: OID

    ...

class GenericFlagSet(MutableSet[int]):
    def __contains__(self, flag: object) -> bool: ...
    def __iter__(self) -> Iterator[int]: ...
    def __len__(self) -> int: ...
    def add(self, flag: int) -> None: ...
    def discard(self, flag: int) -> None: ...
    ...

Flags = Union[GenericFlagSet, int]
class IntEnumFlagSet(GenericFlagSet):
    def __init__(self, enum: type,
                 flags: Optional[Flags] = None) -> None: ...

    # mypy can't infer this
    def __new__(self, enum: type,
                flags: Optional[Flags] = None) -> IntEnumFlagSet:
        ...

    ...
