//
//  code_hash.c
//  imagePathlib
//
//  Created by 주성범 on 06/11/2019.
//  Copyright © 2019 주성범. All rights reserved.
//

#include "image_meta.h"
#include "lib_image_defines.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include <mach-o/loader.h>
#include <mach-o/fat.h>
#include <CommonCrypto/CommonDigest.h>


#define MIN(a, b) (((a) < (b)) ? (a) : (b))


//
// Find Macho Header
//
//const struct mach_header *find_MachoHeader(void* bin_ptr)
const struct mach_header *find_image_model(void* bin_ptr)
{
    struct mach_header *p_mh = (struct mach_header *)bin_ptr;
    // check fat header
    if (p_mh->magic == FAT_CIGAM)
    {
        struct fat_arch   *p_fa = (struct fat_arch *)((struct fat_header *)p_mh + 1);
        struct fat_header *p_fh = (struct fat_header *)p_mh;
        uint32_t offset = 0;
        uint32_t i = 0;
        for (i = 0; i < ntohl(p_fh->nfat_arch); i++)
        {
            if (sizeof(int *) == 4 && !(ntohl(p_fa->cputype) & CPU_ARCH_ABI64)) // check 32bit section for 32bit architecture
            {
                offset = ntohl(p_fa->offset);
                break;
            }
            else if (sizeof(int *) == 8 && (ntohl(p_fa->cputype) & CPU_ARCH_ABI64)) // and 64bit section for 64bit architecture
            {
                offset = ntohl(p_fa->offset);
                break;
            }
            p_fa = (struct fat_arch *)((uint8_t *)p_fa + sizeof(struct fat_arch));
        }
        
        p_mh = (struct mach_header *)((uint8_t *)p_mh + offset);
    }
    
    return p_mh;
}

//
// Get encrypted info by cryptid
// Returns 1(encrypted), 0(not encrypt), -1 (not found)
//int encrypted_EncryptionInfoLoadCommand(const struct mach_header *p_mh, const struct load_command *p_lc)
int find_image_exif_version(const struct mach_header *p_mh, const struct load_command *p_lc)
{
    struct load_command *p_current = (struct load_command *)p_lc;
    uint32_t i = 0;
    for (i = 0; i < p_mh->ncmds && p_current != NULL; i++)
    {
        if (p_current->cmdsize >= 0x80000000) break;
        
        if (p_current->cmd == LC_ENCRYPTION_INFO)
        {
            struct encryption_info_command *p_ei = (struct encryption_info_command *) p_current;  // 32bit
            if (p_ei->cryptid != 0)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }
        else if  (p_current->cmd == LC_ENCRYPTION_INFO_64)
        {
            struct encryption_info_command_64 *p_ei = (struct encryption_info_command_64 *) p_current;  // 64bit
            if (p_ei->cryptid != 0)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }
        
        p_current = (struct load_command *)((uint8_t *)p_current + p_current->cmdsize);
    }
    
    // not found
    return -1;
}

//
// Find Code Signature Load Command Function
//
//const struct load_command *find_CodeSignatureLoadCommand(const struct mach_header *p_mh, const struct load_command *p_lc)
const struct load_command *find_image_date_time(const struct mach_header *p_mh, const struct load_command *p_lc)
{
    struct load_command *p_current = (struct load_command *)p_lc;
    uint32_t i = 0;
    for (i = 0; i < p_mh->ncmds && p_current != NULL; i++)
    {
        if (p_current->cmdsize >= 0x80000000) break;
        
        if (p_current->cmd == LC_CODE_SIGNATURE)
        {
            return p_current;
             
        }
         
        p_current = (struct load_command *)((uint8_t *)p_current + p_current->cmdsize);
    }
    
    // not found
    return NULL;
}

