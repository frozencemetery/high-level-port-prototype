from gssapi.raw.creds import Creds
from gssapi.raw.names import Name
from gssapi.raw.oids import OID
from gssapi.raw.chan_bindings import ChannelBindings

from gssapi.raw.types import MechType, RequirementFlag, IntEnumFlagSet
from gssapi.raw.misc import GSSError
from gssapi.raw.named_tuples import AcceptSecContextResult
from gssapi.raw.named_tuples import InitSecContextResult
from gssapi.raw.named_tuples import InquireContextResult

from typing import Optional, Union

Flags = Union[IntEnumFlagSet, RequirementFlag]

class SecurityContext:
    # stuff for @catch_and_return_token for step()
    __DEFER_STEP_ERRORS__: bool
    _last_err: Optional[GSSError]

    def __init__(self, cpy: Optional[SecurityContext] = None) -> None: ...

    # mypy can't infer this
    def __new__(self,
                cpy: Optional[SecurityContext] = None) -> SecurityContext:
        ...

    @property
    def _started(self) -> bool: ...

    ...

def init_sec_context(target_name: Name, creds: Optional[Creds] = None,
                     context: Optional[SecurityContext] = None,
                     mech: Optional[OID] = None,
                     flags: Optional[Flags] = None,
                     lifetime: Optional[int] = None,
                     channel_bindings: Optional[ChannelBindings] = None,
                     input_token: Optional[bytes] = None) \
                     -> InitSecContextResult: ...

def accept_sec_context(input_token: bytes,
                       acceptor_creds: Optional[Creds] = None,
                       context: Optional[SecurityContext] = None,
                       channel_bindings: Optional[ChannelBindings] = None) \
                       -> AcceptSecContextResult: ...

def inquire_context(context: SecurityContext, initiator_name: bool = True,
                    target_name: bool = True, lifetime: bool = True,
                    mech: bool = True, flags: bool = True,
                    locally_init: bool = True,
                    complete: bool = True) -> InquireContextResult: ...

def context_time(context: SecurityContext) -> int: ...

# deprecated by RFC 2744 - don't use
def process_context_token(context: SecurityContext, token: bytes) -> None: ...

def import_sec_context(token: bytes) -> SecurityContext: ...

def export_sec_context(context: SecurityContext) -> bytes: ...

