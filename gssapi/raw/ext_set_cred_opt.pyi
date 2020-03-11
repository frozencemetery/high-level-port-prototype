from gssapi.raw.oids import OID
from gssapi.raw.creds import Creds

from typing import Optional

def set_cred_option(desired_aspect: OID, creds: Optional[Creds] = None,
                    value: Optional[bytes] = None) -> Creds: ...
