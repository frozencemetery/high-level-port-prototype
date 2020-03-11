from enum import EnumMeta

from typing import Any, Dict, Tuple

_extra_values: Dict[str, Dict[str, Any]] = {}


def register_value(cl_str: str, name: str, value: Any) -> None:
    _extra_values[cl_str] = _extra_values.get(cl_str, {})
    _extra_values[cl_str][name] = value


class ExtendableEnum(EnumMeta):
    def __new__(metacl, name: str, bases: Tuple[type, ...],
                classdict: Dict[str, Any]) -> Any:
        extra_vals = _extra_values.get(name)

        if extra_vals is not None:
            for extra_name, extra_val in list(extra_vals.items()):
                if extra_name in classdict:
                    raise AttributeError(
                        "Enumeration extensions cannot override existing "
                        "enumeration members")
                else:
                    classdict[extra_name] = extra_val

        return super(ExtendableEnum, metacl).__new__(metacl, name,
                                                     bases, classdict)
