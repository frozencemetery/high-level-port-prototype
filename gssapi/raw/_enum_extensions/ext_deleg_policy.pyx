from gssapi.raw.cython_types cimport OM_uint32

from gssapi.raw import _enum_extensions as ext_registry


cdef extern from "python_gssapi.h":
    OM_uint32 GSS_C_DELEG_POLICY_FLAG

ext_registry.register_value('RequirementFlag', 'deleg_policy',
                            GSS_C_DELEG_POLICY_FLAG)
