from gssapi.raw.creds import Creds
from gssapi.raw.names import Name
from gssapi.raw.oids import OID
from gssapi.raw.named_tuples import AcquireCredResult, AddCredResult

def export_cred(creds: Creds) -> bytes: ...

def import_cred(token: bytes) -> Creds: ...
