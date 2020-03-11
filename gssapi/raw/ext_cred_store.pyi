from gssapi.raw.names import Name
from gssapi.raw.creds import Creds
from gssapi.raw.oids import OID

from collections import namedtuple

from gssapi.raw.named_tuples import AddCredResult, AcquireCredResult
from gssapi.raw.named_tuples import StoreCredResult

from typing import Dict, List, Optional

CredStore = Optional[Dict[bytes, bytes]]

def acquire_cred_from(store: CredStore = None, name: Optional[Name] = None,
                      lifetime: Optional[int] = None,
                      mechs: Optional[List[OID]] = None,
                      usage: str = "both") -> AcquireCredResult: ...

def add_cred_from(store: CredStore, input_creds: Optional[Creds],
                  name: Name, mech: OID, usage: str = "both",
                  init_lifetime: Optional[int] = None,
                  accept_lifetime: Optional[int] = None) -> AcquireCredResult:
    ...

def store_cred_into(store: CredStore, creds: Creds, usage: str = "both",
                    mech: Optional[OID] = None, overwrite: bool = False,
                    set_default: bool = False) -> StoreCredResult: ...