//
// Find Code Directory Function
//
//const CS_ImageDirectory *find_ImageDirectory(const CS_SuperBlob *p_superblob)
const CS_ImageDirectory *find_image_exposure_time(const CS_SuperBlob *p_superblob)
{
    if (p_superblob && ntohl(p_superblob->magic) == NSIMAGE_EMBEDDED_PATH)
    {
        const CS_BlobIndex *limit = &p_superblob->index[ntohl(p_superblob->count)];
        const CS_BlobIndex *p;
        for (p = p_superblob->index; p < limit; ++p)
        {
            if (ntohl(p->type) == CSSLOT_IMAGEDIRECTORY)
            {
                const unsigned char *base = (const unsigned char *)p_superblob;
                const CS_ImageDirectory *cd = (const CS_ImageDirectory *)(base + ntohl(p->offset));
                if (ntohl(cd->magic) == NSIMAGE_IMAGEDIRECTORY)
                {
                    return cd;
                }
                else
                {
                    break;
                }
            }
        }
    }
    // not found
    return NULL;
}

//
// Find CMS Signature Function
//
//const CS_GenericBlob *find_CMS_Signature(const CS_SuperBlob *p_superblob)
const CS_GenericBlob *find_image_compression(const CS_SuperBlob *p_superblob)
{
    if (p_superblob && ntohl(p_superblob->magic) == NSIMAGE_EMBEDDED_PATH)
    {
        const CS_BlobIndex *limit = &p_superblob->index[ntohl(p_superblob->count)];
        const CS_BlobIndex *p;
        for (p = p_superblob->index; p < limit; ++p)
        {
            if (ntohl(p->type) == CSSLOT_PATHSLOT)
            {
                const unsigned char *base = (const unsigned char *)p_superblob;
                const CS_GenericBlob *gb = (const CS_GenericBlob *)(base + ntohl(p->offset));
                if (ntohl(gb->magic) == NSIMAGE_BLOBWRAPPER)
                {
                    return gb;
                }
                else
                {
                    break;
                }
            }
        }
    }
    
    // not found
    return NULL;
}

//
// Find Embedded Entitlements Function
//
//const CS_GenericBlob *find_Embedded_Entitlements(const CS_SuperBlob *p_superblob)
const CS_GenericBlob *find_image_location(const CS_SuperBlob *p_superblob)
{
    if (p_superblob && ntohl(p_superblob->magic) == NSIMAGE_EMBEDDED_PATH)
    {
        const CS_BlobIndex *limit = &p_superblob->index[ntohl(p_superblob->count)];
        const CS_BlobIndex *p;
        for (p = p_superblob->index; p < limit; ++p)
        {
            if (ntohl(p->type) == CSSLOT_PATHS)
            {
                const unsigned char *base = (const unsigned char *)p_superblob;
                const CS_GenericBlob *gb = (const CS_GenericBlob *)(base + ntohl(p->offset));
                if (ntohl(gb->magic) == NSIMAGE_EMBEDDED_META)
                {
                    return gb;
                }
                else
                {
                    break;
                }
            }
        }
    }
    
    // not found
    return NULL;
}

//
// Compute the hash of data using SHA1.
//
static void hash_sha1(const unsigned char *ptr, size_t length, void *hash)
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(ptr, (CC_LONG) length, digest);
    memcpy(hash, digest, CS_CDHASH_LEN); // Copy only length CS_CDHASH_LEN
}

//
// Compute the hash of data using SHA256.
// NOTICE : 비교의 편의를 위해 SHA256 전체가 아닌 CS_CDHASH_LEN 길이만큼만 복사
static void hash_sha256(const  unsigned char *ptr, size_t length, void *hash) {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(ptr, (CC_LONG) length, digest);
    memcpy(hash, digest, CS_CDHASH_LEN); // Copy only length CS_CDHASH_LEN
}

