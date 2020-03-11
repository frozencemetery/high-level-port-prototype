from gssapi.raw.creds import Creds
from gssapi.raw.oids import OID
from gssapi.raw.names import Name
from gssapi.raw.named_tuples import AcquireCredResult

from typing import List, Optional

def acquire_cred_with_password(name: Name, password: bytes,
                               lifetime: Optional[int] = None,
                               mechs: Optional[List[OID]] = None,
                               usage: str = "initiate") -> AcquireCredResult:
    ...
