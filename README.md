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
  zip_t* z = zip_open("/tmp/d.zip", 6, 'w');
  scope(exit) zip_close(z);

  zip_entry_open(z, "test");
  scope(exit) zip_entry_close(z);

  string content = "test content";
  zip_entry_write(z, content.ptr, content.length);
}
```

### References
 - [zip](https://github.com/kuba--/zip)

### License

This repo is released under the [MIT License](https://github.com/thechampagne/zip-d/blob/main/LICENSE).