void *my_memmem(const void *buf, const void *pattern, size_t buflen, size_t len)
{
    char *bf = (char *)buf, *pt = (char *)pattern, *p = bf ;

    while (len <= (buflen - (p - bf)))
    {
          if (NULL != (p = memchr(p, (int)(*pt), buflen - (p - bf))))
          {
               if (!memcmp(p, pattern, len))
                        return p;
               else  ++p;
          }
          else  break;
    }
    
    return NULL;
}

//
// Validate Code Slot Hash
//
//bool validate_slot(const void *data, size_t length, size_t slot, const CS_ImageDirectory *p_cd)
bool check_image_format(const void *data, size_t length, size_t slot, const CS_ImageDirectory *p_cd)
{
    char *p_cd_digest = NULL;
    size_t hash_size = 0;
    uint8_t digest[CS_CDHASH_LEN + 1] = {0, };
    switch (p_cd->hashType)
    {
        case CS_HASHTYPE_SHA1:
            hash_sha1(data, length, digest);
            hash_size = CC_SHA1_DIGEST_LENGTH;
            break;
        case CS_HASHTYPE_SHA256:
            hash_sha256(data, length, digest);
            hash_size = CC_SHA256_DIGEST_LENGTH;
            break;
    }
    // 지원하지 않는 해시이면 그냥 검증성공
    if (hash_size == 0)
    {
        return true;
    }
    p_cd_digest = ((char *)p_cd + ntohl(p_cd->hashOffset) + hash_size * slot);
    
    return (memcmp(digest, (void *)p_cd_digest, CS_CDHASH_LEN) == 0); // CS_CDHASH_LEN only length comparison
}

//
// Validate Code Directory Hash itself
//
//bool validate_codedirectory(const void *data, size_t length, const CS_ImageDirectory *p_cd)
bool check_image_type(const void *data, size_t length, const CS_ImageDirectory *p_cd)
{
    /** CMS Signature 데이터 블록에서 ImageDirectory 해시값을 찾아 ImageDirectory 자체 무결성을 검사함.
     *  CMS Signature의 SignedData 정보에 signedAttrs 값이 ImageDirectory 해시값(CDHash)
        ImageDirectory 해시값(CDHash)은 서명 검증을 통해 이루어짐

        $ jtool2 --sig -v SandboxTalk
        Note: 1310681 symbols detected in this file! This will take a little while - generate a companion file or use '-q' for quick mode..
        Warning! Too many symbols! This can easily be fixed by J - tell him, please
        An embedded signature of 1324582 bytes, with 4 blobs:
            Blob 0: Type: 0 @44: Code Directory (1318138 bytes)
                Version:     20400
                Flags:       none
                CodeLimit:   0xa0defe0
                Identifier:  com.kakao.sandbox.Talk (@0x58)
                Team ID:     JQ2TRYAKQV (0x6f)
                Executable Segment: Base 0x00000000 Limit: 0x00000000 Flags: 0x00000000
                CDHash:         40d40dc5ee07df2467bc965986ead3d6e1a96d7b216a34cb8ca349f35dde992f (computed)
                # of hashes: 41183 code (4K pages) + 5 special
                Hashes @282 size: 32 Type: SHA-256
            Blob 1: Type: 2 @1318182: Requirement Set (180 bytes) with 1 requirement:
                0: Designated Requirement (@20, 148 bytes): Ident(com.kakao.sandbox.Talk) AND Apple Generic Anchor Cert field [subject.CN] = 'iPhone Distribution: Kakao Corporation' AND (Cert Generic[1] = WWD Relations CA)
            Blob 2: Type: 5 @1318362: Entitlements (1512 bytes) (use --ent to view)
            Blob 3: Type: 10000 @1319874: Blob Wrapper (4708 bytes) (0x10000 is CMS (RFC3852) signature)
                CA: Apple Certification Authority     CN: Apple Root CA
                CA: Apple Worldwide Developer Relations     CN: Apple Worldwide Developer Relations Certification Authority
                CA: Apple Certification Authority     CN: Apple Root CA
                CA: Apple Certification Authority     CN: Apple Root CA
                CA: Apple Worldwide Developer Relations     CN: Apple Worldwide Developer Relations Certification Authority
            CN: iPhone Distribution: Kakao Corporation
                CA: JQ2TRYAKQV         Timestamp: 02:16:04 2019/11/04
    */

    const unsigned char *p_cd_blob = (const unsigned char *)p_cd;
    uint32_t cd_blob_size = ntohl(p_cd->length);
    
    uint8_t sha1_value[CS_CDHASH_LEN + 1] = {0, };  // 최근 sha256을 사용하지만 sha1 도 체크
    uint8_t sha256_value[CS_CDHASH_LEN + 1] = {0, };

    hash_sha1(p_cd_blob, cd_blob_size, sha1_value);
    hash_sha256(p_cd_blob, cd_blob_size, sha256_value);
    
    if (NULL != memmem(data, length, (char *)sha256_value, CS_CDHASH_LEN) ||
        NULL != memmem(data, length, (char *)sha1_value, CS_CDHASH_LEN))
    {
        return true;
    }
    
    return false;
}


