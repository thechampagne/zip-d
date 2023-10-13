/*
 * Copyright (c) 2023 XXIV
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module zip.raw;

// Documentation copied from https://github.com/kuba--/zip/blob/master/src/zip.h

extern (C):

/**
 * Default zip compression level.
 */
enum ZIP_DEFAULT_COMPRESSION_LEVEL = 6;

/**
 * Error codes
 */
enum ZIP_ENOINIT = -1; // not initialized
enum ZIP_EINVENTNAME = -2; // invalid entry name
enum ZIP_ENOENT = -3; // entry not found
enum ZIP_EINVMODE = -4; // invalid zip mode
enum ZIP_EINVLVL = -5; // invalid compression level
enum ZIP_ENOSUP64 = -6; // no zip 64 support
enum ZIP_EMEMSET = -7; // memset error
enum ZIP_EWRTENT = -8; // cannot write data to entry
enum ZIP_ETDEFLINIT = -9; // cannot initialize tdefl compressor
enum ZIP_EINVIDX = -10; // invalid index
enum ZIP_ENOHDR = -11; // header not found
enum ZIP_ETDEFLBUF = -12; // cannot flush tdefl buffer
enum ZIP_ECRTHDR = -13; // cannot create entry header
enum ZIP_EWRTHDR = -14; // cannot write entry header
enum ZIP_EWRTDIR = -15; // cannot write to central dir
enum ZIP_EOPNFILE = -16; // cannot open file
enum ZIP_EINVENTTYPE = -17; // invalid entry type
enum ZIP_EMEMNOALLOC = -18; // extracting data using no memory allocation
enum ZIP_ENOFILE = -19; // file not found
enum ZIP_ENOPERM = -20; // no permission
enum ZIP_EOOMEM = -21; // out of memory
enum ZIP_EINVZIPNAME = -22; // invalid zip archive name
enum ZIP_EMKDIR = -23; // make dir error
enum ZIP_ESYMLINK = -24; // symlink error
enum ZIP_ECLSZIP = -25; // close archive error
enum ZIP_ECAPSIZE = -26; // capacity size too small
enum ZIP_EFSEEK = -27; // fseek error
enum ZIP_EFREAD = -28; // fread error
enum ZIP_EFWRITE = -29; // fwrite error
enum ZIP_ERINIT = -30; // cannot initialize reader
enum ZIP_EWINIT = -31; // cannot initialize writer
enum ZIP_EWRINIT = -32; // cannot initialize writer from reader

/**
 * Looks up the error message string corresponding to an error number.
 * @param errnum error number
 * @return error message string corresponding to errnum or NULL if error is not
 * found.
 */
const(char)* zip_strerror (int errnum);

/**
 * @struct zip_t
 *
 * This data structure is used throughout the library to represent zip archive -
 * forward declaration.
 */
struct zip_t;

/**
 * Opens zip archive with compression level using the given mode.
 *
 * @param zipname zip archive file name.
 * @param level compression level (0-9 are the standard zlib-style levels).
 * @param mode file access mode.
 *        - 'r': opens a file for reading/extracting (the file must exists).
 *        - 'w': creates an empty file for writing.
 *        - 'a': appends to an existing archive.
 *
 * @return the zip archive handler or NULL on error
 */
zip_t* zip_open (const(char)* zipname, int level, char mode);

/**
 * Opens zip archive with compression level using the given mode.
 * The function additionally returns @param errnum -
 *
 * @param zipname zip archive file name.
 * @param level compression level (0-9 are the standard zlib-style levels).
 * @param mode file access mode.
 *        - 'r': opens a file for reading/extracting (the file must exists).
 *        - 'w': creates an empty file for writing.
 *        - 'a': appends to an existing archive.
 * @param errnum 0 on success, negative number (< 0) on error.
 *
 * @return the zip archive handler or NULL on error
 */
zip_t* zip_openwitherror (
    const(char)* zipname,
    int level,
    char mode,
    int* errnum);

/**
 * Closes the zip archive, releases resources - always finalize.
 *
 * @param zip zip archive handler.
 */
void zip_close (zip_t* zip);

/**
 * Determines if the archive has a zip64 end of central directory headers.
 *
 * @param zip zip archive handler.
 *
 * @return the return code - 1 (true), 0 (false), negative number (< 0) on
 *         error.
 */
int zip_is64 (zip_t* zip);

