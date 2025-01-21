import fnmatch
import logging
import transaction


logger = logging.getLogger("fix_mtr_re")
logger.setLevel(logging.INFO)

sites = app.objectValues("Plone Site")  # type: ignore

for site in sites:
    logger.info("Checking site %r", site)
    registry = site.mimetypes_registry
    globs = registry.globs

    for glob in globs:
        compiled_pattern, mimetype = globs[glob]
        # Since 2009 the fnmatch.translate, in Python 2,
        # returned a string ending with `\Z(?ms)`
        # See https://github.com/python/cpython/commit/b98d6b2cbcba1344609a60c7c0fb9f595d19023b
        if compiled_pattern.pattern.endswith(r"\Z(?ms)"):
            logger.info("  ⚡ Re-registering glob %r (%r -> %r)", glob, compiled_pattern.pattern, fnmatch.translate(glob))
            registry.register_glob(glob, mimetype)
        else:
            logger.info("  ✅ Not touching glob %r (%r)", glob, compiled_pattern.pattern)

transaction.commit()