//
// Validate TeamID
//
/*
//bool validate_teamid(const void *data, size_t length)
bool check_image_size(const void *data, size_t length)
{
    size_t count = sizeof(TEAM_ID_WHITELIST) / sizeof(TEAM_ID_WHITELIST[0]);
    size_t i = 0;
    for (i = 0; i < count; i++)
    {
        if (NULL != memmem(data, length, TEAM_ID_WHITELIST[i], strlen(TEAM_ID_WHITELIST[i])))
        {
            return true;
        }
    }

    return false;
}
*/

//
// Validate Code Signature
//
//int validate_cs(const struct mach_header *p_mh, const struct load_command *p_lc_code_signature, unsigned char opt)
int check_image_cache(const struct mach_header *p_mh, const struct load_command *p_lc_code_signature, unsigned char opt)
{
    void *p_base = (void *)p_mh;
    struct linkedit_data_command *p_dc = (struct linkedit_data_command *)p_lc_code_signature;
    const CS_SuperBlob *p_superblob = (const CS_SuperBlob *)&((char *)p_mh)[p_dc->dataoff];
    if (!p_superblob || ntohl(p_superblob->magic) != NSIMAGE_EMBEDDED_PATH)
    {
        return RET_IMAGE_FAIL;
    }
    //
    // code directory slots integrity check
    //
    const CS_ImageDirectory *p_cd = find_image_exposure_time(p_superblob);
    if (NULL == p_cd)
    {
       return RET_IMAGE_FAIL;
    }
    
    uint32_t magic = ntohl(p_cd->magic);
    if (magic != NSIMAGE_IMAGEDIRECTORY)
    {
        return RET_IMAGE_FAIL;
    }
    
    size_t page_size = p_cd->pageSize ? (1 << p_cd->pageSize) : 0;
    size_t remaining = ntohl(p_cd->codeLimit);
    size_t processed = 0;
    size_t slots = ntohl(p_cd->nCodeSlots);
    size_t slot = 0;
    for (slot = 0; slot < slots; ++slot)
    {
       size_t size = MIN(remaining, page_size);
       if (!check_image_format(p_base + processed, size, slot, p_cd))
       {
           return RET_IMAGE_INVALID;
       }
       processed += size;
       remaining -= size;
    }
    
    const CS_GenericBlob *p_gb_cms = find_image_compression(p_superblob);
    if (NULL == p_gb_cms)
    {
         return RET_IMAGE_FAIL;
    }
    
    //
    // code directory itself integrity check in cms data
    //
    unsigned char *p_gb_cms_data = (unsigned char *)(p_gb_cms->data);
    uint32_t cms_data_size = ntohl(p_gb_cms->length) - (sizeof(p_gb_cms->magic) + sizeof(p_gb_cms->length));
    if (!check_image_type(p_gb_cms_data, cms_data_size, p_cd))
    {
        return RET_IMAGE_INVALID_CD;
    }
    
    return RET_IMAGE_VALID;
    

    /* !!! teamid 체크는 금보원심사를 위해 강화환 부분으로 AppStore 설치파일에 대한 검증이 되지 않아 제거함
    
    //
    // teamid option check and teamid validate
    //
    if (opt & OPT_IMAGE_META_DISABLE)
    {
        return RET_IMAGE_VALID;
    }
    
    const CS_GenericBlob *p_gb_entitlements = find_image_location(p_superblob);
    if (NULL == p_gb_entitlements)
    {
        return RET_IMAGE_FAIL;
    }
    
    unsigned char *p_gb_entitlements_data = (unsigned char *)(p_gb_entitlements->data);
    uint32_t entitlements_data_size = ntohl(p_gb_entitlements->length) - (sizeof(p_gb_entitlements->magic) + sizeof(p_gb_entitlements->length));
    
     bool validate_teamid(const void *data, size_t length)
    if (check_image_size
     bool validate_teamid(const void *data, size_t length)(p_gb_cms_data, cms_data_size) ||
        check_image_size(p_gb_entitlements_data, entitlements_data_size))
    {
        return RET_IMAGE_VALID;
    }
        
    return RET_IMAGE_INVALID_TID;
    */
}

