from gssapi.raw.creds import Creds
from gssapi.raw.oids import OID

from typing import Iterable

def set_neg_mechs(cred_handle: Creds, mech_set: Iterable[OID]) -> None: ...
