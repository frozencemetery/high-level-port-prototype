from gssapi.raw.names import Name
from gssapi.raw.oids import OID
from gssapi.raw.named_tuples import AcquireCredResult, AddCredResult
from gssapi.raw.named_tuples import InquireCredResult, InquireCredByMechResult

from typing import Any, Iterable, Optional

class Creds:
    def __init__(self, cpy: Optional[Creds] = None) -> None: ...

    # mypy needs this, but we don't define it...
    def __new__(self, cpy: Optional[Creds] = None) -> "Creds": ...

    ...

def acquire_cred(name: Optional[Name] = None, lifetime: Optional[int] = None,
                 mechs: Optional[Iterable[OID]] = None,
                 usage: str = "both") -> AcquireCredResult: ...

def release_cred(creds: Creds) -> None: ...

# mutate_input doesn't 
def add_cred(input_cred: Creds, name: Name, mech: OID,
             usage: str = "initiate", init_lifetime: Optional[int] = None,
             accept_lifetime: Optional[int] = None,
             mutate_input: bool = False) -> AddCredResult: ...

def inquire_cred(creds: Creds, name: bool = True, lifetime: bool = True,
                 usage: bool = True, mechs: bool = True) -> InquireCredResult:
    ...

def inquire_cred_by_mech(creds: Creds, mech: OID, name: bool = True,
                         init_lifetime: bool = True,
                         accept_lifetime: bool = True,
                         usage: bool = True) -> InquireCredByMechResult: ...

