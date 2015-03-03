from gssapi._utils import import_gssapi_extension
import os.path

try:
    import commands
    get_output = commands.getoutput
except ImportError:
    import subprocess

    def _get_output(*args, **kwargs):
        res = subprocess.check_output(*args, shell=True, **kwargs)
        decoded = res.decode('utf-8')
        return decoded.strip()

    get_output = _get_output


def _extension_test(extension_name, extension_text):
    def make_ext_test(func):
        def ext_test(self, *args, **kwargs):
            if import_gssapi_extension(extension_name) is None:
                self.skipTest("The %s GSSAPI extension is not supported by "
                              "your GSSAPI implementation" % extension_text)
            else:
                func(self, *args, **kwargs)

        return ext_test

    return make_ext_test


_KRB_VERSION = None


def _minversion_test(target_version, problem):
    global _KRB_VERSION
    if _KRB_VERSION is None:
        _KRB_VERSION = get_output("krb5-config --version")
        _KRB_VERSION = _KRB_VERSION.split(' ')[-1].split('.')

    def make_ext_test(func):
        def ext_test(self, *args, **kwargs):
            if _KRB_VERSION < target_version.split('.'):
                self.skipTest("Your GSSAPI (version %s) is known to have "
                              "problems with %s" % (_KRB_VERSION, problem))
            else:
                func(self, *args, **kwargs)
        return ext_test

    return make_ext_test


_KRB_PREFIX = None


def _requires_krb_plugin(plugin_type, plugin_name):
    global _KRB_PREFIX
    if _KRB_PREFIX is None:
        _KRB_PREFIX = get_output("krb5-config --prefix")

    plugin_path = os.path.join(_KRB_PREFIX, 'lib/krb5/plugins',
                               plugin_type, '%s.so' % plugin_name)

    def make_krb_plugin_test(func):
        def krb_plugin_test(self, *args, **kwargs):
            if not os.path.exists(plugin_path):
                self.skipTest("You do not have the GSSAPI {type}"
                              "plugin {name} installed".format(
                                  type=plugin_type, name=plugin_name))
            else:
                func(self, *args, **kwargs)

        return krb_plugin_test

    return make_krb_plugin_test
