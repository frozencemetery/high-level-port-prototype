GSSAPI="BASE"  # This ensures that a full module is generated by Cython

from gssapi.raw.cython_types cimport *
from gssapi.raw.cython_converters cimport c_get_mech_oid_set
from gssapi.raw.cython_converters cimport c_create_oid_set
from gssapi.raw.cython_converters cimport c_py_ttl_to_c, c_c_ttl_to_py
from gssapi.raw.names cimport Name
from gssapi.raw.oids cimport OID

from gssapi.raw.types import MechType, NameType
from gssapi.raw.misc import GSSError
from gssapi.raw.named_tuples import AcquireCredResult, AddCredResult
from gssapi.raw.named_tuples import InquireCredResult, InquireCredByMechResult


cdef extern from "gssapi.h":
    OM_uint32 gss_acquire_cred(OM_uint32 *min_stat,
                               const gss_name_t name,
                               OM_uint32 ttl,
                               const gss_OID_set mechs,
                               gss_cred_usage_t cred_usage,
                               gss_cred_id_t *creds,
                               gss_OID_set *actual_mechs,
                               OM_uint32 *actual_ttl) nogil

    OM_uint32 gss_release_cred(OM_uint32 *min_stat,
                               gss_cred_id_t *creds) nogil

    OM_uint32 gss_add_cred(OM_uint32 *min_stat,
                           const gss_cred_id_t base_creds,
                           const gss_name_t name,
                           const gss_OID mech,
                           gss_cred_usage_t cred_usage,
                           OM_uint32 initiator_ttl,
                           OM_uint32 acceptor_ttl,
                           gss_cred_id_t *output_creds,
                           gss_OID_set *actual_mechs,
                           OM_uint32 *actual_initiator_ttl,
                           OM_uint32 *actual_acceptor_ttl) nogil

    # NB(directxman12): this is called frequently, so don't release the GIL
    OM_uint32 gss_inquire_cred(OM_uint32 *min_stat,
                               const gss_cred_id_t creds,
                               gss_name_t *name,
                               OM_uint32 *ttl,
                               gss_cred_usage_t *cred_usage,
                               gss_OID_set *mechs) nogil

    OM_uint32 gss_inquire_cred_by_mech(OM_uint32 *min_stat,
                                       const gss_cred_id_t cred_handle,
                                       const gss_OID mech_type,
                                       gss_name_t *name,
                                       OM_uint32 *initiator_ttl,
                                       OM_uint32 *acceptor_ttl,
                                       gss_cred_usage_t *cred_usage) nogil


cdef class Creds:
    """
    GSSAPI Credentials
    """
    # defined in pxd
    # cdef gss_cred_id_t raw_creds

    def __cinit__(self, Creds cpy=None):
        if cpy is not None:
            self.raw_creds = cpy.raw_creds
            cpy.raw_creds = GSS_C_NO_CREDENTIAL
        else:
            self.raw_creds = GSS_C_NO_CREDENTIAL

    def __dealloc__(self):
        # essentially just releaseCred(self), but it is unsafe to call
        # methods
        cdef OM_uint32 maj_stat, min_stat
        if self.raw_creds is not GSS_C_NO_CREDENTIAL:
            maj_stat = gss_release_cred(&min_stat, &self.raw_creds)
            if maj_stat != GSS_S_COMPLETE:
                raise GSSError(maj_stat, min_stat)
            self.raw_creds = NULL


def acquire_cred(Name name, lifetime=None, mechs=None, usage='both'):
    """
    Get GSSAPI credentials for the given name and mechanisms.

    This method gets GSSAPI credentials corresponding to the given name
    and mechanims.  The desired TTL and usage for the the credential may also
    be specified.

    Args:
        name (Name): the name for which to acquire the credentials (or None
            for the "no name" functionality)
        lifetime (int): the lifetime for the credentials (or None for
            indefinite)
        mechs ([MechType]): the desired mechanisms for which the credentials
            should work, or None for the default set
        usage (str): the usage type for the credentials: may be
            'initiate', 'accept', or 'both'

    Returns:
        AcquireCredResult: the resulting credentials, the actual mechanisms
        with which they may be used, and their actual lifetime (or None for
        indefinite or not supported)

    Raises:
        GSSError
    """

    cdef gss_OID_set desired_mechs
    if mechs is not None:
        desired_mechs = c_get_mech_oid_set(mechs)
    else:
        desired_mechs = GSS_C_NO_OID_SET

    cdef OM_uint32 input_ttl = c_py_ttl_to_c(lifetime)

    cdef gss_name_t c_name
    if name is None:
        c_name = GSS_C_NO_NAME
    else:
        c_name = name.raw_name

    cdef gss_cred_usage_t c_usage
    if usage == 'initiate':
        c_usage = GSS_C_INITIATE
    elif usage == 'accept':
        c_usage = GSS_C_ACCEPT
    else:
        c_usage = GSS_C_BOTH

    cdef gss_cred_id_t creds
    cdef gss_OID_set actual_mechs
    cdef OM_uint32 actual_ttl

    cdef OM_uint32 maj_stat, min_stat

    with nogil:
        maj_stat = gss_acquire_cred(&min_stat, c_name, input_ttl,
                                    desired_mechs, c_usage, &creds,
                                    &actual_mechs, &actual_ttl)

    cdef OM_uint32 tmp_min_stat
    if mechs is not None:
        gss_release_oid_set(&tmp_min_stat, &desired_mechs)

    cdef Creds rc = Creds()
    if maj_stat == GSS_S_COMPLETE:
        rc.raw_creds = creds
        return AcquireCredResult(rc, c_create_oid_set(actual_mechs),
                                 c_c_ttl_to_py(actual_ttl))
    else:
        raise GSSError(maj_stat, min_stat)


