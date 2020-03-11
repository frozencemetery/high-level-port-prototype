from gssapi.raw.names import Name
from gssapi.raw.oids import OID
from gssapi.raw.named_tuples import InquireNameResult, GetNameAttributeResult

from typing import List, Optional

def display_name_ext(name: Name, name_type: OID) -> bytes: ...

def inquire_name(name: Name, mech_name: bool = True,
                 attrs: bool = True) -> InquireNameResult: ...

def set_name_attribute(name: Name, attr: bytes, value: List[bytes],
                       complete: bool = False) -> None: ...

def get_name_attribute(name: Name, attr: bytes,
                       more: Optional[int] = None) -> GetNameAttributeResult:
    ...

def delete_name_attribute(name: Name, attr: bytes) -> None: ...

def export_name_composite(name: Name) -> bytes: ...
