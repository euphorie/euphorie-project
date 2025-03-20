""" This script pulls the latest translations from prototype po files and updates the translations in the Euphorie package whenever there is a matching message_id.
The script assumes
- Euphorie and plonestatic.euphorie to be checked out in the src directory.
- prototype to be recently updated so that the po files there are up to date.
- that it gets called from within the buildout directory.
"""
import os
import polib

i18n_proto = 'src/plonestatic.euphorie/var/prototype/_site/assets/oira/i18n'
i18n_euphorie = 'src/Euphorie/src/euphorie/deployment/locales'

# Quick statistics
# Check the i18n_proto directory, list and print all languages and the corresponding file size.
# Afterwards print the date when this repository was last updated.
print('Proto:')
for file in os.listdir(i18n_proto):
    if file.endswith('.po'):
        print(f'{file}: {os.path.getsize(f"{i18n_proto}/{file}")}')
print(f'Last updated: {os.path.getmtime(i18n_proto)}')  # noqa


proto_po_dict = {}
# Iterate over each po file in the i18n_proto directory, load the file using polib.
# Then store each pofile insteance in proto_po_dict with the language as the key.
for file in os.listdir(i18n_proto):
    if file.endswith('.po'):
        po = polib.pofile(f'{i18n_proto}/{file}')
        proto_po_dict[file.split('.')[0]] = po

# Iterate over all languages in the proto_po_dict
# For each language, access the language folder within the i18n_euphorie directory and enter the LC_MESSAGES directory within.
# For each po file in the LC_MESSAGES directory, load the file using polib.
for lang in proto_po_dict:
    # Load all proto messages for that language into a dict for faster lookup.
    proto_entries_dict = {
        entry.msgid: entry.msgstr for entry in proto_po_dict[lang]}

    for file in os.listdir(f'{i18n_euphorie}/{lang}/LC_MESSAGES'):
        if file.endswith('.po'):
            update_counter = 0
            po = polib.pofile(f'{i18n_euphorie}/{lang}/LC_MESSAGES/{file}')
            # Iterate over each entry in the po file and update the translation if the message_id matches.
            for entry in po:
                if entry.msgid in proto_entries_dict:
                    if proto_entries_dict[entry.msgid] and entry.msgstr != proto_entries_dict[entry.msgid]:
                        update_counter += 1
                        entry.msgstr = proto_entries_dict[entry.msgid]
            # Save the updated po file.
            po.save(f'{i18n_euphorie}/{lang}/LC_MESSAGES/{file}')
            print(
                f'Updated {update_counter} entries in Euphorie {file} for {lang}')

print('Done')