def release_cred(Creds creds not None):
    """
    Release GSSAPI Credentials.

    This method releases GSSAPI credentials.

    Args:
        creds (Creds): the credentials in question

    Raises:
        GSSError
    """

    cdef OM_uint32 maj_stat, min_stat
    maj_stat = gss_release_cred(&min_stat, &creds.raw_creds)
    if maj_stat != GSS_S_COMPLETE:
        raise GSSError(maj_stat, min_stat)
    creds.raw_creds = NULL


def add_cred(Creds input_cred, Name name not None, OID mech not None,
             usage='initiate', initiator_lifetime=None,
             acceptor_lifetime=None):
    """Add a credential element to a credential.

    This method can be used to either compose two credentials (i.e., original
    and new credential), or to add a new element to an existing credential.

    Args:
        input_cred (Cred): the set of credentials to which to add the new
            credentials
        name (Name): name of principal to acquire a credential for
        mech (MechType): the desired security mechanism (required).
        usage (str): usage type for credentials.  Possible values:
            'initiate' (default), 'accept', 'both' (failsafe).
        initiator_lifetime (int): lifetime of credentials for use in initiating
            security contexts (None for indefinite)
        acceptor_lifetime (int): lifetime of credentials for use in accepting
            security contexts (None for indefinite)

    Returns:
        AddCredResult: the actual mechanisms with which the credentials may be
        used, the actual initiator TTL, and the actual acceptor TTL (None for
        either indefinite or not supported)

    Raises:
        GSSError

    """
    cdef gss_cred_usage_t c_usage
    if usage == 'initiate':
        c_usage = GSS_C_INITIATE
    elif usage == 'accept':
        c_usage = GSS_C_ACCEPT
    else:  # usage == 'both'
        c_usage = GSS_C_BOTH

    cdef gss_cred_id_t raw_input_cred
    if input_cred is not None:
        raw_input_cred = input_cred.raw_creds
    else:
        raw_input_cred = GSS_C_NO_CREDENTIAL

    cdef OM_uint32 input_initiator_ttl = c_py_ttl_to_c(initiator_lifetime)
    cdef OM_uint32 input_acceptor_ttl = c_py_ttl_to_c(acceptor_lifetime)

    cdef gss_cred_id_t output_creds
    cdef gss_OID_set actual_mechs
    cdef OM_uint32 actual_initiator_ttl, actual_acceptor_ttl

    cdef OM_uint32 maj_stat, min_stat

    with nogil:
        maj_stat = gss_add_cred(&min_stat, raw_input_cred, name.raw_name,
                                &mech.raw_oid, c_usage, input_initiator_ttl,
                                input_acceptor_ttl, &output_creds,
                                &actual_mechs, &actual_initiator_ttl,
                                &actual_acceptor_ttl)

    cdef Creds rc
    if maj_stat == GSS_S_COMPLETE:
        rc = Creds()
        rc.raw_creds = output_creds
        return AddCredResult(rc, c_create_oid_set(actual_mechs),
                             c_c_ttl_to_py(actual_initiator_ttl),
                             c_c_ttl_to_py(actual_acceptor_ttl))
    else:
        raise GSSError(maj_stat, min_stat)


