GSSAPI="BASE"  # This ensures that a full module is generated by Cython

import locale  # for decoding error messages

import six

from gssapi.raw.cython_types cimport *
from gssapi.raw.cython_converters cimport c_create_mech_list
from gssapi.raw.oids cimport OID

from gssapi.raw.types import MechType


cdef extern from "gssapi.h":
    OM_uint32 gss_display_status(OM_uint32 *minor_status,
                                 OM_uint32 status_value,
                                 int status_type,
                                 const gss_OID mech_type,
                                 OM_uint32 *message_context,
                                 gss_buffer_t status_string)

    OM_uint32 gss_indicate_mechs(OM_uint32 *minor_status,
                                 gss_OID_set *mech_set)


def indicate_mechs():
    """
    Get the currently supported mechanisms.

    This method retrieves the currently supported GSSAPI mechanisms.
    Note that if unknown mechanims are found, those will be skipped.
    """

    cdef gss_OID_set mech_set

    cdef OM_uint32 maj_stat, min_stat

    maj_stat = gss_indicate_mechs(&min_stat, &mech_set)

    if maj_stat == GSS_S_COMPLETE:
        return c_create_mech_list(mech_set)
    else:
        raise GSSError(maj_stat, min_stat)


def _display_status(unsigned int error_code, bint is_major_code,
                    OID mech_type=None, unsigned int message_context=0):
    """
    Display a string message for a GSSAPI error code.

    This method displays a message for a corresponding GSSAPI error code.
    Since some error codes might have multiple messages, a context parameter
    may be passed to indicate where in the series of messages we currently are
    (this is the second item in the return value tuple).  Additionally, the
    third item in the return value tuple indicates whether or not more
    messages are available.

    Args:
        error_code (int): The error code in question
        is_major_code (bool): is this a major code (True) or a
            minor code (False)
        mech_type (MechType): The mechanism type that returned this error code
            (defaults to None, for the default mechanism)
        message_context (int): The context for this call -- this is used when
            multiple messages are available (defaults to 0)

    Returns:
        (bytes, int, bool): the message, the new message context, and
            whether or not to call again for further messages

    Raises:
       GSSError
    """

    cdef int status_type
    cdef gss_OID c_mech_type

    if is_major_code:
        status_type = GSS_C_GSS_CODE
    else:
        status_type = GSS_C_MECH_CODE

    if mech_type is None:
        c_mech_type = GSS_C_NO_OID
    else:
        c_mech_type = &mech_type.raw_oid

    cdef OM_uint32 maj_stat
    cdef OM_uint32 min_stat
    cdef OM_uint32 msg_ctx_out = message_context
    cdef gss_buffer_desc msg_buff

    maj_stat = gss_display_status(&min_stat, error_code, status_type,
                                  c_mech_type, &msg_ctx_out, &msg_buff)

    if maj_stat == GSS_S_COMPLETE:
        call_again = bool(msg_ctx_out)

        msg_out = msg_buff.value[:msg_buff.length]
        gss_release_buffer(&min_stat, &msg_buff)
        return (msg_out, msg_ctx_out, call_again)
    else:
        # NB(directxman12): this is highly unlikely to cause a recursive loop
        raise GSSError(maj_stat, min_stat)


class GSSErrorRegistry(type):
    __registry = {}

    def __init__(cls, name, bases, attributes):
        calling_code = getattr(cls, 'CALLING_CODE', None)
        routine_code = getattr(cls, 'ROUTINE_CODE', None)
        supplementary_code = getattr(cls, 'SUPPLEMENTARY_CODE', None)

        # NB(directxman12): we ignore minor code since it's mech-specific

        if any([calling_code, routine_code, supplementary_code]):
            if calling_code not in cls.__registry:
                cls.__registry[calling_code] = {}

            call_reg = cls.__registry[calling_code]

            if routine_code not in call_reg:
                call_reg[routine_code] = {}

            routine_reg = call_reg[routine_code]

            routine_reg[supplementary_code] = cls

    @staticmethod
    def __get_registry(code, parent_reg):
        return parent_reg.get(code, parent_reg.get(None, {}))

    def __find_error(cls, maj_code):
        codes = cls._parse_major_code(maj_code)
        calling_code, routine_code, suppl_code = codes

        call_reg = cls.__get_registry(calling_code, cls.__registry)
        routine_reg = cls.__get_registry(routine_code, call_reg)

        return routine_reg.get(suppl_code, routine_reg.get(None, None))

    def __call__(cls, maj_code, min_code, *args, **kwargs):
        new_cls = cls.__find_error(maj_code) or cls

        return super(GSSErrorRegistry, new_cls).__call__(maj_code, min_code,
                                                         *args, **kwargs)


