from gssapi.raw.names import Name
from gssapi.raw.creds import Creds
from gssapi.raw.oids import OID
from gssapi.raw.named_tuples import StoreCredResult

from typing import Optional

def store_cred(creds: Creds, usage: str = "both", mech: Optional[OID] = None,
               overwrite: bool = False,
               set_default: bool = False) -> StoreCredResult: ...