def inquire_cred(Creds creds not None, name=True, lifetime=True, usage=True,
                 mechs=True):
    """Inspect credentials for information

    This method inspects a :class:`Creds` object for information.

    Args:
        creds (Creds): the credentials to inspect
        name (bool): get the Name associated with the credentials
        lifetime (bool): get the TTL for the credentials
        usage (bool): get the usage type of the credentials
        mechs (bool): the mechanims used with the credentials

    Returns:
        InquireCredResult: the information about the credentials,
            with unused fields set to None

    Raises:
        GSSError
    """

    # TODO(directxman12): add docs
    cdef gss_name_t res_name
    cdef gss_name_t *res_name_ptr = NULL
    if name:
        res_name_ptr = &res_name

    cdef OM_uint32 res_ttl
    cdef OM_uint32 *res_ttl_ptr = NULL
    if lifetime:
        res_ttl_ptr = &res_ttl

    cdef gss_cred_usage_t res_usage
    cdef gss_cred_usage_t *res_usage_ptr = NULL
    if usage:
        res_usage_ptr = &res_usage

    cdef gss_OID_set res_mechs
    cdef gss_OID_set *res_mechs_ptr = NULL
    if mechs:
        res_mechs_ptr = &res_mechs

    cdef OM_uint32 maj_stat, min_stat
    maj_stat = gss_inquire_cred(&min_stat, creds.raw_creds, res_name_ptr,
                                res_ttl_ptr, res_usage_ptr, res_mechs_ptr)

    cdef Name rn
    if maj_stat == GSS_S_COMPLETE:
        if name:
            rn = Name()
            rn.raw_name = res_name
        else:
            rn = None

        py_usage = None
        if usage:
            if res_usage == GSS_C_INITIATE:
                py_usage = 'initiate'
            elif res_usage == GSS_C_ACCEPT:
                py_usage = 'accept'
            elif res_usage == GSS_C_BOTH:
                py_usage = 'both'

        py_ttl = None
        if lifetime:
            py_ttl = c_c_ttl_to_py(res_ttl)

        py_mechs = None
        if mechs:
            py_mechs = c_create_oid_set(res_mechs)

        return InquireCredResult(rn, py_ttl, py_usage, py_mechs)
    else:
        raise GSSError(maj_stat, min_stat)


def inquire_cred_by_mech(Creds creds not None, OID mech not None,
                         name=True, initiator_lifetime=True,
                         acceptor_lifetime=True, usage=True):
    """Inspect credentials for mechanism-specific

    This method inspects a :class:`Creds` object for information
    specific to a particular mechanism.

    Args:
        creds (Creds): the credentials to inspect
        mech (OID): the desired mechanism
        name (bool): get the Name associated with the credentials
        initiator_lifetime (bool): get the initiator TTL for the credentials
        acceptor_lifetime (bool): get the acceptor TTL for the credentials
        usage (bool): get the usage type of the credentials

    Returns:
        InquireCredByMechResult: the information about the credentials,
            with unused fields set to None

    Raises:
        GSSError
    """

    # TODO(directxman12): add docs
    cdef gss_name_t res_name
    cdef gss_name_t *res_name_ptr = NULL
    if name:
        res_name_ptr = &res_name

    cdef OM_uint32 res_initiator_ttl
    cdef OM_uint32 *res_initiator_ttl_ptr = NULL
    if initiator_lifetime:
        res_initiator_ttl_ptr = &res_initiator_ttl

    cdef OM_uint32 res_acceptor_ttl
    cdef OM_uint32 *res_acceptor_ttl_ptr = NULL
    if acceptor_lifetime:
        res_acceptor_ttl_ptr = &res_acceptor_ttl

    cdef gss_cred_usage_t res_usage
    cdef gss_cred_usage_t *res_usage_ptr = NULL
    if usage:
        res_usage_ptr = &res_usage

    cdef OM_uint32 maj_stat, min_stat
    maj_stat = gss_inquire_cred_by_mech(&min_stat, creds.raw_creds,
                                        &mech.raw_oid, res_name_ptr,
                                        res_initiator_ttl_ptr,
                                        res_acceptor_ttl_ptr, res_usage_ptr)
    cdef Name rn
    if maj_stat == GSS_S_COMPLETE:
        if name:
            rn = Name()
            rn.raw_name = res_name
        else:
            rn = None

        py_initiator_ttl = None
        if initiator_lifetime:
            py_initiator_ttl = c_c_ttl_to_py(res_initiator_ttl)

        py_acceptor_ttl = None
        if acceptor_lifetime:
            py_acceptor_ttl = c_c_ttl_to_py(res_acceptor_ttl)

        py_usage = None
        if usage:
            if res_usage == GSS_C_INITIATE:
                py_usage = 'initiate'
            elif res_usage == GSS_C_ACCEPT:
                py_usage = 'accept'
            elif res_usage == GSS_C_BOTH:
                py_usage = 'both'

        return InquireCredByMechResult(rn, py_initiator_ttl,
                                       py_acceptor_ttl, py_usage)
    else:
        raise GSSError(maj_stat, min_stat)