/**
 * Opens an entry by name in the zip archive.
 *
 * For zip archive opened in 'w' or 'a' mode the function will append
 * a new entry. In readonly mode the function tries to locate the entry
 * in global dictionary.
 *
 * @param zip zip archive handler.
 * @param entryname an entry name in local dictionary.
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_entry_open (zip_t* zip, const(char)* entryname);

/**
 * Opens an entry by name in the zip archive.
 *
 * For zip archive opened in 'w' or 'a' mode the function will append
 * a new entry. In readonly mode the function tries to locate the entry
 * in global dictionary (case sensitive).
 *
 * @param zip zip archive handler.
 * @param entryname an entry name in local dictionary (case sensitive).
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_entry_opencasesensitive (zip_t* zip, const(char)* entryname);

/**
 * Opens a new entry by index in the zip archive.
 *
 * This function is only valid if zip archive was opened in 'r' (readonly) mode.
 *
 * @param zip zip archive handler.
 * @param index index in local dictionary.
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_entry_openbyindex (zip_t* zip, size_t index);

/**
 * Closes a zip entry, flushes buffer and releases resources.
 *
 * @param zip zip archive handler.
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_entry_close (zip_t* zip);

/**
 * Returns a local name of the current zip entry.
 *
 * The main difference between user's entry name and local entry name
 * is optional relative path.
 * Following .ZIP File Format Specification - the path stored MUST not contain
 * a drive or device letter, or a leading slash.
 * All slashes MUST be forward slashes '/' as opposed to backwards slashes '\'
 * for compatibility with Amiga and UNIX file systems etc.
 *
 * @param zip: zip archive handler.
 *
 * @return the pointer to the current zip entry name, or NULL on error.
 */
const(char)* zip_entry_name (zip_t* zip);

/**
 * Returns an index of the current zip entry.
 *
 * @param zip zip archive handler.
 *
 * @return the index on success, negative number (< 0) on error.
 */
long zip_entry_index (zip_t* zip);

/**
 * Determines if the current zip entry is a directory entry.
 *
 * @param zip zip archive handler.
 *
 * @return the return code - 1 (true), 0 (false), negative number (< 0) on
 *         error.
 */
int zip_entry_isdir (zip_t* zip);

/**
 * Returns the uncompressed size of the current zip entry.
 * Alias for zip_entry_uncomp_size (for backward compatibility).
 *
 * @param zip zip archive handler.
 *
 * @return the uncompressed size in bytes.
 */
ulong zip_entry_size (zip_t* zip);

/**
 * Returns the uncompressed size of the current zip entry.
 *
 * @param zip zip archive handler.
 *
 * @return the uncompressed size in bytes.
 */
ulong zip_entry_uncomp_size (zip_t* zip);

/**
 * Returns the compressed size of the current zip entry.
 *
 * @param zip zip archive handler.
 *
 * @return the compressed size in bytes.
 */
ulong zip_entry_comp_size (zip_t* zip);

/**
 * Returns CRC-32 checksum of the current zip entry.
 *
 * @param zip zip archive handler.
 *
 * @return the CRC-32 checksum.
 */
uint zip_entry_crc32 (zip_t* zip);

/**
 * Compresses an input buffer for the current zip entry.
 *
 * @param zip zip archive handler.
 * @param buf input buffer.
 * @param bufsize input buffer size (in bytes).
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_entry_write (zip_t* zip, const(void)* buf, size_t bufsize);

/**
 * Compresses a file for the current zip entry.
 *
 * @param zip zip archive handler.
 * @param filename input file.
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_entry_fwrite (zip_t* zip, const(char)* filename);

/**
 * Extracts the current zip entry into output buffer.
 *
 * The function allocates sufficient memory for a output buffer.
 *
 * @param zip zip archive handler.
 * @param buf output buffer.
 * @param bufsize output buffer size (in bytes).
 *
 * @note remember to release memory allocated for a output buffer.
 *       for large entries, please take a look at zip_entry_extract function.
 *
 * @return the return code - the number of bytes actually read on success.
 *         Otherwise a negative number (< 0) on error.
 */
long zip_entry_read (zip_t* zip, void** buf, size_t* bufsize);

/**
 * Extracts the current zip entry into a memory buffer using no memory
 * allocation.
 *
 * @param zip zip archive handler.
 * @param buf preallocated output buffer.
 * @param bufsize output buffer size (in bytes).
 *
 * @note ensure supplied output buffer is large enough.
 *       zip_entry_size function (returns uncompressed size for the current
 *       entry) can be handy to estimate how big buffer is needed.
 *       For large entries, please take a look at zip_entry_extract function.
 *
 * @return the return code - the number of bytes actually read on success.
 *         Otherwise a negative number (< 0) on error (e.g. bufsize is not large
 * enough).
 */
