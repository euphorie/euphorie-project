""" This script pulls the latest translations from prototype po files and updates the translations in the Euphorie package whenever there is a matching message_id.
The script assumes
- Euphorie and plonestatic.euphorie to be checked out in the src directory.
- prototype to be recently updated so that the po files there are up to date.
- that it gets called from within the buildout directory.
"""
import os
import polib
import yaml

oira_yaml_path = 'src/plonestatic.euphorie/var/prototype/_data/oira/ui.yaml'
patterns_yaml_path = 'src/plonestatic.euphorie/var/prototype/_data/patterns/ui.yaml'

# Load and parse the oira YAML file
with open(oira_yaml_path, 'r', encoding='utf-8') as oira_file:
    oira_data = yaml.safe_load(oira_file)

# Load and parse the patterns YAML file
with open(patterns_yaml_path, 'r', encoding='utf-8') as patterns_file:
    patterns_data = yaml.safe_load(patterns_file)

# oira_data takes precendence over patterns_data
proto_data = {**patterns_data, **oira_data}


i18n_euphorie = 'src/Euphorie/src/euphorie/deployment/locales'
LANGS = []

# Iterate over all lang in i18n_euphorie
for lang in os.listdir(i18n_euphorie):
    lang_path = os.path.join(i18n_euphorie, lang, 'LC_MESSAGES', 'euphorie.po')
    if os.path.isfile(lang_path):
        LANGS.append(lang)
        euphorie_po = polib.pofile(lang_path)
        update_counter = 0
        add_counter = 0
        was_empty_counter = 0
        all_good_counter = 0

        for entry in proto_data:
            # Check if the entry is not in the po file
            poentry = euphorie_po.find(entry)

            if proto_data[entry].get(lang, '') in (True, False):
                # the yaml parser interprets literally, so we need quotes
                print(f"YAML parser fun - quotes needed at {entry}!")
                breakpoint()

            if poentry and '${' in poentry.msgstr:
                # euphorie has a variable in the msgstr. Skip
                continue
            if proto_data[entry].get(lang, '') == '':
                # proto has nothing. Skip
                continue
            if not poentry:
                # euphorie doesn't have it. Add the entry to the po file
                euphorie_po.append(polib.POEntry(
                    msgid=entry,
                    msgstr=proto_data[entry].get(lang, '')
                ))
                add_counter += 1
            elif proto_data[entry].get(lang, '') == poentry.msgstr:
                # euphorie and proto agree
                all_good_counter += 1
                continue
            elif poentry.msgstr == '':
                # euphorie was empty but proto has something. Add proto to euphorie
                was_empty_counter += 1
            else:
                # euphorie had a different value from proto. Update euphorie
                print(
                    f'>> {entry} << {poentry.msgstr} ~> {proto_data[entry].get(lang)}')
                poentry.msgstr = proto_data[entry].get(lang, '')
                update_counter += 1

        # Save the updated po file
        euphorie_po.save(lang_path)
        print(f'in euphorie.po for {lang}:')
        print(f'- Added {add_counter} ')
        print(f'- All good {all_good_counter} ')
        print(f'- Was empty {was_empty_counter} ')
        print(f'- Updated {update_counter} ')

        print('Done')
