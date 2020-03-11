from gssapi.raw.sec_contexts import SecurityContext
from gssapi.raw.named_tuples import WrapResult, UnwrapResult

from typing import Optional

def get_mic(context: SecurityContext, message: bytes,
            qop: Optional[int] = None) -> bytes: ...

def verify_mic(context: SecurityContext, message: bytes,
               token: bytes) -> int: ...

def wrap_size_limit(context: SecurityContext, output_size: int,
                    confidential: bool = True,
                    qop: Optional[int] = None) -> int: ...

def wrap(context: SecurityContext, message: bytes, confidential: bool = True,
         qop: Optional[int] = None) -> WrapResult: ...

def unwrap(context: SecurityContext, message: bytes) -> UnwrapResult: ...

