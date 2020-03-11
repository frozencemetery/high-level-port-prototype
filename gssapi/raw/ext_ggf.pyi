from gssapi.raw.oids import OID
from gssapi.raw.creds import Creds
from gssapi.raw.sec_contexts import SecurityContext

from typing import List, Optional

def inquire_cred_by_oid(cred_handle: Creds,
                        desired_aspect: OID) -> List[bytes]: ...

def inquire_sec_context_by_oid(context: SecurityContext,
                               desired_aspect: OID) -> List[bytes]: ...

def set_sec_context_option(desired_aspect: OID,
                           context: Optional[SecurityContext] = None,
                           value: Optional[bytes] = None) -> SecurityContext:
    ...

