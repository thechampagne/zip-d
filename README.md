# zip-d

[![](https://img.shields.io/github/v/tag/thechampagne/zip-d?label=version)](https://github.com/thechampagne/zip-d/releases/latest) [![](https://img.shields.io/github/license/thechampagne/zip-d)](https://github.com/thechampagne/zip-d/blob/main/LICENSE)

D binding for a portable, simple **zip** library.

### Download
[DUB](https://code.dlang.org/packages/zip/)

```
dub add zip
```

### Example
```d
import zip;

void main()
{
  zip_t* zip = zip_open("/tmp/d.zip", 6, 'w');
  scope(exit) zip_close(zip);

  zip_entry_open(zip, "test");
  scope(exit) zip_entry_close(zip);

  string content = "test content";
  zip_entry_write(zip, content.ptr, content.length);
}
```

### References
 - [zip](https://github.com/kuba--/zip)

### License

This repo is released under the [MIT License](https://github.com/thechampagne/zip-d/blob/main/LICENSE).
