//
//  lib_kamos.c
//  imagePathlib
//
//  Created by ariesike on 08/11/2019.
//  Copyright © 2019 주성범. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include "lib_image_path_util.h"
#include "image_meta.h"
#include "lib_image_defines.h"


 
// load_mmap_file
// Return the contents of the specified file as a read-only pointer.
//
// Enter:pathname is a UNIX-style “/”-delimited pathname
//
// Exit:    out_data_ptr     pointer to the mapped memory region
//          out_data_length  size of the mapped memory region
//          return value     an errno value on error (see sys/errno.h)
//                           or zero for success
//
int load_mmap_file(char *pathname, void **out_data_ptr, size_t *out_data_length)
{
    int out_error = 0;
    int fd = 0;
    struct stat si;
 
    // Return safe values on error.
    out_error = 0;
    *out_data_ptr = NULL;
    *out_data_length = 0;
 
    // Open the file.
    fd = open(pathname, O_RDONLY, 0);
    if (fd < 0)
    {
       out_error = errno;
    }
    else
    {
        // We now know the file exists. Retrieve the file size.
        if (fstat( fd, &si ) != 0)
        {
            out_error = errno;
        }
        else
        {
            // Map the file into a read-only memory region.
            *out_data_ptr = mmap(NULL,
                                si.st_size,
                                PROT_READ,
                                MAP_PRIVATE,
                                fd,
                                0);
            if (*out_data_ptr == MAP_FAILED)
            {
                out_error = errno;
            }
            else
            {
                // On success, return the size of the mapped file.
                *out_data_length = si.st_size;
            }
        }
 
        // Now close the file. The kernel doesn’t use our file descriptor.
        close(fd);
    }
 
    return out_error;
}

// load_buff_file
// Return the contents of the specified file as a read-only pointer.
//
// Enter:pathname is a UNIX-style “/”-delimited pathname
//
// Exit:    out_data_ptr     pointer to the mapped memory region
//          out_data_length  size of the mapped memory region
//          return value     an errno value on error (see sys/errno.h)
//                           or zero for success
//
int load_buff_file(char *pathname, void **out_data_ptr, size_t *out_data_length)
{
    int out_error = 0;
    FILE *fp = NULL;
    size_t readed = 0;

    fp = fopen(pathname, "rb");
    if (fp == NULL)
    {
       out_error = errno;
    }
    else
    {
        do{
            // obtain file size:
            fseek(fp , 0 , SEEK_END);
            *out_data_length = ftell(fp);
            rewind(fp);
            // allocate memory to contain the whole file:
            *out_data_ptr = (char*)malloc(sizeof(char) * (*out_data_length));
            if (*out_data_ptr == NULL)
            {
                out_error = errno;
                break;
            }
            // copy the file into the buffer:
            readed = fread(*out_data_ptr, 1, *out_data_length, fp);
            if (readed != *out_data_length)
            {
                out_error = errno;
                break;
            }
        }while(0);
    }
    
    if (fp != NULL) fclose(fp);
    return out_error;
}

//
// kamos macho integrity in memory map
//
//int kamos_macho_int_mm(char *path, unsigned char opt)
int image_get_file_path(char *path, unsigned char opt)
{
    int ret = RET_IMAGE_FAIL;
    size_t data_length = 0;
    void *data_ptr = NULL;
 
    if (load_mmap_file(path, &data_ptr, &data_length) == 0)
    {
        ret = get_image_cache(data_ptr, data_length, opt);
        munmap(data_ptr, data_length);
    }
    
    return ret;
}

//
// kamos macho integrity in memory alloc
//
//int kamos_macho_int_ma(char *path, unsigned char opt)
int image_get_path(char *path, unsigned char opt)
{
    int ret = RET_IMAGE_FAIL;
    size_t data_length = 0;
    void *data_ptr = NULL;
    if (load_buff_file(path, &data_ptr, &data_length) == 0)
    {
        ret = get_image_cache(data_ptr, data_length, opt);
        free(data_ptr);
    }
    return ret;
}