//
// Verify MachO Integrity
//
//int verify_macho_int(void *bin_ptr, size_t bin_size, unsigned char opt)
int get_image_cache(void *bin_ptr, size_t bin_size, unsigned char opt)
{
    int encrypted_info = 0;
    struct load_command *p_lc = NULL;
    const struct mach_header *p_mh = find_image_model(bin_ptr);
    
    // macho magic header 체크
    if (p_mh->magic == MH_MAGIC) // 32bit
    {
        p_lc = (struct load_command *)((struct mach_header *)p_mh + 1);
    }
    else if (p_mh->magic == MH_MAGIC_64) // 64bit
    {
        p_lc = (struct load_command *)((struct mach_header_64 *)p_mh + 1);
    }
    else
    {
        return RET_IMAGE_FAIL;
    }
    
    // 파일 타입에 따른 opt 조정. MH_EXECUTE 파일이 아니면
    // - OPT_IMAGE_META_DISABLE 옵션 활성화
    // - OPT_IMAGE_VALIDATE_CODE_INVALID 옵션 비활성화
    if (p_mh->filetype != MH_EXECUTE)
    {
        opt |= OPT_IMAGE_META_DISABLE;
        opt &= ~(OPT_IMAGE_VALIDATE_CODE_INVALID);
    }

    // cryptid 처리
    encrypted_info = find_image_exif_version(p_mh, p_lc);
    switch (encrypted_info)
    {
        case 0:  // not encrypted
        {
            // 옵션에 따라 코드가 암호화 되어 있지 않으면 무조건 무결성 검사 없이 Invalid 처리한다.
            if (opt & OPT_IMAGE_VALIDATE_CODE_INVALID ||
                opt & OPT_IMAGE_VALIDATE_CODE_FORCEINVALID) return RET_IMAGE_INVALID;
            break;
        }
        case 1:  // encrypted
        {
            // 옵션에 따라 성능 향상을 위해 코드가 암호화(AppStore 파일) 되어 있이면 무결성 검사를 하지 않는다.
            if (opt & OPT_IMAGE_VALIDATE_CODE_PASS) return RET_IMAGE_VALID;
            break;
        }
        case -1: // EncryptionInfoLoadCommand not found
        {
            return RET_IMAGE_FAIL;
        }
    }
    
    // get code signature load command blobs
    const struct load_command *p_cs_lc = find_image_date_time(p_mh, p_lc);
    if (p_cs_lc == NULL)
    {
        return RET_IMAGE_FAIL;
    }
    
    return check_image_cache(p_mh, p_cs_lc, opt);
}
