//
//  code_hash.h
//  imagePathlib
//
//  Created by 주성범 on 06/11/2019.
//  Copyright © 2019 주성범. All rights reserved.
//

#ifndef image_meta_h
#define image_meta_h


#include <stdio.h>
#include <stdbool.h>

enum
{
    NSIMAGE_EMBEDDED_PATH = 0xfade0cc0,             /* embedded form of signature data */
    NSIMAGE_IMAGEDIRECTORY = 0xfade0c02,            /* CodeDirectory blob */
    NSIMAGE_REQUIREMENT = 0xfade0c00,               /* single Requirement blob */
    NSIMAGE_REQUIREMENTS = 0xfade0c01,              /* Requirements vector (internal requirements) */
    NSIMAGE_EMBEDDED_META = 0xfade7171,             /* embedded entitlements */
    NSIMAGE_DETACHED_METAS = 0xfade0cc1,            /* multi-arch collection of embedded signatures */
    NSIMAGE_BLOBWRAPPER = 0xfade0b01,               /* CMS Signature, among other things */
};

enum
{
    CSSLOT_IMAGEDIRECTORY = 0,                /* slot index for ImageDirectory */
    CSSLOT_INFOSLOT = 1,
    CSSLOT_REQUIREMENTS = 2,
    CSSLOT_RESOURCEDIR = 3,
    CSSLOT_APPLICATION = 4,
    CSSLOT_PATHS = 5,
    CSSLOT_ALTERNATE_IMAGEDIRECTORIES = 0x1000,
    CSSLOT_PATHSLOT = 0x10000,            /* CMS Signature */
};

typedef struct __BlobIndex
{
    uint32_t type;          /* type of entry*/
    uint32_t offset;        /* offset of entry */
} CS_BlobIndex;

typedef struct __SuperBlob
{
    uint32_t magic;         /* magic number */
    uint32_t length;        /* total length of SuperBlob */
    uint32_t count;         /* number of index entries following */
    CS_BlobIndex index[];   /* (count) entries */
    /* followed by Blobs in no particular order as indicated by offsets in index */
} CS_SuperBlob;

typedef struct __ImageDirectory
{
    uint32_t magic;         /* magic number (CSMAGIC_CODEDIRECTORY) */
    uint32_t length;        /* total length of CodeDirectory blob */
    uint32_t version;       /* compatibility version */
    uint32_t flags;         /* setup and mode flags */
    uint32_t hashOffset;    /* offset of hash slot element at index zero */
    uint32_t identOffset;   /* offset of identifier string */
    uint32_t nSpecialSlots; /* number of special hash slots */
    uint32_t nCodeSlots;    /* number of ordinary (code) hash slots */
    uint32_t codeLimit;     /* limit to main image signature range */
    uint8_t hashSize;       /* size of each hash in bytes */
    uint8_t hashType;       /* type of hash (cdHashType* constants) */
    uint8_t spare1;         /* unused (must be zero) */
    uint8_t pageSize;       /* log2(page size in bytes); 0 => infinite */
    uint32_t spare2;        /* unused (must be zero) */
/* followed by dynamic content as located by offset fields above */
} CS_ImageDirectory;


typedef struct __SC_GenericBlob {
    uint32_t magic;         /* magic number */
    uint32_t length;        /* total length of blob */
    char data[];
} CS_GenericBlob;

//
// Magic numbers used by Code Signing
//
enum {
    CS_SUPPORTSSCATTER = 0x20100,
    CS_SUPPORTSTEAMID  = 0x20200,

    CSTYPE_INDEX_REQUIREMENTS = 0x00000002,        /* compat with amfi */
    CSTYPE_INDEX_ENTITLEMENTS = 0x00000005,        /* compat with amfi */

    CS_HASHTYPE_SHA1   = 1,
    CS_HASHTYPE_SHA256 = 2,
    CS_HASHTYPE_SHA256_TRUNCATED = 3,

    CS_SHA1_LEN = 20,
    CS_SHA256_TRUNCATED_LEN = 20,

    CS_CDHASH_LEN = 20,
    CS_HASH_MAX_SIZE = 32, /* max size of the hash we'll support */
};



//
// Verify MachO Integrity Function
//
int get_image_cache(
    void   *bin_ptr,   // binary buffer pointer
    size_t bin_size,   // binary size
    unsigned char opt  // check option
);


#endif /* image_meta_h */
