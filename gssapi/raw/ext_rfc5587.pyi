from gssapi.raw.oids import OID
from gssapi.raw.named_tuples import InquireAttrsResult, DisplayAttrResult

from typing import Iterable, List, Optional

MAs = Iterable[OID]

def indicate_mechs_by_attrs(desired_mech_attrs: Optional[MAs] = None,
                            except_mech_attrs: Optional[MAs] = None,
                            critical_mech_attrs: Optional[MAs] = None) \
                            -> List[OID]: ...

def inquire_attrs_for_mech(mech: OID) -> InquireAttrsResult: ...

def display_mech_attr(attr: OID) -> DisplayAttrResult: ...
