from gssapi.raw.sec_contexts import SecurityContext
from gssapi.raw.ext_dce import IOV, IOVBufferType

from typing import Optional

def get_mic_iov(context: SecurityContext, message: IOV,
                qop: Optional[int] = None) -> None: ...

def get_mic_iov_length(context: SecurityContext, message: IOV,
                       qop: Optional[int] = None) -> None: ...

def verify_mic_iov(context: SecurityContext, message: IOV,
                   qop: Optional[int] = None) -> None: ...
