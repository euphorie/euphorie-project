import yaml
""" USE ONLY AS DEVELOPER! This is a helper script to clean up the prototype YAML files. 

It checks for redundant translations—cases where a translation in another language is identical to the English ("en") version.
We need to do that so that we can later identify missing translations in other languages so that we may provide proper translations.

How it works:

It loads the patterns YAML file (the path is set by patterns_yaml_path).
For each key, it gets the English translation.
It compares each other language’s translation to the English one.
If a translation matches the English text, it prints a message and triggers a debugger breakpoint for inspection.

Output:
It prints out any keys where a non-English translation is the same as the English one and pauses execution for debugging.

Note:
The code to write changes back to the YAML file is commented out, so the script currently only checks and reports redundancies—it does not modify the file. I have done this to make sure this is first used to inspect the data before making any changes.

Gotcha:
If you want to actually remove redundant translations or save changes, you’d need to uncomment and adapt the writing section. Also, the script expects the YAML structure to be a dictionary of keys, each mapping to a dictionary of language codes and translations.

"""

oira_yaml_path = 'src/plonestatic.euphorie/var/prototype/_data/oira/ui.yaml'
patterns_yaml_path = 'src/plonestatic.euphorie/var/prototype/_data/patterns/ui.yaml'


def remove_redundant_translations(yaml_path):
    with open(yaml_path, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)

    for key, translations in data.items():
        en_value = translations.get('en')
        if not en_value:
            continue
        # Remove keys where the translation is the same as English
        for lang, value in translations.items():
            if lang != 'en' and value == en_value:
                print(f'Check {key}: {lang} == {en_value}')
                breakpoint()

    # # Write it back (optional)
    # with open(yaml_path, 'w', encoding='utf-8') as f:
    #     yaml.dump(data, f, allow_unicode=True, sort_keys=False)


# Example usage
# remove_redundant_translations(oira_yaml_path)
remove_redundant_translations(patterns_yaml_path)
