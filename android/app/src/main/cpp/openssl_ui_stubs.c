// android/app/src/main/cpp/openssl_ui_stubs.c
#include <stdio.h>

// Android NDK defines stdin/stderr as macros; undef them so we can provide linker symbols.
#undef stdin
#undef stderr

FILE *stdin = NULL;
FILE *stderr = NULL;
