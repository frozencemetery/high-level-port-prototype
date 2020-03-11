from gssapi.raw.names import Name
from gssapi.raw.oids import OID
from gssapi.raw.types import MechType

from typing import List, Optional, Set, Tuple

def indicate_mechs() -> Set[OID]: ...

def inquire_names_for_mech(mech: OID) -> List[OID]: ...

def inquire_mechs_for_name(name: Name) -> List[OID]: ...

def indicate_names_for_mech(mech: OID) -> Set[OID]: ...

def _display_status(error_code: int, is_major_code: bool,
                    mech: Optional[OID] = None,
                    message_context: Optional[int] = 0) \
                    -> Tuple[bytes, int, bool]: ...

class GSSErrorRegistry(type): ...

class GSSError(Exception, metaclass=GSSErrorRegistry):
    token: Optional[bytes]
    maj_code: int
    min_code: int

    CALLING_CODE: Optional[int]
    ROUTINE_CODE: Optional[int]
    SUPPLEMENTARY_CODE: Optional[int]


    def __init__(self, maj_code: int, min_code: int,
                 token: Optional[bytes] = None) -> None: ...

    # mypy can't figure this out
    def __new__(self, maj_code: int, min_code: int,
                token: Optional[bytes] = None) -> GSSError: ...

    def get_all_statuses(self, code: int, is_maj: bool) -> str: ...

    def gen_message(self) -> bytes: ...
