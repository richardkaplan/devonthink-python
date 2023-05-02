# PyDT3 - The Python API For DEVONthink 3

The Python API for Devonthink 3 utilizes AppleScript (JXA) and PyObjC.

Most of the APIs are directly mapped to AppleScript (JXA).
For example, these two are equivalent:

```python
from pydt3 import DEVONthink3
dt3 = DEVONthink3()
for db in dt3.databases:
    print(db.name)
```

```applescript
tell application "DEVONthink 3"
    repeat with db in databases
        log name of db as string
    end repeat
end tell
```

Many of the APIs are generated by ChatGTP from the DEVONthink's AppleScript dictionary.

The Applescript bridging part is inspired by [py-applescript](https://github.com/rdhyee/py-applescript).

Notes used as examples are imported from [The Blue Book](https://github.com/lyz-code/blue-book), a personal wiki shared by [lyz-code](https://github.com/lyz-code).

## Installation

```bash
pip install pydt3
```

## Quick Start

```python
from pydt3 import DEVONthink3
dtp3 = DEVONthink3()

inbox = dtp3.inbox

# create a new folder in inbox
dtp3.create_location('new-group-from-pydt3', inbox)

# get selected records
records = dtp3.selected_records

# get the first selected record and print its information
if records:
    first = records[0]
    print(first.name)
    print(first.type)
    print(first.reference_url)
    print(first.plain_text)

# create record in inbox
record = dtp3.create_record_with({
    'name': 'hello-from-pydt3',
    'type': 'markdown',
    'plain text': '# Hello from pydt3',
}, inbox)
```

## Work With ChatGTP

### Add Tags to Selected Records Using ChatGTP

Put this [script](https://github.com/thekoc/devonthink-python/releases/download/example-scripts-v0.03/GPT.Add.Tags.scptd.zip) into `~/Library/Application Scripts/com.devon-technologies.think3/Contextual Menu` and run it from contextual menu in DEVONthink (The record must be in selected state).

![add_tags_contextual_menu](https://github.com/thekoc/devonthink-python/raw/main/images/add_tags_contextual_menu.png)

And voilà, the tags are added based on contents automatically.

![generated_tags](https://github.com/thekoc/devonthink-python/raw/main/images/generated_tags.png)

Note: You are required to have an [API key](https://platform.openai.com/account/api-keys) from OpenAI. The first time you run the script, a prompt will ask you to enter key.

![api_key_prompt](https://github.com/thekoc/devonthink-python/raw/main/images/api_key_prompt.png)

The key will be store in Incoming group for DEVONthink (usually `Inbox`). You can see the file `__openai_api_key__` generated there. You can move it to other opened database but don't change it's name.

### Auto Writing / Summarizing Using ChatGTP

[This script](https://github.com/thekoc/devonthink-python/releases/download/example-scripts-v0.03/GPT.Expand.Content.zip) lets you to insert `<<TOKEN>>` into your text and then generate the text based on the token.

![before_expansion](https://github.com/thekoc/devonthink-python/raw/main/images/before_expansion.png)

![after_expansion](https://github.com/thekoc/devonthink-python/raw/main/images/after_expansion.png)

Put the script into `~/Library/Application Scripts/com.devon-technologies.think3/Toolbar`. Restart the DEVONthink and you will see the script in the toolbar customization window.

![custom_toolbar](https://github.com/thekoc/devonthink-python/raw/main/images/custom_toolbar.png)

### About the Release Scripts

The script bundles provided by the project are packed by PyInstaller so that you can run them without Python installation. But the size is relatively large. You can write your own version if you do have Python installed (with required packages.) See codes in examples for more information.

## Documentation

Unlike many other API wrapper projects, PyDT3 is well documented thanks to the detailed AppleScript dictionary by DEVONthink team and the code generation ability of ChatGTP.

You can check the documentation either in source code (`docstring`), code editor (if properly configured), or the documentation site (not available at the time).

![documentation-in-editor](https://github.com/thekoc/devonthink-python/raw/main/images/create_record_with_doc.png)

## Requirements

- DEVONthink 3
- Python 3.6+
- PyObjC

## Limitations

- The APIs are not fully tested. Please report any issues.
- Rich texts in AppleScript are converted to strings in Python, which causes style information loss.
- Collections of elements (eg. `database.records`) are converted to lists in Python. While in Applescript they are retrieved in a lazy manner. This may cause performance issues with large collections.
