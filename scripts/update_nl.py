""" This script updates the nl files basded on the translations available for nl_BE
"""
import os
import polib

i18n_euphorie = 'src/Euphorie/src/euphorie/deployment/locales'

# in i18n_euphorie directory are language subdirectiories, each containing a LC_MESSAGES directory
# Access the BE_nl directory and enter the LC_MESSAGES directory within.
# Open each po file using polib. Also open the corresponding po file from the directory for nl.
# Then update the nl po file with all entries from the nl_BE po file, which do not exist in the nl file.
for file in os.listdir(f'{i18n_euphorie}/nl_BE/LC_MESSAGES'):
    if file.endswith('.po'):
        update_counter = 0
        po = polib.pofile(f'{i18n_euphorie}/nl_BE/LC_MESSAGES/{file}')
        po_dict = {entry.msgid: entry.msgstr for entry in po}
        nl_po = polib.pofile(f'{i18n_euphorie}/nl/LC_MESSAGES/{file}')
        for entry in nl_po.untranslated_entries():
            if entry.msgid in po_dict:
                entry.msgstr = po_dict[entry.msgid]
                update_counter += 1
        nl_po.save(f'{i18n_euphorie}/nl/LC_MESSAGES/{file}')
        print(f'Updated {update_counter} entries in nl {file}')
