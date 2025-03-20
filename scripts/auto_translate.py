""" This script attempts to autotranslate the missing entries in the po files.
"""
import os
import polib
import subprocess


def translate_text(text, target_lang="nl"):
    """Translate text using trans CLI."""
    target_lang = ":"+target_lang
    try:
        result = subprocess.run(
            ["trans", "--brief", target_lang, text],
            capture_output=True,
            text=True
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except FileNotFoundError:
        return "The 'translate' command is not available on this system."


i18n_euphorie = 'src/Euphorie/src/euphorie/deployment/locales'

# Access the po files in the i18n_euphorie directory for language nl_BE.
# For each po file, open the file using polib.
# Then iterate over all untranslated entries in the nl_BE po file.
# For each entry, access the default value and print it.
lang = "nl_BE"
for file in os.listdir(f'{i18n_euphorie}/{lang}/LC_MESSAGES'):
    if file.endswith('.po'):
        po = polib.pofile(f'{i18n_euphorie}/{lang}/LC_MESSAGES/{file}')
        update_counter = 0
        for entry in po.untranslated_entries():
            # Remove the string "Default: " from the comment and print the comment.
            comment = entry.comment.replace(
                "Default: ", "").replace("\n", "").strip()[1:-1]
            if not comment:
                comment = entry.msgid
            comment_t = translate_text(comment, "nl").strip()
            if comment_t:
                update_counter += 1
                print(f"{entry.msgid}: {comment} | {comment_t}")
                entry.msgstr = comment_t
        po.save(f'{i18n_euphorie}/{lang}/LC_MESSAGES/{file}')
        print(f'Updated {update_counter} entries in {lang} {file}')
