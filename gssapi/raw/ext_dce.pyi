from gssapi.raw.sec_contexts import SecurityContext
from gssapi.raw.named_tuples import IOVUnwrapResult, WrapResult, UnwrapResult
from collections import namedtuple
from enum import IntEnum
from gssapi.raw._enum_extensions import ExtendableEnum
from collections.abc import Sequence

from typing import Optional

class IOVBufferType(IntEnum, metaclass=ExtendableEnum): ...

class IOV: ...

def wrap_iov(context: SecurityContext, message: IOV,
             confidential: bool = True,
             qop: Optional[int] = None) -> bool: ...

def unwrap_iov(context: SecurityContext, message: IOV) -> IOVUnwrapResult: ...

def wrap_iov_length(context: SecurityContext, message: IOV,
                    confidential: bool = True,
                    qop: Optional[int] = None) -> WrapResult: ...

def wrap_aead(context: SecurityContext, message: bytes,
              associated: Optional[bytes] = None, confidential: bool = True,
              qop: Optional[int] = None) -> WrapResult: ...

def unwrap_aead(context: SecurityContext, message: bytes,
                associated: Optional[bytes] = None) -> UnwrapResult: ...

