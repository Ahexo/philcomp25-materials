import re
from urllib.parse import unquote
import unicodedata

URL_PATTERN = r"^(.*)(\.com\/(in\/)?)(.+?)(\/)?(\?.+)?$"


def fullname(unistr: str) -> str:
    '''
    Turns full names into a normalized form used as ID.
    i.e. Alejandro Martínez Argüello turns into alejando_martinez_arguello

    Args:
        unistr: String to normalize.
    Returns:
        str: Normalized name.
    '''
    # First, we remove las spaces and set lowercase
    unistr = unistr.rstrip().lower()
    # Replace undesired characters
    unistr = unistr.replace(".", "").replace(" ", "_").replace("-", "_")
    normalized_str = unicodedata.normalize('NFKD', unistr)
    ascii_str = normalized_str.encode("ascii", "ignore").decode("utf-8")
    return ascii_str

def user(url: str) -> str:
    '''
    Extracts the username from a social url.
    Args:
        url: URL to filter.
    Returns:
        str: username.
    '''
    if isinstance(url, str):
        decoded = unquote(url)
        match = re.match(URL_PATTERN, decoded)
        return match.group(4)
    else:
        return ""
