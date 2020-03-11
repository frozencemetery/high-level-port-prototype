from typing import Iterable, List, Optional, Union

class OID:
    def __init__(self, cpy: Optional[OID] = None,
                 elements: Optional[bytes] = None) -> None:
        ...

    # mypy is not smart enough to infer this
    def __new__(self, cpy: Optional[OID] = None,
                elements: Optional[bytes] = None) -> "OID":
        ...

    def __bytes__(self) -> bytes: ...

    @classmethod
    def from_int_seq(cls, integer_sequence: Union[Iterable[Union[int, str, bytes]], str]) -> OID:
        ...

    @property
    def dotted_form(self) -> str: ...