long zip_entry_noallocread (zip_t* zip, void* buf, size_t bufsize);

/**
 * Extracts the current zip entry into output file.
 *
 * @param zip zip archive handler.
 * @param filename output file.
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_entry_fread (zip_t* zip, const(char)* filename);

/**
 * Extracts the current zip entry using a callback function (on_extract).
 *
 * @param zip zip archive handler.
 * @param on_extract callback function.
 * @param arg opaque pointer (optional argument, which you can pass to the
 *        on_extract callback)
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_entry_extract (
    zip_t* zip,
    size_t function (void* arg, ulong offset, const(void)* data, size_t size) on_extract,
    void* arg);

/**
 * Returns the number of all entries (files and directories) in the zip archive.
 *
 * @param zip zip archive handler.
 *
 * @return the return code - the number of entries on success, negative number
 *         (< 0) on error.
 */
long zip_entries_total (zip_t* zip);

/**
 * Deletes zip archive entries.
 *
 * @param zip zip archive handler.
 * @param entries array of zip archive entries to be deleted.
 * @param len the number of entries to be deleted.
 * @return the number of deleted entries, or negative number (< 0) on error.
 */
long zip_entries_delete (zip_t* zip, const(char*)* entries, size_t len);

/**
 * Extracts a zip archive stream into directory.
 *
 * If on_extract is not NULL, the callback will be called after
 * successfully extracted each zip entry.
 * Returning a negative value from the callback will cause abort and return an
 * error. The last argument (void *arg) is optional, which you can use to pass
 * data to the on_extract callback.
 *
 * @param stream zip archive stream.
 * @param size stream size.
 * @param dir output directory.
 * @param on_extract on extract callback.
 * @param arg opaque pointer.
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_stream_extract (
    const(char)* stream,
    size_t size,
    const(char)* dir,
    int function (const(char)* filename, void* arg) on_extract,
    void* arg);

/**
 * Opens zip archive stream into memory.
 *
 * @param stream zip archive stream.
 * @param size stream size.
 * @param level compression level (0-9 are the standard zlib-style levels).
 * @param mode file access mode.
 *        - 'r': opens a file for reading/extracting (the file must exists).
 *        - 'w': creates an empty file for writing.
 *        - 'a': appends to an existing archive.
 *
 * @return the zip archive handler or NULL on error
 */
zip_t* zip_stream_open (const(char)* stream, size_t size, int level, char mode);

/**
 * Opens zip archive stream into memory.
 * The function additionally returns @param errnum -
 *
 * @param stream zip archive stream.
 * @param size stream size.*
 * @param level compression level (0-9 are the standard zlib-style levels).
 * @param mode file access mode.
 *        - 'r': opens a file for reading/extracting (the file must exists).
 *        - 'w': creates an empty file for writing.
 *        - 'a': appends to an existing archive.
 * @param errnum 0 on success, negative number (< 0) on error.
 *
 * @return the zip archive handler or NULL on error
 */
zip_t* zip_stream_openwitherror (
    const(char)* stream,
    size_t size,
    int level,
    char mode,
    int* errnum);

/**
 * Copy zip archive stream output buffer.
 *
 * @param zip zip archive handler.
 * @param buf output buffer. User should free buf.
 * @param bufsize output buffer size (in bytes).
 *
 * @return copy size
 */
long zip_stream_copy (zip_t* zip, void** buf, size_t* bufsize);

/**
 * Close zip archive releases resources.
 *
 * @param zip zip archive handler.
 *
 * @return
 */
void zip_stream_close (zip_t* zip);

/**
 * Creates a new archive and puts files into a single zip archive.
 *
 * @param zipname zip archive file.
 * @param filenames input files.
 * @param len: number of input files.
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_create (const(char)* zipname, const(char)** filenames, size_t len);

/**
 * Extracts a zip archive file into directory.
 *
 * If on_extract_entry is not NULL, the callback will be called after
 * successfully extracted each zip entry.
 * Returning a negative value from the callback will cause abort and return an
 * error. The last argument (void *arg) is optional, which you can use to pass
 * data to the on_extract_entry callback.
 *
 * @param zipname zip archive file.
 * @param dir output directory.
 * @param on_extract_entry on extract callback.
 * @param arg opaque pointer.
 *
 * @return the return code - 0 on success, negative number (< 0) on error.
 */
int zip_extract (
    const(char)* zipname,
    const(char)* dir,
    int function (const(char)* filename, void* arg) on_extract_entry,
    void* arg);
