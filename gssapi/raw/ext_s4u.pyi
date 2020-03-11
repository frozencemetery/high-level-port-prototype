from gssapi.raw.creds import Creds
from gssapi.raw.names import Name
from gssapi.raw.types import MechType
from gssapi.raw.oids import OID

from gssapi.raw.named_tuples import AcquireCredResult, AddCredResult

from typing import List, Optional

def acquire_cred_impersonate_name(impersonator_cred: Creds,
                                  name: Name, lifetime: Optional[int] = None,
                                  mechs: Optional[List[MechType]] = None,
                                  usage: str = "initiate") \
                                  -> AcquireCredResult: ...

def add_cred_impersonate_name(input_cred: Optional[Creds],
                              impersonator_cred: Creds, name: Name,
                              mech: OID, usage: str = "initiate",
                              init_lifetime: Optional[int] = None,
                              accept_lifetime: Optional[int] = None) \
                              -> AddCredResult: ...