# NB(directxman12): this needs to be here (and not in another file)
#                   so that display_status can use it
@six.add_metaclass(GSSErrorRegistry)
class GSSError(Exception):
    """
    GSSAPI Error

    This Exception represents an error returned from the GSSAPI
    C bindings.  It contains the major and minor status codes
    returned by the method which caused the error, and can
    generate human-readable string messages from the error
    codes
    """

    MESSAGE = u"Major ({maj_stat}): {maj_str}, Minor ({min_stat}): {min_str}"

    @classmethod
    def _parse_major_code(cls, maj_code):
        # major status codes consist of
        # calling error | routine error | supplementary info
        # in non-overlapping bits

        calling_code = GSS_CALLING_ERROR(maj_code) or None
        routine_code = GSS_ROUTINE_ERROR(maj_code) or None
        supplementary_code = GSS_SUPPLEMENTARY_INFO(maj_code) or None

        return (calling_code, routine_code, supplementary_code)

    def __init__(self, maj_code, min_code, token=None):
        """
        Create a new GSSError.

        This method creates a new GSSError,
        retrieves the releated human-readable
        string messages, and uses the results to construct an
        exception message

        Args:
            maj_code (int): the major code associated with this error
            min_code (int): the minor code associated with this error
            token (bytes): an error token associated with the error
        """

        self.maj_code = maj_code
        self.min_code = min_code

        self.token = token

        split_codes = self._parse_major_code(maj_code)
        self.calling_code = split_codes[0]
        self.routine_code = split_codes[1]
        self.supplementary_code = split_codes[2]

        super(GSSError, self).__init__(self.gen_message())

    def get_all_statuses(self, code, is_maj):
        """
        Retrieve all messages for a status code.

        This method retrieves all human-readable messages
        available for the given status code.

        Args:
            code (int): the status code in question
            is_maj (bool): whether this is a major status code (True)
                or minor status code (False)

        Returns:
            [bytes]: A list of string messages associated with the
                given code
        """

        msg_encoding = locale.getlocale(locale.LC_MESSAGES)[0] or 'UTF-8'

        res = []
        try:
            msg, ctx, cont = _display_status(code, is_maj)
            res.append(msg.decode(msg_encoding))
        except GSSError:
            res.append(u'issue decoding code: {0}'.format(code))
            cont = False

        while cont:
            try:
                msg, ctx, cont = _display_status(code, is_maj,
                                                 message_context=ctx)
                res.append(msg.decode(msg_encoding))
            except GSSError:
                res.append(u'issue decoding '
                           u'code: {0}'.format(code))
                cont = False

        return res

    def gen_message(self):
        """
        Retrieves all messages for this error's status codes

        This method retrieves all messages for this error's status codes,
        and forms them into a string for use as an exception message

        Returns:
            bytes: a string for use as this error's message
        """

        maj_statuses = self.get_all_statuses(self.maj_code, True)
        min_statuses = self.get_all_statuses(self.min_code, False)

        maj_str = u' -- '.join(maj_statuses)
        min_str = u' -- '.join(min_statuses)

        return self.MESSAGE.format(maj_stat=self.maj_code,
                                   maj_str=maj_str,
                                   min_stat=self.min_code,
                                   min_str=min_str)
