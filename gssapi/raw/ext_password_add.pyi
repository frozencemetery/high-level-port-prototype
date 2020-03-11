from gssapi.raw.creds import Creds
from gssapi.raw.names import Name
from gssapi.raw.oids import OID
from gssapi.raw.named_tuples import AddCredResult

from typing import Optional

def add_cred_with_password(input_cred: Creds, name: Name, mech: OID,
                           password: bytes, usage: str = "initiate",
                           init_lifetime: Optional[int] = None,
                           accept_lifetime: Optional[int] = None) \
                           -> AddCredResult: ...
